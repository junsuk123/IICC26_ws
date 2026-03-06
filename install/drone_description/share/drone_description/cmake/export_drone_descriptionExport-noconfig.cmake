#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "drone_description::plugin_drone" for configuration ""
set_property(TARGET drone_description::plugin_drone APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(drone_description::plugin_drone PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libplugin_drone.so"
  IMPORTED_SONAME_NOCONFIG "libplugin_drone.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS drone_description::plugin_drone )
list(APPEND _IMPORT_CHECK_FILES_FOR_drone_description::plugin_drone "${_IMPORT_PREFIX}/lib/libplugin_drone.so" )

# Import target "drone_description::plugin_wind" for configuration ""
set_property(TARGET drone_description::plugin_wind APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(drone_description::plugin_wind PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libplugin_wind.so"
  IMPORTED_SONAME_NOCONFIG "libplugin_wind.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS drone_description::plugin_wind )
list(APPEND _IMPORT_CHECK_FILES_FOR_drone_description::plugin_wind "${_IMPORT_PREFIX}/lib/libplugin_wind.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
