#ifndef GEOMETRY_MSGS__VISIBILITY_CONTROL_H_
#define GEOMETRY_MSGS__VISIBILITY_CONTROL_H_
#if defined _WIN32 || defined __CYGWIN__
  #ifdef __GNUC__
    #define GEOMETRY_MSGS_EXPORT __attribute__ ((dllexport))
    #define GEOMETRY_MSGS_IMPORT __attribute__ ((dllimport))
  #else
    #define GEOMETRY_MSGS_EXPORT __declspec(dllexport)
    #define GEOMETRY_MSGS_IMPORT __declspec(dllimport)
  #endif
  #ifdef GEOMETRY_MSGS_BUILDING_LIBRARY
    #define GEOMETRY_MSGS_PUBLIC GEOMETRY_MSGS_EXPORT
  #else
    #define GEOMETRY_MSGS_PUBLIC GEOMETRY_MSGS_IMPORT
  #endif
  #define GEOMETRY_MSGS_PUBLIC_TYPE GEOMETRY_MSGS_PUBLIC
  #define GEOMETRY_MSGS_LOCAL
#else
  #define GEOMETRY_MSGS_EXPORT __attribute__ ((visibility("default")))
  #define GEOMETRY_MSGS_IMPORT
  #if __GNUC__ >= 4
    #define GEOMETRY_MSGS_PUBLIC __attribute__ ((visibility("default")))
    #define GEOMETRY_MSGS_LOCAL  __attribute__ ((visibility("hidden")))
  #else
    #define GEOMETRY_MSGS_PUBLIC
    #define GEOMETRY_MSGS_LOCAL
  #endif
  #define GEOMETRY_MSGS_PUBLIC_TYPE
#endif
#endif  // GEOMETRY_MSGS__VISIBILITY_CONTROL_H_
// Generated 19-Mar-2026 16:18:11
 