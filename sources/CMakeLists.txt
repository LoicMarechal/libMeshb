
##########################
# BUILD THE STATIC LIBRARY
##########################

add_library(Meshb.7 libmeshb7.c)
install (FILES libmeshb7.h DESTINATION include COMPONENT headers)
target_include_directories(Meshb.7 PUBLIC $<INSTALL_INTERFACE:include>)
install (TARGETS Meshb.7 EXPORT meshb-target DESTINATION lib COMPONENT libraries)
install(EXPORT meshb-target NAMESPACE ${PROJECT_NAME}::
        DESTINATION lib/cmake/${PROJECT_NAME})
install (TARGETS Meshb.7 EXPORT libMeshb-target DESTINATION lib COMPONENT libraries)
install (EXPORT libMeshb-target DESTINATION lib/cmake/${PROJECT_NAME})

####################################
# BUILD THE LIBRARY WITH FORTRAN API
####################################

add_library(Meshbf.7 libmeshb7.c)
target_compile_options (Meshbf.7 PRIVATE -DF77API)
install (FILES libmeshb7.ins DESTINATION include COMPONENT headers)
target_include_directories(Meshbf.7 PUBLIC $<INSTALL_INTERFACE:include>)
install (TARGETS Meshbf.7 EXPORT meshb-target DESTINATION lib COMPONENT libraries)
install(EXPORT meshb-target NAMESPACE ${PROJECT_NAME}::
        DESTINATION lib/cmake/${PROJECT_NAME})
install (TARGETS Meshbf.7 EXPORT libMeshb-target DESTINATION lib COMPONENT libraries)
install (EXPORT libMeshb-target DESTINATION lib/cmake/${PROJECT_NAME})
