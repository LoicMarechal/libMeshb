
! libMeshb 7.79 example: transform a quadrilateral mesh into a triangular one
! using fast block transfer

program test_libmeshb_block_f90
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  use libmeshb7
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  implicit none
  integer(8)            :: InpMsh, OutMsh, m(1)
  character(80)         :: InpFile
  character(80)         :: OutFile
  character(80)         :: SolFile
  integer               :: i
  integer               :: NmbVer,NmbQad,NmbTri,ver,dim,res
  real(real64)          :: sol(1:10)
  real(real64), pointer :: VerTab(:,:)
  integer     , pointer :: VerRef(  :)
  integer     , pointer :: QadTab(:,:),QadRef(  :)
  integer     , pointer :: TriTab(:,:),TriRef(  :)
  integer               :: t(1),d,ho,s
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"test_libmeshb_block_f90")'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  InpFile='../sample_meshes/quad.mesh'
  OutFile='./tri.mesh'
  SolFile='./tri.sol'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Open the quadrilateral mesh file for reading
  print '(/"Input  Mesh Open    : ",a )',trim(InpFile)
  
  ! Open the mesh file and check the version and dimension
  InpMsh = GmfOpenMeshf77(trim(InpFile),GmfRead,ver,dim)
  print '( "Input  Mesh Idx     : ",i0)',InpMsh
  print '( "Input  Mesh ver     : ",i0)',ver
  print '( "Input  Mesh dim     : ",i0)',dim
  
  ! Allocate VerRef
  NmbVer = GmfStatKwd(InpMsh, GmfVertices)
  print '( "Input  Mesh NmbVer  : ",i0)', NmbVer
  allocate(VerTab(1:3,1:NmbVer))
  allocate(VerRef(    1:NmbVer))
    
  ! Read the vertices using a vector of 3 consecutive doubles to store the coordinates
  res=GmfGetVertices(                &
  &   InpMsh                        ,&
  &   1                             ,&
  &   NmbVer                        ,&
  &   0, m                          ,&
  &   VerTab(1,1), VerTab(1,NmbVer) ,&
  &   VerRef(  1), VerRef(  NmbVer)  )
  
  ! Allocate QadTab
  NmbQad=GmfStatKwd(InpMsh, GmfQuadrilaterals)
  print '( "Input  Mesh NmbQad  : ",i0)', NmbQad
  allocate(QadTab(1:4,1:NmbQad))
  allocate(QadRef(    1:NmbQad))  
  
  ! Read the quads using one single vector of 4 consecutive integers
  
  res=GmfGetElements(                &
  &   InpMsh                        ,&
  &   GmfQuadrilaterals             ,&
  &   1                             ,&
  &   NmbQad                        ,&
  &   0, m                          ,&
  &   QadTab(1,1), QadTab(1,NmbQad) ,&
  &   QadRef(  1), QadRef(  NmbQad)  )
  
  !!> Lecture par tableau 1D sans recopie
  !block 
  !  use iso_c_binding, only: c_loc,c_f_pointer
  !  integer     , pointer :: nodes(:)
  !  
  !  call c_f_pointer(cptr=c_loc(QadTab), fptr=nodes, shape=[4*NmbQad]) !> binding QadTab(:,:) and nodes(:)
  !  
  !  res=GmfGetElements(                &
  !  &   InpMsh                        ,&
  !  &   GmfQuadrilaterals             ,&
  !  &   1                             ,&
  !  &   NmbQad                        ,&
  !  &   0, m                          ,&
  !  &   nodes(   1), nodes(4*NmbQad-3),&
  !  &   QadRef(  1), QadRef(NmbQad)    )
  !end block
  
  ! Close the quadrilateral mesh
  res=GmfCloseMeshf77(InpMsh)
  print '("Input  Mesh Close   : ",a)',trim(InpFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Allocate TriTab and TriRef
  NmbTri=2*NmbQad
  allocate(TriTab(1:3,1:NmbTri))
  allocate(TriRef(    1:NmbTri))
  
  ! Convert the quad mesh into a triangular one
  do i=1,NmbTri
    if(mod(i,2) .EQ. 1) then
      TriTab(1,i) = QadTab(1,(i+1)/2)
      TriTab(2,i) = QadTab(2,(i+1)/2)
      TriTab(3,i) = QadTab(3,(i+1)/2)
      TriRef(  i) = QadRef(  (i+1)/2)
    else
      TriTab(1,i) = QadTab(1,(i+1)/2)
      TriTab(2,i) = QadTab(3,(i+1)/2)
      TriTab(3,i) = QadTab(4,(i+1)/2)
      TriRef(  i) = QadRef(  (i+1)/2)
    endif
  end do
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Write a triangular mesh
  print '(/"Output Mesh Open    : ",a )',trim(OutFile)
  
  OutMsh = GmfOpenMeshf77(trim(OutFile), GmfWrite, ver, dim)
  print '( "Output Mesh Idx     : ",i0)',InpMsh
  print '( "Output Mesh ver     : ",i0)',ver
  print '( "Output Mesh dim     : ",i0)',dim
  if(OutMsh==0) STOP ' OutMsh = 0'
  
  ! Set the number of vertices
  res=GmfSetKwd(OutMsh, GmfVertices, NmbVer)
  print '( "Output Mesh NmbVer  : ",i0)', NmbVer
  
  ! Write them down using separate pointers for each scalar entry
  res=GmfSetVertices(               &
  &   OutMsh                       ,&
  &   1                            ,&
  &   NmbVer                       ,&
  &   0, m                         ,&
  &   VerTab(1,1), VerTab(1,NmbVer),&
  &   VerRef(  1), VerRef(  NmbVer) )
  
  ! Write the triangles using 4 independant set of arguments 
  ! for each scalar entry: node1, node2, node3 and reference
  res=GmfSetKwd(OutMsh, GmfTriangles, NmbTri)
  print '( "Output Mesh NmbTri  : ",i0)', NmbTri
  
  res = GmfSetElements(               &
  &     OutMsh                       ,&
  &     GmfTriangles                 ,&
  &     1                            ,&
  &     NmbTri                       ,&
  &     0, m                         ,&
  &     TriTab(1,1), TriTab(1,NmbTri),&
  &     TriRef(  1), TriRef(  NmbTri) )
  
  !!> Ecriture par tableau 1D sans recopie
  !block 
  !  use iso_c_binding, only: c_loc,c_f_pointer
  !  integer     , pointer :: nodes(:)
  !  
  !  print '(/"binding TriTab(:,:) and nodes(:)")'
  !  
  !  call c_f_pointer(cptr=c_loc(TriTab), fptr=nodes, shape=[3*NmbTri]) !> binding TriTab(:,:) and nodes(:)
  !  
  !  print '(/"Triangle: ",i6)',1
  !  print '( "TriTab:",3(i6,1x) )',TriTab(1,1),TriTab(2,1),TriTab(3,1)
  !  print '( "nodes: ",3(i6,1x)/)',nodes(1),nodes(2),nodes(3)
  !  print '(/"Triangle: ",i6)',NmbTri
  !  print '( "TriTab:",3(i6,1x) )',TriTab(1,NmbTri),TriTab(2,NmbTri),TriTab(3,NmbTri)
  !  print '( "nodes: ",3(i6,1x)/)',nodes(3*NmbTri-2),nodes(3*NmbTri-1),nodes(3*NmbTri)
  !  
  !  res=GmfSetElements(                &
  !  &   InpMsh                        ,&
  !  &   GmfTriangles                  ,&
  !  &   1                             ,&
  !  &   NmbTri                        ,&
  !  &   0, m                          ,&
  !  &   nodes(   1), nodes(3*NmbTri-2),&
  !  &   TriRef(  1), TriRef(NmbTri)    )
  !  
  !end block

  ! Don't forget to close the file
  res=GmfCloseMeshf77(OutMsh)
  print '("Output Mesh Close   : ",a)',trim(OutFile)  
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Cleanning Memory
  deallocate(VerTab,VerRef)
  deallocate(QadTab,QadRef)
  deallocate(TriTab,TriRef)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"Constrol"/"vizir4 -in ",a/)',trim(OutFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
end program test_libmeshb_block_f90

