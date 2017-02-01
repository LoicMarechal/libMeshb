
##########################
# BUILD THE STATIC LIBRARY
##########################

add_library(Meshb.7 libmeshb7.c)
install (FILES libmeshb7.h DESTINATION include COMPONENT headers)
if (CMAKE_MAJOR_VERSION GREATER "2")
  target_include_directories(Meshb.7 PUBLIC $<INSTALL_INTERFACE:include>)
  install (TARGETS Meshb.7 EXPORT meshb-target DESTINATION lib COMPONENT libraries)
  install(EXPORT meshb-target NAMESPACE ${PROJECT_NAME}::
          DESTINATION lib/cmake/${PROJECT_NAME})
else()
  install (TARGETS Meshb.7 DESTINATION lib COMPONENT libraries)
endif()

####################################
# BUILD THE LIBRARY WITH FORTRAN API
####################################

add_library(Meshbf.7 libmeshb7.c)
target_compile_options (Meshbf.7 PRIVATE -DF77API)
install (TARGETS Meshbf.7 DESTINATION lib COMPONENT libraries)
install (FILES libmeshb7.ins DESTINATION include COMPONENT headers)
