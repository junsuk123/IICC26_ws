// Simple wind world plugin header
#ifndef SJTU_DRONE_DESCRIPTION_PLUGIN_WIND_H
#define SJTU_DRONE_DESCRIPTION_PLUGIN_WIND_H

#include <gazebo/gazebo.hh>
#include <gazebo/physics/physics.hh>
#include <gazebo/common/common.hh>
#include <random>
// ROS2
#include <rclcpp/rclcpp.hpp>
#include <geometry_msgs/msg/vector3.hpp>
#include <std_msgs/msg/float64.hpp>
#include <atomic>
#include <unordered_map>
#include <string>
#include <vector>
#include <thread>

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

private:
  gazebo::physics::WorldPtr world_;
  gazebo::event::ConnectionPtr updateConn_;

  // Wind parameters
  ignition::math::Vector3d meanWind_{0,0,0};
  double gustStd_{0.0};
  double airDensity_{1.225};
  double dragCoef_{1.0};
  double area_{1.0};
  double updateRate_{50.0};

  std::mt19937 rng_;
  std::normal_distribution<double> gustDist_;
  gazebo::common::Time lastUpdate_;

  // Per-link aerodynamic parameters (area, drag coef)
  struct LinkAero { double area; double drag_coef; };
  std::unordered_map<std::string, LinkAero> linkAeroMap_;

  // per-model overrides from service: model_name -> {mean, gust}
  struct WindParams { ignition::math::Vector3d mean; double gust_std; };
  std::unordered_map<std::string, WindParams> perModelWind_;

  // ROS control
  rclcpp::Node::SharedPtr rosNode_;
  rclcpp::executors::SingleThreadedExecutor::SharedPtr rosExecutor_;
  std::thread rosSpinThread_;
  rclcpp::Subscription<geometry_msgs::msg::Vector3>::SharedPtr meanSub_;
  rclcpp::Subscription<std_msgs::msg::Float64>::SharedPtr gustSub_;
  std::atomic<bool> rosRunning_{false};
  // parameter callback handle and per-model subscriptions
  rclcpp::node_interfaces::OnSetParametersCallbackHandle::SharedPtr rosParamCbHandle_;
  std::vector<rclcpp::Subscription<geometry_msgs::msg::Vector3>::SharedPtr> perModelMeanSubs_;
  std::vector<rclcpp::Subscription<std_msgs::msg::Float64>::SharedPtr> perModelGustSubs_;
};

} // namespace sjtu_drone_description

#endif // SJTU_DRONE_DESCRIPTION_PLUGIN_WIND_H
