#ifndef STD_MSGS__VISIBILITY_CONTROL_H_
#define STD_MSGS__VISIBILITY_CONTROL_H_
#if defined _WIN32 || defined __CYGWIN__
  #ifdef __GNUC__
    #define STD_MSGS_EXPORT __attribute__ ((dllexport))
    #define STD_MSGS_IMPORT __attribute__ ((dllimport))
  #else
    #define STD_MSGS_EXPORT __declspec(dllexport)
    #define STD_MSGS_IMPORT __declspec(dllimport)
  #endif
  #ifdef STD_MSGS_BUILDING_LIBRARY
    #define STD_MSGS_PUBLIC STD_MSGS_EXPORT
  #else
    #define STD_MSGS_PUBLIC STD_MSGS_IMPORT
  #endif
  #define STD_MSGS_PUBLIC_TYPE STD_MSGS_PUBLIC
  #define STD_MSGS_LOCAL
#else
  #define STD_MSGS_EXPORT __attribute__ ((visibility("default")))
  #define STD_MSGS_IMPORT
  #if __GNUC__ >= 4
    #define STD_MSGS_PUBLIC __attribute__ ((visibility("default")))
    #define STD_MSGS_LOCAL  __attribute__ ((visibility("hidden")))
  #else
    #define STD_MSGS_PUBLIC
    #define STD_MSGS_LOCAL
  #endif
  #define STD_MSGS_PUBLIC_TYPE
#endif
#endif  // STD_MSGS__VISIBILITY_CONTROL_H_
// Generated 19-Mar-2026 16:18:12
 