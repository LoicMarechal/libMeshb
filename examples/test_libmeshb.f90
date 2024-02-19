
! libMeshb 7.79 basic example:
! read a quad mesh, split it into triangles and write the result back
! write an associated dummy .sol file containing some data

program  test_libmeshb_f90
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  use libmeshb7
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  implicit none
  
  integer(8)            :: InpMsh, OutMsh
  character(80)         :: InpFile
  character(80)         :: OutFile
  integer               :: i
  integer               :: NmbVer,NmbQad,NmbTri,ver,dim,res,kwd
  integer               :: t(1:10),d,ho,s
  real(real64)          :: sol(1:10)
  real(real64), pointer :: VerTab(:,:)
  integer     , pointer :: VerRef(  :)
  integer     , pointer :: QadTab(:,:)
  integer     , pointer :: QadRef(  :)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"test_libmeshb_f90")'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  InpFile='../sample_meshes/quad.mesh'
  OutFile='./tri.meshb'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Open the quadrilateral mesh file for reading
  
  ! Open the mesh file and check the version and dimension
  InpMsh = GmfOpenMeshf77(trim(InpFile),GmfRead,ver,dim)
  print '(/"Input Mesh File: ",a," Idx=",i0," version: ",i0," dim: ",i0)',trim(InpFile),InpMsh,ver,dim
  if( InpMsh==0) stop ' InpMsh = 0'
  if( ver<=1   ) stop ' version <= 1'
  if( dim/=3   ) stop ' dimension <> 3'
  
  ! Allocate VerTab and VerRef
  NmbVer = Gmfstatkwdf77(InpMsh, GmfVertices, 0, s, t, d, ho)
  allocate(VerTab(1:3,1:NmbVer))
  allocate(VerRef(    1:NmbVer))
  
  ! Allocate QadTab and QadRef
  NmbQad=Gmfstatkwdf77(InpMsh, GmfQuadrilaterals, 0, s, t, d, ho)  
  allocate(QadTab(1:4,1:NmbQad))
  allocate(QadRef(    1:NmbQad))
  
  print '("Input mesh : ",i0," vertices: ",i0," quads")',NmbVer,NmbQad
  
  ! Read the quads
  res=Gmfgotokwdf77(InpMsh, GmfQuadrilaterals)
  do i=1,NmbQad
    res=GmfGetElement(InpMsh, GmfQuadrilaterals, QadTab(1:4,i), QadRef(i))
  enddo
  
  ! Read the vertices
  res = Gmfgotokwdf77(InpMsh, GmfVertices)
  do i=1,NmbVer
    res=GmfGetVertex(InpMsh, VerTab(1:3,i), VerRef(i))
  end do
  
  ! Close the quadrilateral mesh
  res=GmfCloseMeshf77(InpMsh)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Create a triangular mesh
  NmbTri=2*NmbQad
  
  OutMsh = GmfOpenMeshf77(trim(OutFile), GmfWrite, ver, dim)
  print '(/"Output Mesh File: ",a," Idx=",i0," version: ",i0," dim: ",i0)',trim(OutFile),OutMsh,ver,dim
  print '( "vertices  : ",i0)', NmbVer
  print '( "triangles : ",i0)', NmbTri
  if(OutMsh==0) STOP ' OutMsh = 0'
  
  ! Set the number of vertices
  res=GmfSetKwdf77(OutMsh, GmfVertices, NmbVer, 0, t, 0, ho)
  
  ! Then write them down
  do i=1,NmbVer
    res=GmfSetVertex(OutMsh, VerTab(1:3,i), VerRef(i))
  end do
  
  ! Write the triangles
  res = Gmfsetkwdf77(OutMsh, GmfTriangles, 2*NmbQad, 0, t, 0, ho)
  do i=1,NmbQad
    res=GmfSetElement(OutMsh, GmfTriangles, QadTab(1,i), QadRef(i))
    !     Modify the quad to build the other triangle's diagonal
    QadTab(2,i) = QadTab(3,i);
    QadTab(3,i) = QadTab(4,i);
    res=GmfSetElement(OutMsh, GmfTriangles, QadTab(1,i), QadRef(i))
  end do
  
  ! Don't forget to close the file
  res = GmfCloseMeshf77(OutMsh)
  
  
  print '("output mesh: ",i0," vertices: ",i0," triangles")',NmbVer,2*NmbQad
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Cleanning Memory
  deallocate(VerTab,VerRef)
  deallocate(QadTab,QadRef)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Create a solution file
  
  OutMsh = GmfOpenMeshf77('tri.sol', GmfWrite, 2, 3)
  if(OutMsh==0) STOP ' OutMsh = 0'
  print '("output IDX: ",i0)',OutMsh
  
  ! Set the solution kinds
  t(1:3) = [GmfSca,GmfVec,GmfSca]
  
  ! Set the number of solutions (one per vertex)
  res = Gmfsetkwdf77(OutMsh, GmfSolAtVertices, NmbVer, 3, t, 0, ho)
  
  ! Write the dummy solution fields
  do i = 1, NmbVer
    sol(1:4) = [i,2*i,3*i,4*i]
    sol(5) = -i
    res = Gmfsetsolution(OutMsh, GmfSolAtVertices, sol)
  end do

  ! Don't forget to close the file
  res = GmfCloseMeshf77(OutMsh)
  
  print '("output sol: ",i0," solutions")',NmbVer
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"vizir4 -in ",a," -sol tri.sol")',trim(OutFile)
  print '(/"test_libmeshb_f90")'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


end program test_libmeshb_f90
