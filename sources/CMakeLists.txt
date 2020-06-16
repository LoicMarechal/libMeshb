
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

#message("   CMAKE_BINARY_DIR               ${CMAKE_BINARY_DIR}"              )
#message("   CMAKE_CURRENT_BINARY_DIR       ${CMAKE_CURRENT_BINARY_DIR}"      )
#message("   CMAKE_CURRENT_SOURCE_DIR       ${CMAKE_CURRENT_SOURCE_DIR}"      )
#message("   CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}")

file(GLOB_RECURSE SOURCES *.[chfF] *.[fF]90)
#message("   SOURCES: ${SOURCES}")

add_library(Meshbf.7 STATIC ${SOURCES})
set_target_properties(Meshbf.7 PROPERTIES COMPILE_FLAGS "-DF77API")

target_include_directories(Meshbf.7
                           INTERFACE ${CMAKE_CURRENT_BINARY_DIR}
                           PRIVATE   ${CMAKE_CURRENT_BINARY_DIR}
                           PRIVATE   ${CMAKE_BINARY_DIR}
                           PUBLIC    ${CMAKE_SOURCE_DIR}
)


#install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ DESTINATION include)

install(FILES libmeshb7.ins DESTINATION include)


install(TARGETS Meshbf.7
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include
        ARCHIVE DESTINATION lib)


