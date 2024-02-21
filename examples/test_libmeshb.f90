
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
  
  integer(int64)          :: InpMsh, OutMsh, OutSol
  character(80)           :: InpFile
  character(80)           :: OutFile
  character(80)           :: SolFile
  integer(int32)          :: i
  integer(int32)          :: NmbVer,NmbQad,NmbTri,ver,dim,res,kwd
  integer(int32)          :: NmbField,fields(1:10),ho,s,d
  real(real64)  , pointer :: sol(:)
  real(real64)  , pointer :: VerTab(:,:)
  integer(int32), pointer :: VerRef(  :)
  integer(int32), pointer :: QadTab(:,:)
  integer(int32), pointer :: QadRef(  :)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"test_libmeshb_f90")'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  InpFile='../sample_meshes/quad.mesh'
  OutFile='./tri.meshb'
  SolFile='./tri.solb'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Open the quadrilateral mesh file for reading
  print '(/"Input  Mesh Open    : ",a )',trim(InpFile)
  
  ! Open the mesh file and check the version and dimension
  InpMsh = GmfOpenMeshf77(trim(InpFile),GmfRead,ver,dim)
  print '( "Input  Mesh Idx     : ",i0)',InpMsh
  print '( "Input  Mesh ver     : ",i0)',ver
  print '( "Input  Mesh dim     : ",i0)',dim
  
  if( InpMsh==0 ) stop ' InpMsh = 0'
  if( ver<=1    ) stop ' version <= 1'
  if( dim/=3    ) stop ' dimension <> 3'
  
  ! Read the vertices
  
  NmbVer = Gmfstatkwd(unit=InpMsh, GmfKey=GmfVertices)
  print '( "Input  Mesh NmbVer  : ",i0)', NmbVer
  allocate(VerTab(1:3,1:NmbVer))
  allocate(VerRef(    1:NmbVer))
  
  res = Gmfgotokwdf77(InpMsh, GmfVertices)
  do i=1,NmbVer
    res=GmfGetVertex(InpMsh, VerTab(1:3,i), VerRef(i))
  end do
  
  ! Read the quads
  
  NmbQad = Gmfstatkwd(unit=InpMsh, GmfKey=GmfQuadrilaterals)
  print '( "Input  Mesh NmbQad  : ",i0)', NmbQad
  allocate(QadTab(1:4,1:NmbQad))
  allocate(QadRef(    1:NmbQad))
  
  res=Gmfgotokwdf77(InpMsh, GmfQuadrilaterals)
  do i=1,NmbQad
    res=GmfGetElement(InpMsh, GmfQuadrilaterals, QadTab(1:4,i), QadRef(i))
  enddo
  
  ! Close the quadrilateral mesh
  res=GmfCloseMeshf77(InpMsh)
  print '("Input  Mesh Close   : ",a)',trim(InpFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Create a triangular mesh
  NmbTri=2*NmbQad
  
  print '(/"Output Mesh Open    : ",a )',trim(OutFile)
  OutMsh = GmfOpenMeshf77(trim(OutFile), GmfWrite, ver, dim)
  print '( "Output Mesh Idx     : ",i0)',InpMsh
  print '( "Output Mesh ver     : ",i0)',ver
  print '( "Output Mesh dim     : ",i0)',dim
  if( OutMsh==0 ) STOP ' OutMsh = 0'

  ! Set the number of vertices
  res=GmfSetKwd(OutMsh, GmfVertices, NmbVer)
  print '( "Output Mesh NmbVer  : ",i0)', NmbVer
  
  ! Then write them down
  do i=1,NmbVer
    res=GmfSetVertex(OutMsh, VerTab(1:3,i), VerRef(i))
  end do
  
  ! Write the triangles
  res = GmfSetKwd(OutMsh, GmfTriangles, 2*NmbQad)
  print '( "Output Mesh NmbTri  : ",i0)', NmbTri
  
  do i=1,NmbQad
    res=GmfSetElement(OutMsh, GmfTriangles, QadTab(1,i), QadRef(i))
    !     Modify the quad to build the other triangle's diagonal
    QadTab(2,i) = QadTab(3,i);
    QadTab(3,i) = QadTab(4,i);
    res=GmfSetElement(OutMsh, GmfTriangles, QadTab(1,i), QadRef(i))
  end do
  
  ! Don't forget to close the file
  res = GmfCloseMeshf77(OutMsh)
  print '("Output Mesh Close   : ",a)',trim(OutFile)  
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Create a solution file
  print '(/"Output Solu Open    : ",a )',trim(SolFile)
  
  OutSol = GmfOpenMeshf77(trim(SolFile), GmfWrite, ver, dim)
  print '( "Output Solu Idx     : ",i0)',OutSol
  print '( "Output Solu ver     : ",i0)',ver
  print '( "Output Solu dim     : ",i0)',dim
  if( OutSol==0 ) STOP ' OutSol = 0'
  
  ! Set the solution kinds
  NmbField=3
  fields(1:NmbField) = [GmfSca,GmfVec,GmfSca]
  allocate(sol(1:5)) !       1+   dim+     1
  print '( "Output Solu NmbVer  : ",i0)',NmbVer
  print '( "Output Solu nFields : ",i0)',NmbField
  print '( "Output Solu fields  : ", *(i0,1x))',fields(1:NmbField)
  
  ! Set the number of solutions (one per vertex)
  res = GmfSetKwd(OutSol, GmfSolAtVertices, NmbVer, NmbField, fields(1:NmbField), 0, ho)
  
  ! Write the dummy solution fields
  do i=1,NmbVer
    sol(  1)=VerTab(1,i)
    sol(2:4)=[VerTab(1,i),VerTab(2,i),0d0]
    sol(  5)=VerTab(2,i)
    res=GmfSetSolution(OutSol, GmfSolAtVertices, sol)
  enddo
  
  ! Don't forget to close the file
  res = GmfCloseMeshf77(OutSol)
  print '("Output Solu Close   : ",a)',trim(SolFile)    
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Cleanning Memory
  deallocate(VerTab,VerRef)
  deallocate(QadTab,QadRef)
  deallocate(sol)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> User Control
  print '(/"Control:"/"vizir4 -in ",a," -sol ",a/)',trim(OutFile),trim(SolFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
end program test_libmeshb_f90
