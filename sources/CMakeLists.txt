
##########################
# BUILD THE STATIC LIBRARY
##########################

if(CMAKE_Fortran_COMPILER)
  add_library(Meshb.8 libmeshb8.c ../utilities/libmeshb8_helpers.c  libmeshb8_mod.f90)
else()
  add_library(Meshb.8 libmeshb8.c ../utilities/libmeshb8_helpers.c)
endif()

install (FILES libmeshb8.h libmeshb8.ins DESTINATION include COMPONENT headers)

target_include_directories(
  Meshb.8 PUBLIC $<INSTALL_INTERFACE:include>
                 $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/sources>)

install (TARGETS Meshb.8 EXPORT meshb-target DESTINATION lib COMPONENT libraries)

install (EXPORT meshb-target NAMESPACE ${PROJECT_NAME}::
         DESTINATION lib/cmake/${PROJECT_NAME})

install (TARGETS Meshb.8 EXPORT libMeshb-target DESTINATION lib COMPONENT libraries)

install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ DESTINATION include)

install (EXPORT libMeshb-target DESTINATION lib/cmake/${PROJECT_NAME})

export  (PACKAGE libMeshb)
