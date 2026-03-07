// generated from rosidl_generator_cpp/resource/idl__traits.hpp.em
// with input from sjtu_drone_interfaces:srv/SetWind.idl
// generated code does not contain a copyright notice

#ifndef SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__TRAITS_HPP_
#define SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__TRAITS_HPP_

#include <stdint.h>

#include <sstream>
#include <string>
#include <type_traits>

#include "sjtu_drone_interfaces/srv/detail/set_wind__struct.hpp"
#include "rosidl_runtime_cpp/traits.hpp"

namespace sjtu_drone_interfaces
{

namespace srv
{

inline void to_flow_style_yaml(
  const SetWind_Request & msg,
  std::ostream & out)
{
  out << "{";
  // member: speed
  {
    out << "speed: ";
    rosidl_generator_traits::value_to_yaml(msg.speed, out);
    out << ", ";
  }

  // member: direction
  {
    out << "direction: ";
    rosidl_generator_traits::value_to_yaml(msg.direction, out);
  }
  out << "}";
}  // NOLINT(readability/fn_size)

inline void to_block_style_yaml(
  const SetWind_Request & msg,
  std::ostream & out, size_t indentation = 0)
{
  // member: speed
  {
    if (indentation > 0) {
      out << std::string(indentation, ' ');
    }
    out << "speed: ";
    rosidl_generator_traits::value_to_yaml(msg.speed, out);
    out << "\n";
  }

  // member: direction
  {
    if (indentation > 0) {
      out << std::string(indentation, ' ');
    }
    out << "direction: ";
    rosidl_generator_traits::value_to_yaml(msg.direction, out);
    out << "\n";
  }
}  // NOLINT(readability/fn_size)

inline std::string to_yaml(const SetWind_Request & msg, bool use_flow_style = false)
{
  std::ostringstream out;
  if (use_flow_style) {
    to_flow_style_yaml(msg, out);
  } else {
    to_block_style_yaml(msg, out);
  }
  return out.str();
}

}  // namespace srv

}  // namespace sjtu_drone_interfaces

namespace rosidl_generator_traits
{

[[deprecated("use sjtu_drone_interfaces::srv::to_block_style_yaml() instead")]]
inline void to_yaml(
  const sjtu_drone_interfaces::srv::SetWind_Request & msg,
  std::ostream & out, size_t indentation = 0)
{
  sjtu_drone_interfaces::srv::to_block_style_yaml(msg, out, indentation);
}

[[deprecated("use sjtu_drone_interfaces::srv::to_yaml() instead")]]
inline std::string to_yaml(const sjtu_drone_interfaces::srv::SetWind_Request & msg)
{
  return sjtu_drone_interfaces::srv::to_yaml(msg);
}

template<>
inline const char * data_type<sjtu_drone_interfaces::srv::SetWind_Request>()
{
  return "sjtu_drone_interfaces::srv::SetWind_Request";
}

template<>
inline const char * name<sjtu_drone_interfaces::srv::SetWind_Request>()
{
  return "sjtu_drone_interfaces/srv/SetWind_Request";
}

template<>
struct has_fixed_size<sjtu_drone_interfaces::srv::SetWind_Request>
  : std::integral_constant<bool, true> {};

template<>
struct has_bounded_size<sjtu_drone_interfaces::srv::SetWind_Request>
  : std::integral_constant<bool, true> {};

template<>
struct is_message<sjtu_drone_interfaces::srv::SetWind_Request>
  : std::true_type {};

}  // namespace rosidl_generator_traits

namespace sjtu_drone_interfaces
{

namespace srv
{

inline void to_flow_style_yaml(
  const SetWind_Response & msg,
  std::ostream & out)
{
  out << "{";
  // member: success
  {
    out << "success: ";
    rosidl_generator_traits::value_to_yaml(msg.success, out);
    out << ", ";
  }

  // member: message
  {
    out << "message: ";
    rosidl_generator_traits::value_to_yaml(msg.message, out);
  }
  out << "}";
}  // NOLINT(readability/fn_size)

inline void to_block_style_yaml(
  const SetWind_Response & msg,
  std::ostream & out, size_t indentation = 0)
{
  // member: success
  {
    if (indentation > 0) {
      out << std::string(indentation, ' ');
    }
    out << "success: ";
    rosidl_generator_traits::value_to_yaml(msg.success, out);
    out << "\n";
  }

  // member: message
  {
    if (indentation > 0) {
      out << std::string(indentation, ' ');
    }
    out << "message: ";
    rosidl_generator_traits::value_to_yaml(msg.message, out);
    out << "\n";
  }
}  // NOLINT(readability/fn_size)

inline std::string to_yaml(const SetWind_Response & msg, bool use_flow_style = false)
{
  std::ostringstream out;
  if (use_flow_style) {
    to_flow_style_yaml(msg, out);
  } else {
    to_block_style_yaml(msg, out);
  }
  return out.str();
}

}  // namespace srv

}  // namespace sjtu_drone_interfaces

namespace rosidl_generator_traits
{

[[deprecated("use sjtu_drone_interfaces::srv::to_block_style_yaml() instead")]]
inline void to_yaml(
  const sjtu_drone_interfaces::srv::SetWind_Response & msg,
  std::ostream & out, size_t indentation = 0)
{
  sjtu_drone_interfaces::srv::to_block_style_yaml(msg, out, indentation);
}

[[deprecated("use sjtu_drone_interfaces::srv::to_yaml() instead")]]
inline std::string to_yaml(const sjtu_drone_interfaces::srv::SetWind_Response & msg)
{
  return sjtu_drone_interfaces::srv::to_yaml(msg);
}

template<>
inline const char * data_type<sjtu_drone_interfaces::srv::SetWind_Response>()
{
  return "sjtu_drone_interfaces::srv::SetWind_Response";
}

template<>
inline const char * name<sjtu_drone_interfaces::srv::SetWind_Response>()
{
  return "sjtu_drone_interfaces/srv/SetWind_Response";
}

template<>
struct has_fixed_size<sjtu_drone_interfaces::srv::SetWind_Response>
  : std::integral_constant<bool, false> {};

template<>
struct has_bounded_size<sjtu_drone_interfaces::srv::SetWind_Response>
  : std::integral_constant<bool, false> {};

template<>
struct is_message<sjtu_drone_interfaces::srv::SetWind_Response>
  : std::true_type {};

}  // namespace rosidl_generator_traits

namespace rosidl_generator_traits
{

template<>
inline const char * data_type<sjtu_drone_interfaces::srv::SetWind>()
{
  return "sjtu_drone_interfaces::srv::SetWind";
}

template<>
inline const char * name<sjtu_drone_interfaces::srv::SetWind>()
{
  return "sjtu_drone_interfaces/srv/SetWind";
}

template<>
struct has_fixed_size<sjtu_drone_interfaces::srv::SetWind>
  : std::integral_constant<
    bool,
    has_fixed_size<sjtu_drone_interfaces::srv::SetWind_Request>::value &&
    has_fixed_size<sjtu_drone_interfaces::srv::SetWind_Response>::value
  >
{
};

template<>
struct has_bounded_size<sjtu_drone_interfaces::srv::SetWind>
  : std::integral_constant<
    bool,
    has_bounded_size<sjtu_drone_interfaces::srv::SetWind_Request>::value &&
    has_bounded_size<sjtu_drone_interfaces::srv::SetWind_Response>::value
  >
{
};

template<>
struct is_service<sjtu_drone_interfaces::srv::SetWind>
  : std::true_type
{
};

template<>
struct is_service_request<sjtu_drone_interfaces::srv::SetWind_Request>
  : std::true_type
{
};

template<>
struct is_service_response<sjtu_drone_interfaces::srv::SetWind_Response>
  : std::true_type
{
};

}  // namespace rosidl_generator_traits

#endif  // SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__TRAITS_HPP_
