#include "sjtu_drone_description/wind_plugin.h"

#include <ignition/math/Vector3.hh>
#include <ignition/math/Helpers.hh>

#include <gazebo/physics/Model.hh>
#include <gazebo/physics/Link.hh>
#include <gazebo/common/Plugin.hh>
#include <gazebo/transport/transport.hh>

#include <cmath>
#include <string>
#include <vector>

using namespace gazebo;
using namespace sjtu_drone_description;

// Register this plugin with the simulator
GZ_REGISTER_WORLD_PLUGIN(WindPlugin)

WindPlugin::WindPlugin()
: WorldPlugin(), wind_speed_(0.0), wind_direction_(0.0), area_(0.1), force_coeff_(1.0), publish_rate_hz_(10.0)
{
}

WindPlugin::~WindPlugin()
{
  // stop executor and join thread
  try {
    if (exec_) {
      exec_->cancel();
    }
  } catch(...) {}
  if (exec_thread_.joinable()) {
    exec_thread_.join();
  }
  // remove node from executor and reset
  try {
    if (exec_ && node_) exec_->remove_node(node_);
  } catch(...) {}
  node_.reset();
}

void WindPlugin::Load(gazebo::physics::WorldPtr _world, sdf::ElementPtr _sdf)
{
  this->world_ = _world;

  // Read parameters from SDF if provided
  if (_sdf->HasElement("wind_speed"))
    wind_speed_ = _sdf->Get<double>("wind_speed");
  if (_sdf->HasElement("wind_direction"))
    wind_direction_ = _sdf->Get<double>("wind_direction");
  if (_sdf->HasElement("area"))
    area_ = _sdf->Get<double>("area");
  if (_sdf->HasElement("force_coeff"))
    force_coeff_ = _sdf->Get<double>("force_coeff");
  if (_sdf->HasElement("publish_rate_hz"))
    publish_rate_hz_ = _sdf->Get<double>("publish_rate_hz");

  // Initialize rclcpp if not already initialized in the process
  if (!rclcpp::ok()) {
    int argc = 0;
    rclcpp::init(argc, nullptr);
  }

  node_ = std::make_shared<rclcpp::Node>("gazebo_wind_plugin_node");
  pub_ = node_->create_publisher<std_msgs::msg::Float32MultiArray>("/wind_condition", 10);
  // subscription to allow runtime updates to wind parameters
  sub_ = node_->create_subscription<std_msgs::msg::Float32MultiArray>(
    "/wind_command",
    10,
    std::bind(&WindPlugin::WindCommandCb, this, std::placeholders::_1)
  );
  // create service to allow setting wind via /set_wind (srv: sjtu_drone_description/srv/SetWind)
  srv_ = node_->create_service<sjtu_drone_interfaces::srv::SetWind>(
    "/set_wind",
    std::bind(&WindPlugin::SetWindCb, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)
  );
  last_pub_time_ = node_->now();

  // create executor and spin it in a background thread so callbacks run
  exec_ = std::make_shared<rclcpp::executors::SingleThreadedExecutor>();
  exec_->add_node(node_);
  exec_thread_ = std::thread([this]() {
    try {
      exec_->spin();
    } catch (const std::exception &e) {
      std::cerr << "WindPlugin executor error: " << e.what() << std::endl;
    }
  });

  // Connect to the update event
  this->updateConnection_ = event::Events::ConnectWorldUpdateBegin(
    std::bind(&WindPlugin::OnUpdate, this));

  gzdbg << "WindPlugin loaded: speed=" << wind_speed_ << " dir=" << wind_direction_ << " deg area=" << area_ << " coeff=" << force_coeff_ << "\n";
}

void WindPlugin::WindCommandCb(const std_msgs::msg::Float32MultiArray::SharedPtr msg)
{
  if (!msg) return;
  std::lock_guard<std::mutex> lock(mutex_);
  if (msg->data.size() >= 1) {
    wind_speed_ = msg->data[0];
  }
  if (msg->data.size() >= 2) {
    wind_direction_ = msg->data[1];
  }
  RCLCPP_INFO(node_->get_logger(), "WindPlugin: set wind_speed=%.2f wind_direction=%.1f", wind_speed_, wind_direction_);
  gzdbg << "WindPlugin: received command -> speed=" << wind_speed_ << " dir=" << wind_direction_ << "\n";
}

void WindPlugin::SetWindCb(const std::shared_ptr<rmw_request_id_t> request_header,
                           const std::shared_ptr<sjtu_drone_interfaces::srv::SetWind::Request> request,
                           std::shared_ptr<sjtu_drone_interfaces::srv::SetWind::Response> response)
{
  (void)request_header;
  if (!request) {
    response->success = false;
    response->message = "empty request";
    return;
  }
  std::lock_guard<std::mutex> lock(mutex_);
  wind_speed_ = static_cast<double>(request->speed);
  wind_direction_ = static_cast<double>(request->direction);
  response->success = true;
  response->message = "wind set";
  RCLCPP_INFO(node_->get_logger(), "WindPlugin service: set wind_speed=%.2f wind_direction=%.1f", wind_speed_, wind_direction_);
  gzdbg << "WindPlugin service: received set_wind -> speed=" << wind_speed_ << " dir=" << wind_direction_ << "\n";
}

void WindPlugin::OnUpdate()
{
  std::lock_guard<std::mutex> lock(mutex_);

  // compute force vector in world XY plane
  // convert degrees to radians
  double rad = wind_direction_ * M_PI / 180.0;
  double fx = std::cos(rad) * wind_speed_ * force_coeff_ * area_;
  double fy = std::sin(rad) * wind_speed_ * force_coeff_ * area_;

  // apply force to any model that looks like a drone (simple heuristic) or to all models if none matched
  bool applied_to_any = false;
  auto models = this->world_->Models();
  for (auto &model : models) {
    // heuristic: model name contains "drone" or "sjtu_drone"
    std::string name = model->GetName();
    if (name.find("drone") == std::string::npos && name.find("sjtu_drone") == std::string::npos) {
      continue;
    }

    // find a link to apply force to (prefer base_link, otherwise first link)
    physics::LinkPtr link = model->GetLink("base_link");
    if (!link) {
      auto links = model->GetLinks();
      if (!links.empty()) link = links[0];
    }
    if (!link) continue;

    ignition::math::Vector3d force(fx, fy, 0.0);
    link->AddForce(force);
    applied_to_any = true;
  }

  // if none matched, apply to all models' first link (useful for testing)
  if (!applied_to_any) {
    for (auto &model : models) {
      auto links = model->GetLinks();
      if (links.empty()) continue;
      links[0]->AddForce(ignition::math::Vector3d(fx, fy, 0.0));
    }
  }

  // publish wind condition at the requested rate
  if (rclcpp::ok()) {
    rclcpp::Time now = node_->now();
    double dt = (now - last_pub_time_).seconds();
    if (dt >= 1.0 / std::max(1.0, publish_rate_hz_)) {
      std_msgs::msg::Float32MultiArray msg;
      msg.data.resize(2);
      msg.data[0] = static_cast<float>(wind_speed_);
      msg.data[1] = static_cast<float>(wind_direction_);
      pub_->publish(msg);
      last_pub_time_ = now;
    }
  }
}
