
##########################
# BUILD THE STATIC LIBRARY
##########################

add_library(Meshb.7 libmeshb7.c ../utilities/libmeshb7_helpers.c)
install (FILES libmeshb7.h libmeshb7.ins ../utilities/libmeshb7_helpers.h DESTINATION include COMPONENT headers)
target_include_directories(
  Meshb.7 PUBLIC $<INSTALL_INTERFACE:include>
                 $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/sources>)
install (TARGETS Meshb.7 EXPORT meshb-target DESTINATION lib COMPONENT libraries)
install (EXPORT meshb-target NAMESPACE ${PROJECT_NAME}::
         DESTINATION lib/cmake/${PROJECT_NAME})
install (TARGETS Meshb.7 EXPORT libMeshb-target DESTINATION lib COMPONENT libraries)
install (EXPORT libMeshb-target DESTINATION lib/cmake/${PROJECT_NAME})
export  (PACKAGE libMeshb)
