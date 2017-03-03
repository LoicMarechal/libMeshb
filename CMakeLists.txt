

################################
# GLOBAL CONFIGURATION VARIABLES
################################

cmake_minimum_required (VERSION 3.0.1)
set (libMeshb_VERSION_MAJOR 7)
set (libMeshb_VERSION_MINOR 24)

if (WIN32)
   set (CMAKE_C_FLAGS "-DWIN32")
   set (CMAKE_CONFIGURATION_TYPES "Release")
else ()
   set (CMAKE_C_FLAGS "-O3")
   set (CMAKE_Fortran_FLAGS "-O3")
endif ()

project (libMeshb VERSION ${libMeshb_VERSION_MAJOR}.${libMeshb_VERSION_MINOR} LANGUAGES C)

include (CheckLanguage)
check_language (Fortran)
if(CMAKE_Fortran_COMPILER)
  enable_language(Fortran)
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

include(CMakePackageConfigHelpers)
file(WRITE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
"include(\${CMAKE_CURRENT_LIST_DIR}/meshb-target.cmake)
set(libMeshb_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include)
set(libMeshb_C_LIBRARY ${CMAKE_INSTALL_PREFIX}/lib/libMeshb.${libMeshb_VERSION_MAJOR}.a)
set(libMeshb_Fortran_LIBRARY ${CMAKE_INSTALL_PREFIX}/lib/libMeshbf.${libMeshb_VERSION_MAJOR}.a)
")
write_basic_package_version_file(
   "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
   VERSION ${PROJECT_VERSION}
   COMPATIBILITY SameMajorVersion)
install(FILES
   "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
   "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
   DESTINATION lib/cmake/${PROJECT_NAME})
