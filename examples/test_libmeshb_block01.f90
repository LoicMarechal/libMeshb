! libMeshb 7.79 example: transform a quadrilateral mesh into a triangular one
! using fast block transfer

! test_libmeshb_block01_f90
! Version with this shapes:
!   VerTab(:),VerRef(:)
!   QadTab(:),QadRef(:)
!   TriTab(:),TriRef(:)
!   solTab(:)

program test_libmeshb_block01_f90
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
  integer(int32)          :: iVer,NmbVer,NmbQad,iTri,NmbTri,ver,dim,res,strd
  real(real64)  , pointer :: VerTab(:)
  integer(int32), pointer :: VerRef(:)
  integer(int32), pointer :: QadTab(:),QadRef(:)
  integer(int32), pointer :: TriTab(:),TriRef(:)
  integer(int32)          :: iSol,NmbFields,ho,s,d
  integer(int32), pointer :: fields(:)
  character(32) , pointer :: fieldsName(:)=>null()
  real(real64)  , pointer :: solTab(:)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  print '(/"test_libmeshb_block01_f90")'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  InpFile='../sample_meshes/quad.mesh'
  OutFile='./tri.meshb'
  SolFile='./tri.solb'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Open the quadrilateral mesh file for reading
  print '(/"Input  Mesh Open         : ",a )',trim(InpFile)
  
  ! Open the mesh file and check the version and dimension
  InpMsh=GmfOpenMeshF90(name=trim(InpFile),GmfKey=GmfRead,ver=ver,dim=dim)
  
  print '( "Input  Mesh Idx          : ",i0)',InpMsh
  print '( "Input  Mesh ver          : ",i0)',ver
  print '( "Input  Mesh dim          : ",i0)',dim
  
  ! Allocate VerRef
  strd=3
  NmbVer = GmfstatkwdF90(unit=InpMsh, GmfKey=GmfVertices)
  print '( "Input  Mesh strd x NmbVer: ",i0,"x",i0)', strd, NmbVer
  allocate(VerTab(1:strd*NmbVer))
  allocate(VerRef(1:     NmbVer))
  
  ! Read the vertices using a vector of 3 consecutive doubles to store the coordinates  
  res=GmfGetBlockF90(     &
  &   unit=InpMsh        ,&
  &   GmfKey=GmfVertices ,&
  &   ad0=1              ,&
  &   ad1=NmbVer         ,&
  &   strd=strd          ,&  !<= add stride when using Tab(:)
  &   Tab=VerTab(1:)     ,&
  &   Ref=VerRef(1:)      )
  
  !do i=1,10
  !  iVer=strd*(i-1)
  !  print '(3x,"ver",i6," xyz:",3(f12.5,1x)," ref: ",i0)',i,VerTab( iVer+1:iVer+strd),VerRef(i)
  !enddo
  
  ! Allocate QadTab
  strd=4
  NmbQad=GmfstatkwdF90(unit=InpMsh, GmfKey=GmfQuadrilaterals)
  print '( "Input  Mesh strd x NmbQad: ",i0,"x",i0)', strd,NmbQad
  allocate(QadTab(1:strd*NmbQad))
  allocate(QadRef(1:     NmbQad))  
  
  ! Read the quads using one single vector of 4 consecutive integers  
  res=GmfGetBlockF90(           &
  &   unit=InpMsh              ,&
  &   GmfKey=GmfQuadrilaterals ,&
  &   ad0=1                    ,&
  &   ad1=NmbQad               ,&
  &   strd=strd                ,& !<= add stride when using Tab(:)
  &   Tab=QadTab(1:)           ,&
  &   Ref=QadRef(1:)            )
  
  !do i=1,10
  !  print '(3x,"qad",i6," nd:",4(i6,1x)," ref: ",i0)',i,QadTab( strd*(i-1)+1:strd*i),QadRef(i)
  !enddo
    
  ! Close the quadrilateral mesh
  res=GmfCloseMeshF90(unit=InpMsh)
  print '("Input  Mesh Close         : ",a)',trim(InpFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Allocate TriTab and TriRef
  strd=3
  NmbTri=2*NmbQad
  allocate(TriTab(1:strd*NmbTri))
  allocate(TriRef(1:     NmbTri))
  
  ! Convert the quad mesh into a triangular one
  do i=1,NmbQad
    iTri=2*i-1
    TriTab( strd*(iTri-1)+1 ) = QadTab( 4*(i-1)+1 )
    TriTab( strd*(iTri-1)+2 ) = QadTab( 4*(i-1)+2 )
    TriTab( strd*(iTri-1)+3 ) = QadTab( 4*(i-1)+3 )
    TriRef(       iTri      ) = QadRef(    i      )
    
    iTri=2*i
    TriTab( strd*(iTri-1)+1 ) = QadTab( 4*(i-1)+1 )
    TriTab( strd*(iTri-1)+2 ) = QadTab( 4*(i-1)+3 )
    TriTab( strd*(iTri-1)+3 ) = QadTab( 4*(i-1)+4 )
    TriRef(       iTri      ) = QadRef(    i      )
  end do
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Write a triangular mesh
  print '(/"Output Mesh Open         : ",a )',trim(OutFile)
  
  OutMsh=GmfOpenMeshF90(name=trim(OutFile),GmfKey=GmfWrite,ver=ver,dim=dim)
  
  print '( "Output Mesh Idx          : ",i0)',InpMsh
  print '( "Output Mesh ver          : ",i0)',ver
  print '( "Output Mesh dim          : ",i0)',dim
  if(OutMsh==0) STOP ' OutMsh = 0'
  
  ! Set the number of vertices
  strd=3
  res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfVertices, Nmb=NmbVer)
  print '( "Output Mesh strd x NmbVer: ",i0,"x",i0)', strd, NmbVer
  
  ! Write them down using separate pointers for each scalar entry  
  res=GmfSetBlockF90(        &
  &   unit=OutMsh           ,&
  &   GmfKey=GmfVertices    ,&
  &   ad0=1                 ,&
  &   strd=3                ,& !<= add stride when using Tab(:)
  &   ad1=NmbVer            ,&
  &   Tab=VerTab(1:)        ,&
  &   Ref=VerRef(1:)         )
  
  ! Write the triangles using 4 independant set of arguments 
  ! for each scalar entry: node1, node2, node3 and reference
  res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfTriangles, Nmb=NmbTri)
  print '( "Output Mesh strd x NmbTri: ",i0,"x",i0)', strd, NmbTri
  
  res=GmfSetBlockF90(        &
  &   unit=OutMsh           ,&
  &   GmfKey=GmfTriangles   ,&
  &   ad0=1                 ,&
  &   ad1=NmbTri            ,&
  &   strd=3                ,& !<= add stride when using Tab(:)
  &   Tab=TriTab(1:)        ,&
  &   Ref=TriRef(1:)         )
    
  ! Don't forget to close the file
  res=GmfCloseMeshF90(unit=OutMsh)
  print '( "Output Mesh Close        : ",a)',trim(OutFile)  
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Create a solution file
  
  print '(/"Output Solu Open         : ",a )',trim(SolFile)
  
  OutSol=GmfOpenMeshF90(name=trim(SolFile),GmfKey=GmfWrite,ver=ver,dim=dim)
  
  print '( "Output Solu Idx          : ",i0)',OutSol
  print '( "Output Solu ver          : ",i0)',ver
  print '( "Output Solu dim          : ",i0)',dim
  if( OutSol==0 ) STOP ' OutSol = 0'
  
  ! Set the solution kinds
  strd=5
  NmbFields=3
  allocate( fields    (1:NmbFields))
  allocate( fieldsName(1:NmbFields))
  fields(1:NmbFields) = [GmfSca,GmfVec,GmfSca]  
  fieldsName(1:NmbFields)=['sca_1','vec_1','sca_2']
  
  ! Write iteration number in file
  res=GmfSetKwdF90 (unit=OutSol, GmfKey=GmfIterations, Nmb=1 )
  res=GmfSetLineF90(unit=OutSol, GmfKey=GmfIterations, Tab=int(10,kind=int32)) ! number of iteration (example 10)  
  
  allocate(solTab(1:strd*NmbVer))
  print '( "Output Solu strd x NmbVer: ",i0,"x",i0)', strd, NmbVer
  print '( "Output Solu nFields      : ",i0)',NmbFields
  print '( "Output Solu fields       : ", *(i0,1x))',fields(1:NmbFields)
  
  ! Set the number of solutions (one per vertex)
  res=GmfSetKwdF90(                      &
  &   unit=OutSol                       ,&
  &   GmfKey=GmfSolAtVertices           ,&
  &   Nmb=NmbVer                        ,&
  &   NmbFields=NmbFields               ,&
  &   fields=fields(1:NmbFields)        ,&
  &   fieldsName=fieldsName(1:NmbFields),&  ! <= optional
  &   iter=10                           ,&  ! <= optional
  &   time=60d0                          )  ! <= optional

  ! Compute the dummy solution fields
  do i=1,NmbVer
    iSol=strd*(i-1)
    solTab(iSol+1 )      = VerTab(3*(i-1)+1)
    solTab(iSol+2:iSol+4)=[VerTab(3*(i-1)+1),VerTab(3*(i-1)+2),0d0]
    solTab(iSol+5 )      = VerTab(3*(i-1)+2)
  enddo
  
  res=GmfSetBlockF90(          &
  &   unit=OutMsh             ,&
  &   GmfKey=GmfSolAtVertices ,&
  &   ad0=1                   ,&
  &   ad1=NmbVer              ,&
  &   strd=strd               ,& !<= add stride when using Tab(:)
  &   Tab=solTab(1:)           )
  
  ! Don't forget to close the file
  res=GmfCloseMeshF90(unit=OutSol)
  print '("Output Solu Close         : ",a)',trim(SolFile)
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
  
end program test_libmeshb_block01_f90