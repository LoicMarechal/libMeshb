
################################
# GLOBAL CONFIGURATION VARIABLES
################################

if (CMAKE_MAJOR_VERSION GREATER "2")
  cmake_minimum_required (VERSION 3.0)
else()
  cmake_minimum_required (VERSION 2.6)
endif()
set (libMeshb_VERSION_MAJOR 7)
set (libMeshb_VERSION_MINOR 24)
if (CMAKE_MAJOR_VERSION GREATER "2")
  project (libMeshb
    VERSION ${libMeshb_VERSION_MAJOR}.${libMeshb_VERSION_MINOR}
    LANGUAGES C)
else()
  project (libMeshb)
endif()
set (CMAKE_C_FLAGS "-O3")
set (CMAKE_Fortran_FLAGS "-O3")
if (NOT CMAKE_INSTALL_PREFIX)
  set (CMAKE_INSTALL_PREFIX "/opt/libMeshb")
endif()


#######################################
# SET FILES AND DIRECTORIES TO BE BUILT
#######################################

include_directories ("${PROJECT_SOURCE_DIR}/sources")
add_subdirectory (sources)
add_subdirectory (examples)
add_subdirectory (utilities)
install (FILES LICENSE copyright.txt DESTINATION share/libMeshb)
install (DIRECTORY sample_meshes DESTINATION share/libMeshb)


######################################
# SET PACKAGE AND DEPLOYMENT VARIABLES
######################################

include (InstallRequiredSystemLibraries)
set (CPACK_GENERATOR "TGZ")
set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/copyright.txt")
set (CPACK_PACKAGE_VERSION_MAJOR "${libMeshb_VERSION_MAJOR}")
set (CPACK_PACKAGE_VERSION_MINOR "${libMeshb_VERSION_MINOR}")
set(CPACK_COMPONENTS_ALL applications examples libraries headers)
include (CPack)

######################################
# EXPORT CMAKE PACKAGE INFORMATION
######################################

if (CMAKE_MAJOR_VERSION GREATER "2")
  include(CMakePackageConfigHelpers)
  file(WRITE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
      "include(\${CMAKE_CURRENT_LIST_DIR}/meshb-target.cmake)")
  write_basic_package_version_file(
      "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
      VERSION ${PROJECT_VERSION}
      COMPATIBILITY SameMajorVersion)
  install(FILES
      "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
      "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
      DESTINATION lib/cmake/${PROJECT_NAME})
endif()
