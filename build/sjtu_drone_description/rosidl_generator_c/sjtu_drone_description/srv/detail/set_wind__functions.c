// generated from rosidl_generator_c/resource/idl__functions.c.em
// with input from sjtu_drone_description:srv/SetWind.idl
// generated code does not contain a copyright notice
#include "sjtu_drone_description/srv/detail/set_wind__functions.h"

#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "rcutils/allocator.h"

bool
sjtu_drone_description__srv__SetWind_Request__init(sjtu_drone_description__srv__SetWind_Request * msg)
{
  if (!msg) {
    return false;
  }
  // speed
  // direction
  return true;
}

void
sjtu_drone_description__srv__SetWind_Request__fini(sjtu_drone_description__srv__SetWind_Request * msg)
{
  if (!msg) {
    return;
  }
  // speed
  // direction
}

bool
sjtu_drone_description__srv__SetWind_Request__are_equal(const sjtu_drone_description__srv__SetWind_Request * lhs, const sjtu_drone_description__srv__SetWind_Request * rhs)
{
  if (!lhs || !rhs) {
    return false;
  }
  // speed
  if (lhs->speed != rhs->speed) {
    return false;
  }
  // direction
  if (lhs->direction != rhs->direction) {
    return false;
  }
  return true;
}

bool
sjtu_drone_description__srv__SetWind_Request__copy(
  const sjtu_drone_description__srv__SetWind_Request * input,
  sjtu_drone_description__srv__SetWind_Request * output)
{
  if (!input || !output) {
    return false;
  }
  // speed
  output->speed = input->speed;
  // direction
  output->direction = input->direction;
  return true;
}

sjtu_drone_description__srv__SetWind_Request *
sjtu_drone_description__srv__SetWind_Request__create()
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  sjtu_drone_description__srv__SetWind_Request * msg = (sjtu_drone_description__srv__SetWind_Request *)allocator.allocate(sizeof(sjtu_drone_description__srv__SetWind_Request), allocator.state);
  if (!msg) {
    return NULL;
  }
  memset(msg, 0, sizeof(sjtu_drone_description__srv__SetWind_Request));
  bool success = sjtu_drone_description__srv__SetWind_Request__init(msg);
  if (!success) {
    allocator.deallocate(msg, allocator.state);
    return NULL;
  }
  return msg;
}

void
sjtu_drone_description__srv__SetWind_Request__destroy(sjtu_drone_description__srv__SetWind_Request * msg)
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  if (msg) {
    sjtu_drone_description__srv__SetWind_Request__fini(msg);
  }
  allocator.deallocate(msg, allocator.state);
}


bool
sjtu_drone_description__srv__SetWind_Request__Sequence__init(sjtu_drone_description__srv__SetWind_Request__Sequence * array, size_t size)
{
  if (!array) {
    return false;
  }
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  sjtu_drone_description__srv__SetWind_Request * data = NULL;

  if (size) {
    data = (sjtu_drone_description__srv__SetWind_Request *)allocator.zero_allocate(size, sizeof(sjtu_drone_description__srv__SetWind_Request), allocator.state);
    if (!data) {
      return false;
    }
    // initialize all array elements
    size_t i;
    for (i = 0; i < size; ++i) {
      bool success = sjtu_drone_description__srv__SetWind_Request__init(&data[i]);
      if (!success) {
        break;
      }
    }
    if (i < size) {
      // if initialization failed finalize the already initialized array elements
      for (; i > 0; --i) {
        sjtu_drone_description__srv__SetWind_Request__fini(&data[i - 1]);
      }
      allocator.deallocate(data, allocator.state);
      return false;
    }
  }
  array->data = data;
  array->size = size;
  array->capacity = size;
  return true;
}

void
sjtu_drone_description__srv__SetWind_Request__Sequence__fini(sjtu_drone_description__srv__SetWind_Request__Sequence * array)
{
  if (!array) {
    return;
  }
  rcutils_allocator_t allocator = rcutils_get_default_allocator();

  if (array->data) {
    // ensure that data and capacity values are consistent
    assert(array->capacity > 0);
    // finalize all array elements
    for (size_t i = 0; i < array->capacity; ++i) {
      sjtu_drone_description__srv__SetWind_Request__fini(&array->data[i]);
    }
    allocator.deallocate(array->data, allocator.state);
    array->data = NULL;
    array->size = 0;
    array->capacity = 0;
  } else {
    // ensure that data, size, and capacity values are consistent
    assert(0 == array->size);
    assert(0 == array->capacity);
  }
}

sjtu_drone_description__srv__SetWind_Request__Sequence *
sjtu_drone_description__srv__SetWind_Request__Sequence__create(size_t size)
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  sjtu_drone_description__srv__SetWind_Request__Sequence * array = (sjtu_drone_description__srv__SetWind_Request__Sequence *)allocator.allocate(sizeof(sjtu_drone_description__srv__SetWind_Request__Sequence), allocator.state);
  if (!array) {
    return NULL;
  }
  bool success = sjtu_drone_description__srv__SetWind_Request__Sequence__init(array, size);
  if (!success) {
    allocator.deallocate(array, allocator.state);
    return NULL;
  }
  return array;
}

void
sjtu_drone_description__srv__SetWind_Request__Sequence__destroy(sjtu_drone_description__srv__SetWind_Request__Sequence * array)
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  if (array) {
    sjtu_drone_description__srv__SetWind_Request__Sequence__fini(array);
  }
  allocator.deallocate(array, allocator.state);
}

bool
sjtu_drone_description__srv__SetWind_Request__Sequence__are_equal(const sjtu_drone_description__srv__SetWind_Request__Sequence * lhs, const sjtu_drone_description__srv__SetWind_Request__Sequence * rhs)
{
  if (!lhs || !rhs) {
    return false;
  }
  if (lhs->size != rhs->size) {
    return false;
  }
  for (size_t i = 0; i < lhs->size; ++i) {
    if (!sjtu_drone_description__srv__SetWind_Request__are_equal(&(lhs->data[i]), &(rhs->data[i]))) {
      return false;
    }
  }
  return true;
}

bool
sjtu_drone_description__srv__SetWind_Request__Sequence__copy(
  const sjtu_drone_description__srv__SetWind_Request__Sequence * input,
  sjtu_drone_description__srv__SetWind_Request__Sequence * output)
{
  if (!input || !output) {
    return false;
  }
  if (output->capacity < input->size) {
    const size_t allocation_size =
      input->size * sizeof(sjtu_drone_description__srv__SetWind_Request);
    rcutils_allocator_t allocator = rcutils_get_default_allocator();
    sjtu_drone_description__srv__SetWind_Request * data =
      (sjtu_drone_description__srv__SetWind_Request *)allocator.reallocate(
      output->data, allocation_size, allocator.state);
    if (!data) {
      return false;
    }
    // If reallocation succeeded, memory may or may not have been moved
    // to fulfill the allocation request, invalidating output->data.
    output->data = data;
    for (size_t i = output->capacity; i < input->size; ++i) {
      if (!sjtu_drone_description__srv__SetWind_Request__init(&output->data[i])) {
        // If initialization of any new item fails, roll back
        // all previously initialized items. Existing items
        // in output are to be left unmodified.
        for (; i-- > output->capacity; ) {
          sjtu_drone_description__srv__SetWind_Request__fini(&output->data[i]);
        }
        return false;
      }
    }
    output->capacity = input->size;
  }
  output->size = input->size;
  for (size_t i = 0; i < input->size; ++i) {
    if (!sjtu_drone_description__srv__SetWind_Request__copy(
        &(input->data[i]), &(output->data[i])))
    {
      return false;
    }
  }
  return true;
}


// Include directives for member types
// Member `message`
#include "rosidl_runtime_c/string_functions.h"

bool
sjtu_drone_description__srv__SetWind_Response__init(sjtu_drone_description__srv__SetWind_Response * msg)
{
  if (!msg) {
    return false;
  }
  // success
  // message
  if (!rosidl_runtime_c__String__init(&msg->message)) {
    sjtu_drone_description__srv__SetWind_Response__fini(msg);
    return false;
  }
  return true;
}

void
sjtu_drone_description__srv__SetWind_Response__fini(sjtu_drone_description__srv__SetWind_Response * msg)
{
  if (!msg) {
    return;
  }
  // success
  // message
  rosidl_runtime_c__String__fini(&msg->message);
}

bool
sjtu_drone_description__srv__SetWind_Response__are_equal(const sjtu_drone_description__srv__SetWind_Response * lhs, const sjtu_drone_description__srv__SetWind_Response * rhs)
{
  if (!lhs || !rhs) {
    return false;
  }
  // success
  if (lhs->success != rhs->success) {
    return false;
  }
  // message
  if (!rosidl_runtime_c__String__are_equal(
      &(lhs->message), &(rhs->message)))
  {
    return false;
  }
  return true;
}

bool
sjtu_drone_description__srv__SetWind_Response__copy(
  const sjtu_drone_description__srv__SetWind_Response * input,
  sjtu_drone_description__srv__SetWind_Response * output)
{
  if (!input || !output) {
    return false;
  }
  // success
  output->success = input->success;
  // message
  if (!rosidl_runtime_c__String__copy(
      &(input->message), &(output->message)))
  {
    return false;
  }
  return true;
}

sjtu_drone_description__srv__SetWind_Response *
sjtu_drone_description__srv__SetWind_Response__create()
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  sjtu_drone_description__srv__SetWind_Response * msg = (sjtu_drone_description__srv__SetWind_Response *)allocator.allocate(sizeof(sjtu_drone_description__srv__SetWind_Response), allocator.state);
  if (!msg) {
    return NULL;
  }
  memset(msg, 0, sizeof(sjtu_drone_description__srv__SetWind_Response));
  bool success = sjtu_drone_description__srv__SetWind_Response__init(msg);
  if (!success) {
    allocator.deallocate(msg, allocator.state);
    return NULL;
  }
  return msg;
}

void
sjtu_drone_description__srv__SetWind_Response__destroy(sjtu_drone_description__srv__SetWind_Response * msg)
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  if (msg) {
    sjtu_drone_description__srv__SetWind_Response__fini(msg);
  }
  allocator.deallocate(msg, allocator.state);
}


bool
sjtu_drone_description__srv__SetWind_Response__Sequence__init(sjtu_drone_description__srv__SetWind_Response__Sequence * array, size_t size)
{
  if (!array) {
    return false;
  }
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  sjtu_drone_description__srv__SetWind_Response * data = NULL;

  if (size) {
    data = (sjtu_drone_description__srv__SetWind_Response *)allocator.zero_allocate(size, sizeof(sjtu_drone_description__srv__SetWind_Response), allocator.state);
    if (!data) {
      return false;
    }
    // initialize all array elements
    size_t i;
    for (i = 0; i < size; ++i) {
      bool success = sjtu_drone_description__srv__SetWind_Response__init(&data[i]);
      if (!success) {
        break;
      }
    }
    if (i < size) {
      // if initialization failed finalize the already initialized array elements
      for (; i > 0; --i) {
        sjtu_drone_description__srv__SetWind_Response__fini(&data[i - 1]);
      }
      allocator.deallocate(data, allocator.state);
      return false;
    }
  }
  array->data = data;
  array->size = size;
  array->capacity = size;
  return true;
}

void
sjtu_drone_description__srv__SetWind_Response__Sequence__fini(sjtu_drone_description__srv__SetWind_Response__Sequence * array)
{
  if (!array) {
    return;
  }
  rcutils_allocator_t allocator = rcutils_get_default_allocator();

  if (array->data) {
    // ensure that data and capacity values are consistent
    assert(array->capacity > 0);
    // finalize all array elements
    for (size_t i = 0; i < array->capacity; ++i) {
      sjtu_drone_description__srv__SetWind_Response__fini(&array->data[i]);
    }
    allocator.deallocate(array->data, allocator.state);
    array->data = NULL;
    array->size = 0;
    array->capacity = 0;
  } else {
    // ensure that data, size, and capacity values are consistent
    assert(0 == array->size);
    assert(0 == array->capacity);
  }
}

sjtu_drone_description__srv__SetWind_Response__Sequence *
sjtu_drone_description__srv__SetWind_Response__Sequence__create(size_t size)
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  sjtu_drone_description__srv__SetWind_Response__Sequence * array = (sjtu_drone_description__srv__SetWind_Response__Sequence *)allocator.allocate(sizeof(sjtu_drone_description__srv__SetWind_Response__Sequence), allocator.state);
  if (!array) {
    return NULL;
  }
  bool success = sjtu_drone_description__srv__SetWind_Response__Sequence__init(array, size);
  if (!success) {
    allocator.deallocate(array, allocator.state);
    return NULL;
  }
  return array;
}

void
sjtu_drone_description__srv__SetWind_Response__Sequence__destroy(sjtu_drone_description__srv__SetWind_Response__Sequence * array)
{
  rcutils_allocator_t allocator = rcutils_get_default_allocator();
  if (array) {
    sjtu_drone_description__srv__SetWind_Response__Sequence__fini(array);
  }
  allocator.deallocate(array, allocator.state);
}

bool
sjtu_drone_description__srv__SetWind_Response__Sequence__are_equal(const sjtu_drone_description__srv__SetWind_Response__Sequence * lhs, const sjtu_drone_description__srv__SetWind_Response__Sequence * rhs)
{
  if (!lhs || !rhs) {
    return false;
  }
  if (lhs->size != rhs->size) {
    return false;
  }
  for (size_t i = 0; i < lhs->size; ++i) {
    if (!sjtu_drone_description__srv__SetWind_Response__are_equal(&(lhs->data[i]), &(rhs->data[i]))) {
      return false;
    }
  }
  return true;
}

bool
sjtu_drone_description__srv__SetWind_Response__Sequence__copy(
  const sjtu_drone_description__srv__SetWind_Response__Sequence * input,
  sjtu_drone_description__srv__SetWind_Response__Sequence * output)
{
  if (!input || !output) {
    return false;
  }
  if (output->capacity < input->size) {
    const size_t allocation_size =
      input->size * sizeof(sjtu_drone_description__srv__SetWind_Response);
    rcutils_allocator_t allocator = rcutils_get_default_allocator();
    sjtu_drone_description__srv__SetWind_Response * data =
      (sjtu_drone_description__srv__SetWind_Response *)allocator.reallocate(
      output->data, allocation_size, allocator.state);
    if (!data) {
      return false;
    }
    // If reallocation succeeded, memory may or may not have been moved
    // to fulfill the allocation request, invalidating output->data.
    output->data = data;
    for (size_t i = output->capacity; i < input->size; ++i) {
      if (!sjtu_drone_description__srv__SetWind_Response__init(&output->data[i])) {
        // If initialization of any new item fails, roll back
        // all previously initialized items. Existing items
        // in output are to be left unmodified.
        for (; i-- > output->capacity; ) {
          sjtu_drone_description__srv__SetWind_Response__fini(&output->data[i]);
        }
        return false;
      }
    }
    output->capacity = input->size;
  }
  output->size = input->size;
  for (size_t i = 0; i < input->size; ++i) {
    if (!sjtu_drone_description__srv__SetWind_Response__copy(
        &(input->data[i]), &(output->data[i])))
    {
      return false;
    }
  }
  return true;
}
