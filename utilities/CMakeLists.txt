
#################
# BUILD UTILITIES
#################

add_executable(transmesh transmesh.c ../sources/libmeshb7.c)
target_compile_options (transmesh PRIVATE -DTRANSMESH)
target_link_libraries (transmesh Meshb.7 ${AIO_LIBRARIES})
install (TARGETS transmesh DESTINATION bin COMPONENT applications)
