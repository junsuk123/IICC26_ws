#include "sjtu_drone_description/wind_plugin.h"

#include <gz/msgs/wind.pb.h>

#include <gz/sim/components/Name.hh>
#include <gz/plugin/Register.hh>

#include <chrono>
#include <cmath>
#include <string>
#include <vector>

using namespace sjtu_drone_description;

GZ_ADD_PLUGIN(
  sjtu_drone_description::WindPlugin,
  gz::sim::System,
  sjtu_drone_description::WindPlugin::ISystemConfigure,
  sjtu_drone_description::WindPlugin::ISystemPreUpdate)

GZ_ADD_PLUGIN_ALIAS(sjtu_drone_description::WindPlugin, "wind_plugin")

WindPlugin::WindPlugin()
: wind_speed_(0.0), wind_direction_(0.0), publish_rate_hz_(10.0)
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

  try {
    if (exec_ && node_) exec_->remove_node(node_);
  } catch(...) {}
  node_.reset();
}

void WindPlugin::Configure(const gz::sim::Entity &_entity,
                           const std::shared_ptr<const sdf::Element> &_sdf,
                           gz::sim::EntityComponentManager &,
                           gz::sim::EventManager &)
{
  this->world_entity_ = _entity;

  // Read parameters from SDF if provided.
  if (_sdf->HasElement("wind_speed"))
    wind_speed_ = _sdf->Get<double>("wind_speed");
  if (_sdf->HasElement("wind_direction"))
    wind_direction_ = _sdf->Get<double>("wind_direction");
  if (_sdf->HasElement("publish_rate_hz"))
    publish_rate_hz_ = _sdf->Get<double>("publish_rate_hz");

  if (publish_rate_hz_ <= 0.0) {
    publish_rate_hz_ = 10.0;
  }

  // Initialize rclcpp if not already initialized in the process.
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

  // Keep existing service contract used by upstream tooling.
  srv_ = node_->create_service<sjtu_drone_interfaces::srv::SetWind>(
    "/set_wind",
    std::bind(&WindPlugin::SetWindCb, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3)
  );

  auto *worldNameComp = _ecm.Component<gz::sim::components::Name>(world_entity_);
  if (worldNameComp) {
    world_name_ = worldNameComp->Data();
  }

  wind_topic_world_ = "/world/" + world_name_ + "/wind";
  wind_topic_global_ = "/wind";
  gz_wind_pub_world_ = gz_node_.Advertise<gz::msgs::Wind>(wind_topic_world_);
  gz_wind_pub_global_ = gz_node_.Advertise<gz::msgs::Wind>(wind_topic_global_);

  // Spin ROS callbacks in a background executor thread.
  exec_ = std::make_shared<rclcpp::executors::SingleThreadedExecutor>();
  exec_->add_node(node_);
  exec_thread_ = std::thread([this]() {
    try {
      exec_->spin();
    } catch (const std::exception &e) {
      std::cerr << "WindPlugin executor error: " << e.what() << std::endl;
    }
  });

  std::cout << "[wind_plugin] Harmonic system plugin configured"
            << " speed=" << wind_speed_
            << " dir=" << wind_direction_
            << " world=" << world_name_
            << " world_topic=" << wind_topic_world_
            << " pub_rate_hz=" << publish_rate_hz_ << std::endl;
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
}

void WindPlugin::PublishWindCommandToGazebo()
{
  const double rad = wind_direction_ * M_PI / 180.0;
  const double vx = std::cos(rad) * wind_speed_;
  const double vy = std::sin(rad) * wind_speed_;

  gz::msgs::Wind windMsg;
  windMsg.mutable_linear_velocity()->set_x(vx);
  windMsg.mutable_linear_velocity()->set_y(vy);
  windMsg.mutable_linear_velocity()->set_z(0.0);

  // WindEffects listens on world-scoped wind topics; publish global too for compatibility.
  gz_wind_pub_world_.Publish(windMsg);
  gz_wind_pub_global_.Publish(windMsg);
}

void WindPlugin::PublishWindCondition(double simSec)
{
  if (!rclcpp::ok() || !pub_) {
    return;
  }

  const double periodSec = 1.0 / std::max(1.0, publish_rate_hz_);
  if (last_pub_sim_sec_ >= 0.0 && (simSec - last_pub_sim_sec_) < periodSec) {
    return;
  }

  std_msgs::msg::Float32MultiArray msg;
  msg.data.resize(2);
  msg.data[0] = static_cast<float>(wind_speed_);
  msg.data[1] = static_cast<float>(wind_direction_);
  pub_->publish(msg);
  last_pub_sim_sec_ = simSec;
}

void WindPlugin::PreUpdate(const gz::sim::UpdateInfo &_info,
                           gz::sim::EntityComponentManager &_ecm)
{
  (void)_ecm;
  if (_info.paused) {
    return;
  }

  std::lock_guard<std::mutex> lock(mutex_);

  const double simSec = std::chrono::duration<double>(_info.simTime).count();
  const double cmdPeriodSec = 0.1;  // 10 Hz command forwarding to WindEffects
  if (last_cmd_sim_sec_ < 0.0 || (simSec - last_cmd_sim_sec_) >= cmdPeriodSec) {
    PublishWindCommandToGazebo();
    last_cmd_sim_sec_ = simSec;
  }
  PublishWindCondition(simSec);
}
