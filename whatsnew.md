## Release 7.80

1. Complete rewrite of the Fortran API:
  - No more variable arguments procedures are used in Fortran as such feature is no more supported by gfortran.
  - Line-based read and write go through three tables: one that stores all INTEGER4 values, one for REAL8 and an INTEGER4 scalar to store the reference.
  - Block based access use the same data structures but each table is duplicated: one to store pointers to the first entities and the other one to store pointers to the last entities. This way, the procedure is able to compute the byte stride and store the mesh file data directly to or from the user's data structures.