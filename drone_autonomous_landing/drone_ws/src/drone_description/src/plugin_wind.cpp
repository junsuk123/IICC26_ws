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
#include "drone_description/srv/set_wind.hpp"
#include "drone_description/srv/get_wind.hpp"

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
  for (auto &m : this->world_->Models())
  {
    for (auto &link : m->GetLinks())
    {
      // defaults
      double area = this->area_;
      double drag = this->dragCoef_;
      // try to read from link SDF: <aerodynamics><area> <drag_coef>
      if (link->GetSDF())
      {
        sdf::ElementPtr aer = link->GetSDF()->GetElement("aerodynamics");
        if (aer)
        {
          if (aer->HasElement("area"))
            area = aer->Get<double>("area");
          if (aer->HasElement("drag_coef"))
            drag = aer->Get<double>("drag_coef");
        }
      }
      linkAeroMap_[link->GetScopedName()] = {area, drag};
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

  // Services: SetWind and GetWind
  using SetWind = drone_description::srv::SetWind;
  using GetWind = drone_description::srv::GetWind;

  auto set_cb = [this](const std::shared_ptr<SetWind::Request> req, std::shared_ptr<SetWind::Response> res)
  {
    std::string model = req->model_name;
    ignition::math::Vector3d m(req->mean.x, req->mean.y, req->mean.z);
    double g = req->gust_std;
    if (model.empty())
    {
      this->meanWind_ = m;
      this->gustStd_ = g;
      res->success = true;
      res->message = "Global wind set";
      gzmsg << "WindPlugin: Set global wind via service: " << this->meanWind_ << " g=" << this->gustStd_ << std::endl;
    }
    else
    {
      this->perModelWind_[model] = {m, g};
      res->success = true;
      res->message = "Per-model wind set for " + model;
      gzmsg << "WindPlugin: Set wind for model " << model << " => " << m << " g=" << g << std::endl;
    }
  };
  setService_ = rosNode_->create_service<SetWind> ("/wind/set_wind", set_cb);

  auto get_cb = [this](const std::shared_ptr<GetWind::Request> req, std::shared_ptr<GetWind::Response> res)
  {
    std::string model = req->model_name;
    if (model.empty())
    {
      res->mean.x = this->meanWind_.X();
      res->mean.y = this->meanWind_.Y();
      res->mean.z = this->meanWind_.Z();
      res->gust_std = this->gustStd_;
      res->found = true;
    }
    else
    {
      auto it = this->perModelWind_.find(model);
      if (it!= this->perModelWind_.end())
      {
        res->mean.x = it->second.mean.X();
        res->mean.y = it->second.mean.Y();
        res->mean.z = it->second.mean.Z();
        res->gust_std = it->second.gust_std;
        res->found = true;
      }
      else
      {
        res->found = false;
      }
    }
  };
  getService_ = rosNode_->create_service<GetWind>("/wind/get_wind", get_cb);

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
