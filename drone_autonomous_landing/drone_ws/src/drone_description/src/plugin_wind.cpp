// Simple wind world plugin implementation
#include "sjtu_drone_description/plugin_wind.h"
#include <gazebo/physics/physics.hh>
#include <gazebo/common/Events.hh>
#include <sdf/sdf.hh>
#include <unordered_map>
#include <thread>

// ROS2
#include <rclcpp/rclcpp.hpp>
#include <geometry_msgs/msg/vector3.hpp>
#include <std_msgs/msg/float64.hpp>
#include <vector>

using namespace sjtu_drone_description;

WindPlugin::WindPlugin()
  : rng_(std::random_device{}()), gustDist_(0.0, 1.0)
{
}

WindPlugin::~WindPlugin()
{
  if (updateConn_)
    updateConn_.reset();
  // stop ROS executor thread and cleanup
  try
  {
    if (rosExecutor_)
    {
      rosRunning_.store(false);
      if (rosSpinThread_.joinable())
        rosSpinThread_.join();
      if (rosNode_)
        rosExecutor_->remove_node(rosNode_);
      rosNode_.reset();
      rosExecutor_.reset();
    }
  }
  catch(...){}
}

void WindPlugin::Load(gazebo::physics::WorldPtr _world, sdf::ElementPtr _sdf)
{
  this->world_ = _world;
  // Read parameters from SDF if present
  if (_sdf->HasElement("mean_wind"))
  {
    auto el = _sdf->GetElement("mean_wind");
    meanWind_.X(el->Get<double>("x"));
    meanWind_.Y(el->Get<double>("y"));
    meanWind_.Z(el->Get<double>("z"));
  }
  if (_sdf->HasElement("gust_std"))
    gustStd_ = _sdf->Get<double>("gust_std");
  if (_sdf->HasElement("air_density"))
    airDensity_ = _sdf->Get<double>("air_density");
  if (_sdf->HasElement("drag_coef"))
    dragCoef_ = _sdf->Get<double>("drag_coef");
  if (_sdf->HasElement("area"))
    area_ = _sdf->Get<double>("area");
  if (_sdf->HasElement("update_rate"))
    updateRate_ = _sdf->Get<double>("update_rate");

  this->lastUpdate_ = this->world_->SimTime();

  // Connect update
  updateConn_ = gazebo::event::Events::ConnectWorldUpdateBegin(
      std::bind(&WindPlugin::OnUpdate, this));

  // Read per-model/link aerodynamics at load time
  // initialize link aero defaults (from world-level defaults)
  for (auto &m : this->world_->Models())
  {
    for (auto &link : m->GetLinks())
    {
      linkAeroMap_[link->GetScopedName()] = {this->area_, this->dragCoef_};
    }
  }

  // parse per-model overrides from the plugin SDF under <model_overrides>
  if (_sdf->HasElement("model_overrides"))
  {
    sdf::ElementPtr mo = _sdf->GetElement("model_overrides");
    while (mo && mo->HasElement("model"))
    {
      sdf::ElementPtr modelEl = mo->GetElement("model");
      std::string modelName = modelEl->Get<std::string>("name");
      // iterate links
      if (modelEl->HasElement("link"))
      {
        sdf::ElementPtr linkEl = modelEl->GetElement("link");
        while (linkEl)
        {
          std::string linkName = linkEl->Get<std::string>("name");
          double a = this->area_;
          double d = this->dragCoef_;
          if (linkEl->HasElement("area")) a = linkEl->Get<double>("area");
          if (linkEl->HasElement("drag_coef")) d = linkEl->Get<double>("drag_coef");
          // find the scoped name for model::link
          std::string scoped = modelName + "::" + linkName;
          // store override if link exists
          auto it = linkAeroMap_.find(scoped);
          if (it != linkAeroMap_.end())
            it->second = {a, d};
          // next link sibling
          linkEl = linkEl->GetNextElement("link");
        }
      }
      // move to next model sibling if any
      if (mo->HasElement("model"))
        mo = mo->GetNextElement("model");
      else
        break;
    }
  }

  // Initialize ROS node and subscriptions for runtime control
  if (!rclcpp::ok())
  {
    rclcpp::init(0, nullptr);
  }
  rosNode_ = std::make_shared<rclcpp::Node>("wind_plugin_node");
  meanSub_ = rosNode_->create_subscription<geometry_msgs::msg::Vector3>(
      "/wind/mean", rclcpp::SystemDefaultsQoS(),
      [this](const geometry_msgs::msg::Vector3::SharedPtr msg)
      {
        this->meanWind_.X(msg->x);
        this->meanWind_.Y(msg->y);
        this->meanWind_.Z(msg->z);
        gzmsg << "WindPlugin: updated mean wind via ROS: " << this->meanWind_ << std::endl;
      });

  gustSub_ = rosNode_->create_subscription<std_msgs::msg::Float64>(
      "/wind/gust_std", rclcpp::SystemDefaultsQoS(),
      [this](const std_msgs::msg::Float64::SharedPtr msg)
      {
        this->gustStd_ = msg->data;
        gzmsg << "WindPlugin: updated gust_std via ROS: " << this->gustStd_ << std::endl;
      });

  // Declare ROS parameters for control (mean_wind and gust_std)
  rosNode_->declare_parameter("mean_wind.x", this->meanWind_.X());
  rosNode_->declare_parameter("mean_wind.y", this->meanWind_.Y());
  rosNode_->declare_parameter("mean_wind.z", this->meanWind_.Z());
  rosNode_->declare_parameter("gust_std", this->gustStd_);

  // watch for parameter changes
  rosParamCbHandle_ = rosNode_->add_on_set_parameters_callback([
    this](const std::vector<rclcpp::Parameter> &params)
  {
    for (auto &p : params)
    {
      if (p.get_name() == "mean_wind.x") this->meanWind_.X(p.as_double());
      if (p.get_name() == "mean_wind.y") this->meanWind_.Y(p.as_double());
      if (p.get_name() == "mean_wind.z") this->meanWind_.Z(p.as_double());
      if (p.get_name() == "gust_std") this->gustStd_ = p.as_double();
    }
    gzmsg << "WindPlugin: parameters updated via ROS params: mean=" << this->meanWind_ << " gust=" << this->gustStd_ << std::endl;
    rcl_interfaces::msg::SetParametersResult res;
    res.successful = true;
    res.reason = "";
    return res;
  });

  // Per-model topic subscriptions: /wind/<model>/mean and /wind/<model>/gust_std
  for (auto &m : this->world_->Models())
  {
    std::string model_name = m->GetName();
    std::string mean_topic = "/wind/" + model_name + "/mean";
    std::string gust_topic = "/wind/" + model_name + "/gust_std";

    auto mean_sub = rosNode_->create_subscription<geometry_msgs::msg::Vector3>(
      mean_topic, rclcpp::SystemDefaultsQoS(),
      [this, model_name](const geometry_msgs::msg::Vector3::SharedPtr msg)
      {
        this->perModelWind_[model_name].mean = ignition::math::Vector3d(msg->x, msg->y, msg->z);
        gzmsg << "WindPlugin: per-model mean updated for " << model_name << " -> " << this->perModelWind_[model_name].mean << std::endl;
      });
    auto gust_sub = rosNode_->create_subscription<std_msgs::msg::Float64>(
      gust_topic, rclcpp::SystemDefaultsQoS(),
      [this, model_name](const std_msgs::msg::Float64::SharedPtr msg)
      {
        this->perModelWind_[model_name].gust_std = msg->data;
        gzmsg << "WindPlugin: per-model gust updated for " << model_name << " -> " << msg->data << std::endl;
      });

    perModelMeanSubs_.push_back(mean_sub);
    perModelGustSubs_.push_back(gust_sub);
  }

  rosExecutor_ = std::make_shared<rclcpp::executors::SingleThreadedExecutor>();
  rosExecutor_->add_node(rosNode_);
  // spin in a thread but allow controlled shutdown via rosRunning_
  rosRunning_.store(true);
  rosSpinThread_ = std::thread([this]() {
    while (this->rosRunning_.load())
    {
      this->rosExecutor_->spin_some(std::chrono::milliseconds(10));
      std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }
  });

  gzmsg << "WindPlugin loaded: meanWind=" << meanWind_ << " gustStd=" << gustStd_ << " updateRate=" << updateRate_ << std::endl;
}

void WindPlugin::OnUpdate()
{
  gazebo::common::Time now = this->world_->SimTime();
  double dt = (now - lastUpdate_).Double();
  if (dt <= 0.0)
    return;
  // Respect update rate
  if (updateRate_ > 0.0 && dt < 1.0/updateRate_)
    return;

  // sample gusts (simple gaussian) and compute wind vector
  double gx = gustDist_(rng_) * gustStd_;
  double gy = gustDist_(rng_) * gustStd_;
  double gz = gustDist_(rng_) * gustStd_;
  ignition::math::Vector3d wind = meanWind_ + ignition::math::Vector3d(gx, gy, gz);

  // Apply aerodynamic force to each link
  auto models = this->world_->Models();
  for (auto &m : models)
  {
    // skip static models
    if (m->IsStatic())
      continue;
    auto links = m->GetLinks();
    for (auto &link : links)
    {
      // get relative velocity of air at link
      ignition::math::Vector3d vel = wind - link->WorldLinearVel();
      double speed = vel.Length();
      if (speed <= 1e-6)
        continue;
      // aerodynamic drag force: 0.5 * rho * Cd * A * v^2 (direction of vel)
      // lookup per-link aero
      double area = area_;
      double dragCoef = dragCoef_;
      auto it = linkAeroMap_.find(link->GetScopedName());
      if (it != linkAeroMap_.end())
      {
        area = it->second.area;
        dragCoef = it->second.drag_coef;
      }
      double mag = 0.5 * airDensity_ * dragCoef * area * speed * speed;
      ignition::math::Vector3d force = vel / speed * mag;
      link->AddForce(force);
    }
  }

  lastUpdate_ = now;
}

// Register plugin with Gazebo
GZ_REGISTER_WORLD_PLUGIN(WindPlugin)
