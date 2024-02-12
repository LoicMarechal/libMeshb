## Release 7.79

1. Complete rewrite of the Fortran API:
  - No more variable arguments procedures are used in Fortran as such feature is no more supported by gfortran
  - Addhoc procedures to handle a few keywords are provided
  - Users are encouraged to add their own !
