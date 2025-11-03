

################
# RUN C EXAMPLES
################

add_test(NAME test_libmeshb
         COMMAND test_libmeshb
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

add_test(NAME test_libmeshb_HO
         COMMAND test_libmeshb_HO
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

add_test(NAME test_libmeshb_block
         COMMAND test_libmeshb_block
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

add_test(NAME preprocessing_pipeline
         COMMAND preprocessing_pipeline
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

add_test(NAME test_libmeshb_p2_sol
         COMMAND test_libmeshb_p2_sol
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

add_test(NAME test_polyhedra
         COMMAND test_polyhedra
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

add_test(NAME test_libmeshb_sol
         COMMAND test_libmeshb_sol
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

add_test(NAME mesh2poly
         COMMAND mesh2poly ../sample_meshes/quad.mesh poly.mesh
         WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")


######################
# RUN FORTRAN EXAMPLES
######################

if (CMAKE_Fortran_COMPILER)
   add_test(NAME test_libmeshb_f77
            COMMAND test_libmeshb_f77
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

   add_test(NAME test_libmeshb_f90
            COMMAND test_libmeshb_f90
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

   add_test(NAME test_libmeshb_block_f77
            COMMAND test_libmeshb_block_f77
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

   add_test(NAME test_libmeshb_block01_f90
            COMMAND test_libmeshb_block01_f90
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

   add_test(NAME test_libmeshb_block02_f90
            COMMAND test_libmeshb_block02_f90
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")

   add_test(NAME test_libmeshb_HO_f90
            COMMAND test_libmeshb_HO_f90
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/examples")
endif ()
