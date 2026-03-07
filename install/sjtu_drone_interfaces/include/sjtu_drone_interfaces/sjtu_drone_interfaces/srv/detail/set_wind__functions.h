// generated from rosidl_generator_c/resource/idl__functions.h.em
// with input from sjtu_drone_interfaces:srv/SetWind.idl
// generated code does not contain a copyright notice

#ifndef SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__FUNCTIONS_H_
#define SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__FUNCTIONS_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>
#include <stdlib.h>

#include "rosidl_runtime_c/visibility_control.h"
#include "sjtu_drone_interfaces/msg/rosidl_generator_c__visibility_control.h"

#include "sjtu_drone_interfaces/srv/detail/set_wind__struct.h"

/// Initialize srv/SetWind message.
/**
 * If the init function is called twice for the same message without
 * calling fini inbetween previously allocated memory will be leaked.
 * \param[in,out] msg The previously allocated message pointer.
 * Fields without a default value will not be initialized by this function.
 * You might want to call memset(msg, 0, sizeof(
 * sjtu_drone_interfaces__srv__SetWind_Request
 * )) before or use
 * sjtu_drone_interfaces__srv__SetWind_Request__create()
 * to allocate and initialize the message.
 * \return true if initialization was successful, otherwise false
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Request__init(sjtu_drone_interfaces__srv__SetWind_Request * msg);

/// Finalize srv/SetWind message.
/**
 * \param[in,out] msg The allocated message pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Request__fini(sjtu_drone_interfaces__srv__SetWind_Request * msg);

/// Create srv/SetWind message.
/**
 * It allocates the memory for the message, sets the memory to zero, and
 * calls
 * sjtu_drone_interfaces__srv__SetWind_Request__init().
 * \return The pointer to the initialized message if successful,
 * otherwise NULL
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
sjtu_drone_interfaces__srv__SetWind_Request *
sjtu_drone_interfaces__srv__SetWind_Request__create();

/// Destroy srv/SetWind message.
/**
 * It calls
 * sjtu_drone_interfaces__srv__SetWind_Request__fini()
 * and frees the memory of the message.
 * \param[in,out] msg The allocated message pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Request__destroy(sjtu_drone_interfaces__srv__SetWind_Request * msg);

/// Check for srv/SetWind message equality.
/**
 * \param[in] lhs The message on the left hand size of the equality operator.
 * \param[in] rhs The message on the right hand size of the equality operator.
 * \return true if messages are equal, otherwise false.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Request__are_equal(const sjtu_drone_interfaces__srv__SetWind_Request * lhs, const sjtu_drone_interfaces__srv__SetWind_Request * rhs);

/// Copy a srv/SetWind message.
/**
 * This functions performs a deep copy, as opposed to the shallow copy that
 * plain assignment yields.
 *
 * \param[in] input The source message pointer.
 * \param[out] output The target message pointer, which must
 *   have been initialized before calling this function.
 * \return true if successful, or false if either pointer is null
 *   or memory allocation fails.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Request__copy(
  const sjtu_drone_interfaces__srv__SetWind_Request * input,
  sjtu_drone_interfaces__srv__SetWind_Request * output);

/// Initialize array of srv/SetWind messages.
/**
 * It allocates the memory for the number of elements and calls
 * sjtu_drone_interfaces__srv__SetWind_Request__init()
 * for each element of the array.
 * \param[in,out] array The allocated array pointer.
 * \param[in] size The size / capacity of the array.
 * \return true if initialization was successful, otherwise false
 * If the array pointer is valid and the size is zero it is guaranteed
 # to return true.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Request__Sequence__init(sjtu_drone_interfaces__srv__SetWind_Request__Sequence * array, size_t size);

/// Finalize array of srv/SetWind messages.
/**
 * It calls
 * sjtu_drone_interfaces__srv__SetWind_Request__fini()
 * for each element of the array and frees the memory for the number of
 * elements.
 * \param[in,out] array The initialized array pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Request__Sequence__fini(sjtu_drone_interfaces__srv__SetWind_Request__Sequence * array);

/// Create array of srv/SetWind messages.
/**
 * It allocates the memory for the array and calls
 * sjtu_drone_interfaces__srv__SetWind_Request__Sequence__init().
 * \param[in] size The size / capacity of the array.
 * \return The pointer to the initialized array if successful, otherwise NULL
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
sjtu_drone_interfaces__srv__SetWind_Request__Sequence *
sjtu_drone_interfaces__srv__SetWind_Request__Sequence__create(size_t size);

/// Destroy array of srv/SetWind messages.
/**
 * It calls
 * sjtu_drone_interfaces__srv__SetWind_Request__Sequence__fini()
 * on the array,
 * and frees the memory of the array.
 * \param[in,out] array The initialized array pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Request__Sequence__destroy(sjtu_drone_interfaces__srv__SetWind_Request__Sequence * array);

/// Check for srv/SetWind message array equality.
/**
 * \param[in] lhs The message array on the left hand size of the equality operator.
 * \param[in] rhs The message array on the right hand size of the equality operator.
 * \return true if message arrays are equal in size and content, otherwise false.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Request__Sequence__are_equal(const sjtu_drone_interfaces__srv__SetWind_Request__Sequence * lhs, const sjtu_drone_interfaces__srv__SetWind_Request__Sequence * rhs);

/// Copy an array of srv/SetWind messages.
/**
 * This functions performs a deep copy, as opposed to the shallow copy that
 * plain assignment yields.
 *
 * \param[in] input The source array pointer.
 * \param[out] output The target array pointer, which must
 *   have been initialized before calling this function.
 * \return true if successful, or false if either pointer
 *   is null or memory allocation fails.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Request__Sequence__copy(
  const sjtu_drone_interfaces__srv__SetWind_Request__Sequence * input,
  sjtu_drone_interfaces__srv__SetWind_Request__Sequence * output);

/// Initialize srv/SetWind message.
/**
 * If the init function is called twice for the same message without
 * calling fini inbetween previously allocated memory will be leaked.
 * \param[in,out] msg The previously allocated message pointer.
 * Fields without a default value will not be initialized by this function.
 * You might want to call memset(msg, 0, sizeof(
 * sjtu_drone_interfaces__srv__SetWind_Response
 * )) before or use
 * sjtu_drone_interfaces__srv__SetWind_Response__create()
 * to allocate and initialize the message.
 * \return true if initialization was successful, otherwise false
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Response__init(sjtu_drone_interfaces__srv__SetWind_Response * msg);

/// Finalize srv/SetWind message.
/**
 * \param[in,out] msg The allocated message pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Response__fini(sjtu_drone_interfaces__srv__SetWind_Response * msg);

/// Create srv/SetWind message.
/**
 * It allocates the memory for the message, sets the memory to zero, and
 * calls
 * sjtu_drone_interfaces__srv__SetWind_Response__init().
 * \return The pointer to the initialized message if successful,
 * otherwise NULL
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
sjtu_drone_interfaces__srv__SetWind_Response *
sjtu_drone_interfaces__srv__SetWind_Response__create();

/// Destroy srv/SetWind message.
/**
 * It calls
 * sjtu_drone_interfaces__srv__SetWind_Response__fini()
 * and frees the memory of the message.
 * \param[in,out] msg The allocated message pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Response__destroy(sjtu_drone_interfaces__srv__SetWind_Response * msg);

/// Check for srv/SetWind message equality.
/**
 * \param[in] lhs The message on the left hand size of the equality operator.
 * \param[in] rhs The message on the right hand size of the equality operator.
 * \return true if messages are equal, otherwise false.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Response__are_equal(const sjtu_drone_interfaces__srv__SetWind_Response * lhs, const sjtu_drone_interfaces__srv__SetWind_Response * rhs);

/// Copy a srv/SetWind message.
/**
 * This functions performs a deep copy, as opposed to the shallow copy that
 * plain assignment yields.
 *
 * \param[in] input The source message pointer.
 * \param[out] output The target message pointer, which must
 *   have been initialized before calling this function.
 * \return true if successful, or false if either pointer is null
 *   or memory allocation fails.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Response__copy(
  const sjtu_drone_interfaces__srv__SetWind_Response * input,
  sjtu_drone_interfaces__srv__SetWind_Response * output);

/// Initialize array of srv/SetWind messages.
/**
 * It allocates the memory for the number of elements and calls
 * sjtu_drone_interfaces__srv__SetWind_Response__init()
 * for each element of the array.
 * \param[in,out] array The allocated array pointer.
 * \param[in] size The size / capacity of the array.
 * \return true if initialization was successful, otherwise false
 * If the array pointer is valid and the size is zero it is guaranteed
 # to return true.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Response__Sequence__init(sjtu_drone_interfaces__srv__SetWind_Response__Sequence * array, size_t size);

/// Finalize array of srv/SetWind messages.
/**
 * It calls
 * sjtu_drone_interfaces__srv__SetWind_Response__fini()
 * for each element of the array and frees the memory for the number of
 * elements.
 * \param[in,out] array The initialized array pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Response__Sequence__fini(sjtu_drone_interfaces__srv__SetWind_Response__Sequence * array);

/// Create array of srv/SetWind messages.
/**
 * It allocates the memory for the array and calls
 * sjtu_drone_interfaces__srv__SetWind_Response__Sequence__init().
 * \param[in] size The size / capacity of the array.
 * \return The pointer to the initialized array if successful, otherwise NULL
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
sjtu_drone_interfaces__srv__SetWind_Response__Sequence *
sjtu_drone_interfaces__srv__SetWind_Response__Sequence__create(size_t size);

/// Destroy array of srv/SetWind messages.
/**
 * It calls
 * sjtu_drone_interfaces__srv__SetWind_Response__Sequence__fini()
 * on the array,
 * and frees the memory of the array.
 * \param[in,out] array The initialized array pointer.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
void
sjtu_drone_interfaces__srv__SetWind_Response__Sequence__destroy(sjtu_drone_interfaces__srv__SetWind_Response__Sequence * array);

/// Check for srv/SetWind message array equality.
/**
 * \param[in] lhs The message array on the left hand size of the equality operator.
 * \param[in] rhs The message array on the right hand size of the equality operator.
 * \return true if message arrays are equal in size and content, otherwise false.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Response__Sequence__are_equal(const sjtu_drone_interfaces__srv__SetWind_Response__Sequence * lhs, const sjtu_drone_interfaces__srv__SetWind_Response__Sequence * rhs);

/// Copy an array of srv/SetWind messages.
/**
 * This functions performs a deep copy, as opposed to the shallow copy that
 * plain assignment yields.
 *
 * \param[in] input The source array pointer.
 * \param[out] output The target array pointer, which must
 *   have been initialized before calling this function.
 * \return true if successful, or false if either pointer
 *   is null or memory allocation fails.
 */
ROSIDL_GENERATOR_C_PUBLIC_sjtu_drone_interfaces
bool
sjtu_drone_interfaces__srv__SetWind_Response__Sequence__copy(
  const sjtu_drone_interfaces__srv__SetWind_Response__Sequence * input,
  sjtu_drone_interfaces__srv__SetWind_Response__Sequence * output);

#ifdef __cplusplus
}
#endif

#endif  // SJTU_DRONE_INTERFACES__SRV__DETAIL__SET_WIND__FUNCTIONS_H_
