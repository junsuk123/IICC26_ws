#ifndef SJTU_DRONE_DESCRIPTION_WIND_PLUGIN_H
#define SJTU_DRONE_DESCRIPTION_WIND_PLUGIN_H

#include <gazebo/gazebo.hh>
#include <gazebo/physics/physics.hh>
#include <gazebo/common/common.hh>

#include <rclcpp/rclcpp.hpp>
#include <std_msgs/msg/float32_multi_array.hpp>

#include "sjtu_drone_interfaces/srv/set_wind.hpp"

#include <rclcpp/executors/single_threaded_executor.hpp>
#include <thread>

#include <memory>
#include <mutex>

namespace sjtu_drone_description
{

class WindPlugin : public gazebo::WorldPlugin
{
public:
  WindPlugin();
  virtual ~WindPlugin();

  void Load(gazebo::physics::WorldPtr _world, sdf::ElementPtr _sdf) override;

private:
  void OnUpdate();

  gazebo::event::ConnectionPtr updateConnection_;
  gazebo::physics::WorldPtr world_;

  double wind_speed_;        // m/s
  double wind_direction_;    // degrees, 0 = +X
  double area_;              // m^2 cross-section to scale force
  double force_coeff_;       // arbitrary coefficient to scale force
  double publish_rate_hz_;

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
  rclcpp::Time last_pub_time_;

  std::mutex mutex_;
  // executor and thread to allow rclcpp callbacks to run inside Gazebo plugin
  rclcpp::executors::SingleThreadedExecutor::SharedPtr exec_;
  std::thread exec_thread_;
};

}  // namespace sjtu_drone_description

#endif  // SJTU_DRONE_DESCRIPTION_WIND_PLUGIN_H
