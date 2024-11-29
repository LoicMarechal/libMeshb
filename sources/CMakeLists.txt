
##########################
# BUILD THE STATIC LIBRARY
##########################

if(CMAKE_Fortran_COMPILER)
  add_library(Meshb.7 libmeshb7.c ../utilities/libmeshb7_helpers.c  libmeshb7_mod.f90)
else()
  add_library(Meshb.7 libmeshb7.c ../utilities/libmeshb7_helpers.c)
endif()

install (FILES libmeshb7.h libmeshb7.ins DESTINATION include COMPONENT headers)

target_include_directories(
  Meshb.7 PUBLIC $<INSTALL_INTERFACE:include>
                 $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/sources>)

install (TARGETS Meshb.7 EXPORT meshb-target DESTINATION lib COMPONENT libraries)

install (EXPORT meshb-target NAMESPACE ${PROJECT_NAME}::
         DESTINATION lib/cmake/${PROJECT_NAME})

install (TARGETS Meshb.7 EXPORT libMeshb-target DESTINATION lib COMPONENT libraries)

install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ DESTINATION include)

install (EXPORT libMeshb-target DESTINATION lib/cmake/${PROJECT_NAME})

export  (PACKAGE libMeshb)
