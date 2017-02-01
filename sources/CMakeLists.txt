
##########################
# BUILD THE STATIC LIBRARY
##########################

add_library(Meshb.7 libmeshb7.c)
install (TARGETS Meshb.7 DESTINATION lib COMPONENT libraries)
install (FILES libmeshb7.h DESTINATION include COMPONENT headers)


####################################
# BUILD THE LIBRARY WITH FORTRAN API
####################################

add_library(Meshbf.7 libmeshb7.c)
target_compile_options (Meshbf.7 PRIVATE -DF77API)
install (TARGETS Meshbf.7 DESTINATION lib COMPONENT libraries)
install (FILES libmeshb7.ins DESTINATION include COMPONENT headers)
