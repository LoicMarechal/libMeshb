! libMeshb 8.0 example: transform a quadrilateral mesh into a triangular one
! using fast block transfer

! test_libmeshb_block02_f90
! Version with this shapes:
!   VerTab(:,:),VerRef(:)
!   QadTab(:,:),QadRef(:)
!   TriTab(:,:),TriRef(:)
!   solTab(:,:)

program test_libmeshb_block02_f90
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  use libmeshb8
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  implicit none
  integer(int64)          :: InpMsh, OutMsh, OutSol
  character(80)           :: InpFile
  character(80)           :: OutFile
  character(80)           :: SolFile
  integer(int32)          :: i
  integer(int32)          :: NmbVer,NmbQad,NmbTri,ver,dim,res
  real(real64)  , pointer :: VerTab(:,:)
  integer(int32), pointer :: VerRef(  :)
  integer(int32), pointer :: QadTab(:,:),QadRef(  :)
  integer(int32), pointer :: TriTab(:,:),TriRef(  :)
  integer(int32)          :: NmbFields,ho,s,d
  integer(int32), pointer :: fields(:)
  character(32) , pointer :: fieldNames(:)=>null()
  real(real64)  , pointer :: solTab(:,:)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"test_libmeshb_block02_f90")'
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
  InpMsh=GmfOpenMeshF90(name=trim(InpFile),GmfKey=GmfRead,ver=ver,dim=dim)
  
  print '( "Input  Mesh Idx     : ",i0)',InpMsh
  print '( "Input  Mesh ver     : ",i0)',ver
  print '( "Input  Mesh dim     : ",i0)',dim
  
  ! Allocate VerRef
  NmbVer = GmfstatkwdF90(unit=InpMsh, GmfKey=GmfVertices)
  print '( "Input  Mesh NmbVer  : ",i0)', NmbVer
  allocate(VerTab(1:3,1:NmbVer))
  allocate(VerRef(    1:NmbVer))
  
  ! Read the vertices using a vector of 3 consecutive doubles to store the coordinates  
  res=GmfGetBlockF90(         &
  &   unit=InpMsh            ,&
  &   GmfKey=GmfVertices     ,&
  &   ad0=1                  ,&
  &   ad1=NmbVer             ,&
  &   Tab=VerTab(:,1:NmbVer) ,&
  &   Ref=VerRef(  1:NmbVer)  )
  
  !do i=1,10
  !  print '(3x,"ver",i6," xyz:",3(f12.5,1x)," ref: ",i0)',i,VerTab(1:3,i),VerRef(i)
  !enddo
  
  ! Allocate QadTab
  NmbQad=GmfstatkwdF90(unit=InpMsh, GmfKey=GmfQuadrilaterals)
  print '( "Input  Mesh NmbQad  : ",i0)', NmbQad
  allocate(QadTab(1:4,1:NmbQad))
  allocate(QadRef(    1:NmbQad))  
  
  ! Read the quads using one single vector of 4 consecutive integers  
  res=GmfGetBlockF90(          &
  &   unit=InpMsh             ,&
  &   GmfKey=GmfQuadrilaterals,&
  &   ad0=1                   ,&
  &   ad1=NmbQad              ,&
  &   Tab=QadTab(:,1:)        ,&
  &   Ref=QadRef(  1:)         )
  
  !do i=1,10
  !  print '(3x,"qad",i6," nd:",4(i6,1x)," ref: ",i0)',i,QadTab(1:4,i),QadRef(i)
  !enddo
    
  ! Close the quadrilateral mesh
  res=GmfCloseMeshF90(unit=InpMsh)
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
  
  OutMsh=GmfOpenMeshF90(name=trim(OutFile),GmfKey=GmfWrite,ver=ver,dim=dim)
  
  print '( "Output Mesh Idx     : ",i0)',InpMsh
  print '( "Output Mesh ver     : ",i0)',ver
  print '( "Output Mesh dim     : ",i0)',dim
  if(OutMsh==0) STOP ' OutMsh = 0'
  
  ! Set the number of vertices
  res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfVertices, Nmb=NmbVer)
  print '( "Output Mesh NmbVer  : ",i0)', NmbVer
  
  ! Write them down using separate pointers for each scalar entry  
  res=GmfSetBlockF90(        &
  &   unit=OutMsh           ,&
  &   GmfKey=GmfVertices    ,&
  &   ad0=1                 ,&
  &   ad1=NmbVer            ,&
  &   Tab=VerTab(:,1:NmbVer),&
  &   Ref=VerRef(  1:NmbVer) )
  
  ! Write the triangles using 4 independant set of arguments 
  ! for each scalar entry: node1, node2, node3 and reference
  res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfTriangles, Nmb=NmbTri)
  print '( "Output Mesh NmbTri  : ",i0)', NmbTri
  
  res=GmfSetBlockF90(        &
  &   unit=OutMsh           ,&
  &   GmfKey=GmfTriangles   ,&
  &   ad0=1                 ,&
  &   ad1=NmbTri            ,&
  &   Tab=TriTab(:,1:NmbTri),&
  &   Ref=TriRef(  1:NmbVer) )
  
  ! Don't forget to close the file
  res=GmfCloseMeshF90(unit=OutMsh)
  print '("Output Mesh Close   : ",a)',trim(OutFile)  
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Create a solution file
  
  print '(/"Output Solu Open    : ",a )',trim(SolFile)
  
  OutSol=GmfOpenMeshF90(name=trim(SolFile),GmfKey=GmfWrite,ver=ver,dim=dim)
  
  print '( "Output Solu Idx     : ",i0)',OutSol
  print '( "Output Solu ver     : ",i0)',ver
  print '( "Output Solu dim     : ",i0)',dim
  if( OutSol==0 ) STOP ' OutSol = 0'
  
  ! Set the solution kinds
  NmbFields=3
  allocate(fields    (1:NmbFields))
  allocate(fieldNames(1:NmbFields))
  fields(1:NmbFields) = [GmfSca,GmfVec,GmfSca]  
  fieldNames(1:NmbFields)=['sca_1','vec_1','sca_2']
  
  allocate(solTab(1:5,NmbVer)) !  =1+dim+1
  print '( "Output Solu NmbVer  : ",i0)',NmbVer
  print '( "Output Solu nFields : ",i0)',NmbFields
  print '( "Output Solu fields  : ", *(i0,1x))',fields(1:NmbFields)
  print '( "Output Solu fields  : ", *(a,1x))',fieldNames(1:NmbFields)
  
  ! Set the number of solutions (one per vertex)
  res=GmfSetKwdF90(unit=OutSol, GmfKey=GmfSolAtVertices, Nmb=NmbVer, NmbFields=NmbFields, fields=fields(1:NmbFields))
  
  ! Compute the dummy solution fields
  do i=1,NmbVer
    solTab(  1,i)=VerTab(1,i)
    solTab(2:4,i)=[VerTab(1,i),VerTab(2,i),0d0]
    solTab(  5,i)=VerTab(2,i)
  enddo
  
  res=GmfSetKwdF90(                      &
  &   unit=OutSol                       ,&
  &   GmfKey=GmfSolAtVertices           ,&
  &   Nmb=NmbVer                        ,&
  &   NmbFields=NmbFields               ,&
  &   fields=fields(1:NmbFields)        ,&
  &   fieldNames=fieldNames(1:NmbFields),&  ! <= optional
  &   iter=10                           ,&  ! <= optional
  &   time=60d0                          )  ! <= optional

  res=GmfSetBlockF90(                    &
  &   unit=OutMsh                       ,&
  &   GmfKey=GmfSolAtVertices           ,&
  &   ad0=1                             ,&
  &   ad1=NmbVer                        ,&
  &   Tab=solTab(1:,:)                   )


  ! Don't forget to close the file
  res=GmfCloseMeshF90(unit=OutSol)
  print '("Output Solu Close   : ",a)',trim(SolFile)    
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Cleanning Memory
  deallocate(VerTab,VerRef)
  deallocate(QadTab,QadRef)
  deallocate(TriTab,TriRef)
  deallocate(solTab)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"Constrol"/"vizir4 -in ",a," -sol ",a,/)',trim(OutFile),trim(SolFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
end program test_libmeshb_block02_f90