
##################
# BUILD C EXAMPLES
##################

add_executable(test_libmeshb test_libmeshb.c)
target_link_libraries(test_libmeshb Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_libmeshb DESTINATION share/libMeshb/examples COMPONENT examples)

add_executable(test_libmeshb_block test_libmeshb_block.c)
target_link_libraries(test_libmeshb_block Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_libmeshb_block DESTINATION share/libMeshb/examples COMPONENT examples)

add_executable(test_libmeshb_sol test_libmeshb_sol.c)
target_link_libraries(test_libmeshb_sol Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_libmeshb_sol DESTINATION share/libMeshb/examples COMPONENT examples)

add_executable(test_libmeshb_HO test_libmeshb_HO.c)
target_link_libraries(test_libmeshb_HO Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_libmeshb_HO DESTINATION share/libMeshb/examples COMPONENT examples)

add_executable(test_libmeshb_p2_sol test_libmeshb_p2_sol.c)
target_link_libraries(test_libmeshb_p2_sol Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_libmeshb_p2_sol DESTINATION share/libMeshb/examples COMPONENT examples)

add_executable(test_polyhedra test_polyhedra.c ${PROJECT_SOURCE_DIR}/utilities/libmeshb8_helpers.c)
target_link_libraries(test_polyhedra Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_polyhedra DESTINATION share/libMeshb/examples COMPONENT examples)

add_executable(mesh2poly mesh2poly.c)
target_link_libraries(mesh2poly Meshb.8 ${AIO_LIBRARIES})
install (TARGETS mesh2poly DESTINATION share/libMeshb/examples COMPONENT examples)

if(LPlib_FOUND)
   add_executable(parallel_io parallel_io.c)
   target_link_libraries(parallel_io Meshb.8 ${AIO_LIBRARIES} ${LPlib_LIBRARIES})
   install (TARGETS parallel_io DESTINATION share/libMeshb/examples COMPONENT examples)
endif ()

add_executable(test_write_multiple_block test_write_multiple_block.c)
target_link_libraries(test_write_multiple_block Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_write_multiple_block DESTINATION share/libMeshb/examples COMPONENT examples)


add_executable(test_write_multiple_block_parallel test_write_multiple_block_parallel.c)
target_link_libraries(test_write_multiple_block_parallel Meshb.8 ${AIO_LIBRARIES})
install (TARGETS test_write_multiple_block_parallel DESTINATION share/libMeshb/examples COMPONENT examples)



########################
# BUILD FORTRAN EXAMPLES
########################


if (CMAKE_Fortran_COMPILER)
   add_executable(test_libmeshb_f77 test_libmeshb.f)
   target_link_libraries(test_libmeshb_f77 Meshb.8 ${AIO_LIBRARIES})
   install (TARGETS test_libmeshb_f77 DESTINATION share/libMeshb/examples COMPONENT examples)
   
   add_executable(test_libmeshb_f90 test_libmeshb.f90)
   target_link_libraries(test_libmeshb_f90 Meshb.8 ${AIO_LIBRARIES})
   install (TARGETS test_libmeshb_f90 DESTINATION share/libMeshb/examples COMPONENT examples)
   
   add_executable(test_libmeshb_block_f77 test_libmeshb_block.f)
   target_link_libraries(test_libmeshb_block_f77 Meshb.8 ${AIO_LIBRARIES})
   install (TARGETS test_libmeshb_block_f77 DESTINATION share/libMeshb/examples COMPONENT examples)
   
   add_executable(test_libmeshb_block01_f90 test_libmeshb_block01.f90)
   target_link_libraries(test_libmeshb_block01_f90 Meshb.8 ${AIO_LIBRARIES})
   install (TARGETS test_libmeshb_block01_f90 DESTINATION share/libMeshb/examples COMPONENT examples)

   add_executable(test_libmeshb_block02_f90 test_libmeshb_block02.f90)
   target_link_libraries(test_libmeshb_block02_f90 Meshb.8 ${AIO_LIBRARIES})
   install (TARGETS test_libmeshb_block02_f90 DESTINATION share/libMeshb/examples COMPONENT examples)
   
   add_executable(test_libmeshb_HO_f90 test_libmeshb_HO.f90)
   target_link_libraries(test_libmeshb_HO_f90 Meshb.8 ${AIO_LIBRARIES})
   install (TARGETS test_libmeshb_HO_f90 DESTINATION share/libMeshb/examples COMPONENT examples)


   #add_executable(test_libmeshb_block_bindC test_libmeshb_block_bindC.f90)
   #target_link_libraries(test_libmeshb_block_bindC Meshb.8 ${AIO_LIBRARIES})
   #install (TARGETS test_libmeshb_block_bindC DESTINATION share/libMeshb/examples COMPONENT examples)

endif ()
