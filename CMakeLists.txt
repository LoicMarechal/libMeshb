

################################
# GLOBAL CONFIGURATION VARIABLES
################################

cmake_minimum_required (VERSION 3.18)
set (libMeshb_VERSION_MAJOR 8)
set (libMeshb_VERSION_MINOR 00)
project(libMeshb VERSION ${libMeshb_VERSION_MAJOR}.${libMeshb_VERSION_MINOR} LANGUAGES C)

option(WITH_GMF_AIO     "Use Unix low-level and asynchronous I/O for higher speed"       OFF)
option(WITH_GMF_CPACK   "Enable cpack target to generate a zip file containing binaries" OFF)
option(WITH_GMF_CTEST   "Enable ctest ti run basic validation tests"                     OFF)
option(BUILD_DOCS       "Build the reference documentation"                              OFF)

set(LIBMESHB_HOME ${PROJECT_SOURCE_DIR})
set(LIBMESHB_SRC ${LIBMESHB_HOME}/sources)
set(LIBMESHB_UTILS ${LIBMESHB_HOME}/utilities)
set(LIBMESHB_EXAMPLES ${LIBMESHB_HOME}/examples)
set(LIBMESHB_DOCS ${LIBMESHB_HOME}/docs)

include (CheckLanguage)
check_language (Fortran)
if(CMAKE_Fortran_COMPILER)
  enable_language(Fortran)
  set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)
endif()

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif ()

if (CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
   set (math_LIBRARIES "m")
endif ()

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
   if (WIN32)
      set(CMAKE_INSTALL_PREFIX "$ENV{HOMEPATH}/cmakebuilds" CACHE PATH "..." FORCE)
   else ()
      if (DEFINED ENV{OSTYPE} AND DEFINED ENV{MACHTYPE})
         set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/cmakebuilds/$ENV{OSTYPE}-$ENV{MACHTYPE}" CACHE PATH "..." FORCE)
      else ()
         set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/cmakebuilds" CACHE PATH "..." FORCE)
      endif ()
   endif()
endif ()

list (APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(WITH_GMF_AIO)
   set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DWITH_GMF_AIO")
   IF(${CMAKE_SYSTEM_NAME} MATCHES Linux)
      set(AIO_LIBRARIES rt)
   endif()
endif()

find_package(LPlib 4 CONFIG)

if (LPlib_FOUND)
   include_directories (${LPlib_INCLUDE_DIRS})
endif ()


#######################################
# SET FILES AND DIRECTORIES TO BE BUILT
#######################################

include_directories (${LIBMESHB_SRC})
include_directories (${LIBMESHB_UTILS})
add_subdirectory (sources)
add_subdirectory (examples)
add_subdirectory (utilities)

install (FILES LICENSE.txt copyright.txt DESTINATION share/libMeshb)
install (DIRECTORY sample_meshes DESTINATION share/libMeshb)


#############################
# BUILD THE API DOCUMENTATION
#############################

if(BUILD_DOCS)
   find_package(Doxygen REQUIRED OPTIONAL_COMPONENTS dot)

   # Input and output files
   set(DOXYGEN_IN ${PROJECT_SOURCE_DIR}/docs/Doxyfile.in)
   set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile.out)

   # Configure the file
   configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
   message("Doxygen build started")

   # https://discourse.cmake.org/t/how-to-export-environment-variables-globally/13892/2
   add_custom_target(docs
      COMMAND ${CMAKE_COMMAND} -E env # Environment variables are referenced in Doxyfile.in
                                      CMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
                                      LIBMESHB_SRC=${LIBMESHB_SRC}
                                      LIBMESHB_DOC=${LIBMESHB_DOCS}
                                      LIBMESHB_EXAMPLES=${LIBMESHB_EXAMPLES}
                                      LIBMESHB_UTILS=${LIBMESHB_UTILS}
                                      LIBMESHB_PROJECTNAME=${CMAKE_PROJECT_NAME}
                                      LIBMESHB_VERSION=${libMeshb_VERSION_MAJOR}.${libMeshb_VERSION_MINOR}
                                      # Set input and output files
                                      DOXYGEN_IN=${DOXYGEN_IN}
                                      DOXYGEN_OUT=${DOXYGEN_OUT}
                                      # Call Doxygen
                                      ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Generating API documentation with Doxygen"
      VERBATIM)
   install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/docs DESTINATION ${CMAKE_INSTALL_PREFIX})
endif()

######################################
# SET PACKAGE AND DEPLOYMENT VARIABLES
######################################

if(WITH_GMF_CTEST)
   enable_testing()
   include_directories(${PROJECT_SOURCE_DIR}/testing)
   add_subdirectory(testing)
endif()

if (WITH_GMF_CPACK)
   include (InstallRequiredSystemLibraries)
   set (CPACK_GENERATOR TXZ)
   set (CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/copyright.txt)
   set (CPACK_PACKAGE_VERSION_MAJOR ${libMeshb_VERSION_MAJOR})
   set (CPACK_PACKAGE_VERSION_MINOR ${libMeshb_VERSION_MINOR})
   set (CPACK_COMPONENTS_ALL applications examples libraries headers)
   include (CPack)
endif ()


##################################
# EXPORT CMAKE PACKAGE INFORMATION
##################################

include(CMakePackageConfigHelpers)
file(WRITE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
"include(\${CMAKE_CURRENT_LIST_DIR}/meshb-target.cmake)
include(\${CMAKE_CURRENT_LIST_DIR}/libMeshb-target.cmake)
set(libMeshb_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include)
set(libMeshb_HELPERS_DIRS ${CMAKE_INSTALL_PREFIX}/helpers)
set(libMeshb_LINK_DIRS ${CMAKE_INSTALL_PREFIX}/lib)
set(libMeshb_LIBRARIES Meshb.8 ${AIO_LIBRARIES})
set(libMeshb_Fortran_LIBRARIES Meshbf.8 ${AIO_LIBRARIES})
set(libMeshb_FOUND TRUE)
")
write_basic_package_version_file(
   "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
   VERSION ${PROJECT_VERSION}
   COMPATIBILITY SameMajorVersion)
install(FILES
   "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
   "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
   DESTINATION lib/cmake/${PROJECT_NAME})


##################################
# PRINT OPERATIONS TO BE CONDUCTED
##################################

message("-- Build mode            : " ${CMAKE_BUILD_TYPE})
message("-- cpack target enabled  : " ${WITH_GMF_CPACK})
message("-- ctest target enabled  : " ${WITH_GMF_CTEST})
message("-- Asynchronous IO       : " ${WITH_GMF_AIO})
message("-- Install directory     : " ${CMAKE_INSTALL_PREFIX})
