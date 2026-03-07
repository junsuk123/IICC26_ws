// generated from rosidl_generator_cpp/resource/idl__builder.hpp.em
// with input from sjtu_drone_interfaces:srv/SetWind.idl
// generated code does not contain a copyright notice

#ifndef SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__BUILDER_HPP_
#define SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__BUILDER_HPP_

#include <algorithm>
#include <utility>

#include "sjtu_drone_interfaces/srv/detail/set_wind__struct.hpp"
#include "rosidl_runtime_cpp/message_initialization.hpp"


namespace sjtu_drone_interfaces
{

namespace srv
{

namespace builder
{

class Init_SetWind_Request_direction
{
public:
  explicit Init_SetWind_Request_direction(::sjtu_drone_interfaces::srv::SetWind_Request & msg)
  : msg_(msg)
  {}
  ::sjtu_drone_interfaces::srv::SetWind_Request direction(::sjtu_drone_interfaces::srv::SetWind_Request::_direction_type arg)
  {
    msg_.direction = std::move(arg);
    return std::move(msg_);
  }

private:
  ::sjtu_drone_interfaces::srv::SetWind_Request msg_;
};

class Init_SetWind_Request_speed
{
public:
  Init_SetWind_Request_speed()
  : msg_(::rosidl_runtime_cpp::MessageInitialization::SKIP)
  {}
  Init_SetWind_Request_direction speed(::sjtu_drone_interfaces::srv::SetWind_Request::_speed_type arg)
  {
    msg_.speed = std::move(arg);
    return Init_SetWind_Request_direction(msg_);
  }

private:
  ::sjtu_drone_interfaces::srv::SetWind_Request msg_;
};

}  // namespace builder

}  // namespace srv

template<typename MessageType>
auto build();

template<>
inline
auto build<::sjtu_drone_interfaces::srv::SetWind_Request>()
{
  return sjtu_drone_interfaces::srv::builder::Init_SetWind_Request_speed();
}

}  // namespace sjtu_drone_interfaces


namespace sjtu_drone_interfaces
{

namespace srv
{

namespace builder
{

class Init_SetWind_Response_message
{
public:
  explicit Init_SetWind_Response_message(::sjtu_drone_interfaces::srv::SetWind_Response & msg)
  : msg_(msg)
  {}
  ::sjtu_drone_interfaces::srv::SetWind_Response message(::sjtu_drone_interfaces::srv::SetWind_Response::_message_type arg)
  {
    msg_.message = std::move(arg);
    return std::move(msg_);
  }

private:
  ::sjtu_drone_interfaces::srv::SetWind_Response msg_;
};

class Init_SetWind_Response_success
{
public:
  Init_SetWind_Response_success()
  : msg_(::rosidl_runtime_cpp::MessageInitialization::SKIP)
  {}
  Init_SetWind_Response_message success(::sjtu_drone_interfaces::srv::SetWind_Response::_success_type arg)
  {
    msg_.success = std::move(arg);
    return Init_SetWind_Response_message(msg_);
  }

private:
  ::sjtu_drone_interfaces::srv::SetWind_Response msg_;
};

}  // namespace builder

}  // namespace srv

template<typename MessageType>
auto build();

template<>
inline
auto build<::sjtu_drone_interfaces::srv::SetWind_Response>()
{
  return sjtu_drone_interfaces::srv::builder::Init_SetWind_Response_success();
}

}  // namespace sjtu_drone_interfaces

#endif  // SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__BUILDER_HPP_
