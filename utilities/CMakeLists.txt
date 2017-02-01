
#################
# BUILD UTILITIES
#################

add_executable(transmesh transmesh.c ../sources/libmeshb7.c)
target_compile_options (transmesh PRIVATE -DTRANSMESH)
install (TARGETS transmesh DESTINATION bin COMPONENT applications)
