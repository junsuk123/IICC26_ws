#ifndef BUILTIN_INTERFACES__VISIBILITY_CONTROL_H_
#define BUILTIN_INTERFACES__VISIBILITY_CONTROL_H_
#if defined _WIN32 || defined __CYGWIN__
  #ifdef __GNUC__
    #define BUILTIN_INTERFACES_EXPORT __attribute__ ((dllexport))
    #define BUILTIN_INTERFACES_IMPORT __attribute__ ((dllimport))
  #else
    #define BUILTIN_INTERFACES_EXPORT __declspec(dllexport)
    #define BUILTIN_INTERFACES_IMPORT __declspec(dllimport)
  #endif
  #ifdef BUILTIN_INTERFACES_BUILDING_LIBRARY
    #define BUILTIN_INTERFACES_PUBLIC BUILTIN_INTERFACES_EXPORT
  #else
    #define BUILTIN_INTERFACES_PUBLIC BUILTIN_INTERFACES_IMPORT
  #endif
  #define BUILTIN_INTERFACES_PUBLIC_TYPE BUILTIN_INTERFACES_PUBLIC
  #define BUILTIN_INTERFACES_LOCAL
#else
  #define BUILTIN_INTERFACES_EXPORT __attribute__ ((visibility("default")))
  #define BUILTIN_INTERFACES_IMPORT
  #if __GNUC__ >= 4
    #define BUILTIN_INTERFACES_PUBLIC __attribute__ ((visibility("default")))
    #define BUILTIN_INTERFACES_LOCAL  __attribute__ ((visibility("hidden")))
  #else
    #define BUILTIN_INTERFACES_PUBLIC
    #define BUILTIN_INTERFACES_LOCAL
  #endif
  #define BUILTIN_INTERFACES_PUBLIC_TYPE
#endif
#endif  // BUILTIN_INTERFACES__VISIBILITY_CONTROL_H_
// Generated 19-Mar-2026 16:18:06
 