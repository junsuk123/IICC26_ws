#ifndef SJTU_DRONE_DESCRIPTION_WIND_PLUGIN_H
#define SJTU_DRONE_DESCRIPTION_WIND_PLUGIN_H

#include <gz/sim/System.hh>
#include <gz/sim/Entity.hh>
#include <gz/sim/EntityComponentManager.hh>
#include <gz/transport/Node.hh>

#include <rclcpp/rclcpp.hpp>
#include <std_msgs/msg/float32_multi_array.hpp>

#include "sjtu_drone_interfaces/srv/set_wind.hpp"

#include <rclcpp/executors/single_threaded_executor.hpp>
#include <thread>

#include <memory>
#include <mutex>
#include <string>

namespace sjtu_drone_description
{

class WindPlugin : public gz::sim::System,
                   public gz::sim::ISystemConfigure,
                   public gz::sim::ISystemPreUpdate
{
public:
  WindPlugin();
  ~WindPlugin() override;

  void Configure(const gz::sim::Entity &_entity,
                 const std::shared_ptr<const sdf::Element> &_sdf,
                 gz::sim::EntityComponentManager &_ecm,
                 gz::sim::EventManager &_eventMgr) override;

  void PreUpdate(const gz::sim::UpdateInfo &_info,
                 gz::sim::EntityComponentManager &_ecm) override;

private:
  void PublishWindCommandToGazebo();
  void PublishWindCondition(double simSec);

  gz::sim::Entity world_entity_{gz::sim::kNullEntity};
  std::string world_name_;
  std::string wind_topic_world_;
  std::string wind_topic_global_;
  gz::transport::Node gz_node_;
  gz::transport::Node::Publisher gz_wind_pub_world_;
  gz::transport::Node::Publisher gz_wind_pub_global_;

  double wind_speed_;        // m/s
  double wind_direction_;    // degrees, 0 = +X
  double publish_rate_hz_;
  double last_pub_sim_sec_{-1.0};
  double last_cmd_sim_sec_{-1.0};

  // ROS publisher
  rclcpp::Publisher<std_msgs::msg::Float32MultiArray>::SharedPtr pub_;
  rclcpp::Node::SharedPtr node_;
  rclcpp::Subscription<std_msgs::msg::Float32MultiArray>::SharedPtr sub_;
  rclcpp::Service<sjtu_drone_interfaces::srv::SetWind>::SharedPtr srv_;

  // callback to receive runtime wind commands [speed, direction]
  void WindCommandCb(const std_msgs::msg::Float32MultiArray::SharedPtr msg);
  void SetWindCb(const std::shared_ptr<rmw_request_id_t> request_header,
                 const std::shared_ptr<sjtu_drone_interfaces::srv::SetWind::Request> request,
                 std::shared_ptr<sjtu_drone_interfaces::srv::SetWind::Response> response);

  std::mutex mutex_;
  // executor and thread to allow rclcpp callbacks to run inside Gazebo plugin
  rclcpp::executors::SingleThreadedExecutor::SharedPtr exec_;
  std::thread exec_thread_;
};

}  // namespace sjtu_drone_description

#endif  // SJTU_DRONE_DESCRIPTION_WIND_PLUGIN_H
