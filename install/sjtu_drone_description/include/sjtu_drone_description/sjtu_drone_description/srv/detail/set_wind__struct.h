// generated from rosidl_generator_c/resource/idl__struct.h.em
// with input from sjtu_drone_description:srv/SetWind.idl
// generated code does not contain a copyright notice

#ifndef SJTU_DRONE_DESCRIPTION__SRV__DETAIL__SET_WIND__STRUCT_H_
#define SJTU_DRONE_DESCRIPTION__SRV__DETAIL__SET_WIND__STRUCT_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>


// Constants defined in the message

/// Struct defined in srv/SetWind in the package sjtu_drone_description.
typedef struct sjtu_drone_description__srv__SetWind_Request
{
  float speed;
  float direction;
} sjtu_drone_description__srv__SetWind_Request;

// Struct for a sequence of sjtu_drone_description__srv__SetWind_Request.
typedef struct sjtu_drone_description__srv__SetWind_Request__Sequence
{
  sjtu_drone_description__srv__SetWind_Request * data;
  /// The number of valid items in data
  size_t size;
  /// The number of allocated items in data
  size_t capacity;
} sjtu_drone_description__srv__SetWind_Request__Sequence;


// Constants defined in the message

// Include directives for member types
// Member 'message'
#include "rosidl_runtime_c/string.h"

/// Struct defined in srv/SetWind in the package sjtu_drone_description.
typedef struct sjtu_drone_description__srv__SetWind_Response
{
  bool success;
  rosidl_runtime_c__String message;
} sjtu_drone_description__srv__SetWind_Response;

// Struct for a sequence of sjtu_drone_description__srv__SetWind_Response.
typedef struct sjtu_drone_description__srv__SetWind_Response__Sequence
{
  sjtu_drone_description__srv__SetWind_Response * data;
  /// The number of valid items in data
  size_t size;
  /// The number of allocated items in data
  size_t capacity;
} sjtu_drone_description__srv__SetWind_Response__Sequence;

#ifdef __cplusplus
}
#endif

#endif  // SJTU_DRONE_DESCRIPTION__SRV__DETAIL__SET_WIND__STRUCT_H_
