! libMeshb 7 basic example:
! read a Q2 quad mesh while using the automatic HO reordering feature,
! split it into P2 triangles and write the result back using fast block transfer

program test_libmeshb_HO_f90
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    use iso_fortran_env
    use libmeshb7
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    implicit none
    integer(int64)          :: InpMsh, OutMsh, m(1)
    character(80)           :: InpFile
    character(80)           :: OutFile
    character(80)           :: SolFile
    integer(int32)          :: i,iTria
    integer(int32)          :: GmfCell,GmfOrd
    integer(int32)          :: NmbVer,NmbQad,NmbTri,ver,dim,res
    real(real64)  , pointer :: VerTab(:,:)
    integer(int32), pointer :: VerRef(  :)
    integer(int32), pointer :: QadTab(:,:),QadRef(  :)
    integer(int32), pointer :: TriTab(:,:),TriRef(  :)
    integer(int32)          :: t(1),d,ho,s
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    print '(/"test_libmeshb_HO_f90")'
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    InpFile='../sample_meshes/quad_q2.mesh'
    OutFile='./tri_p2.meshb'
    SolFile='./tri_p2.solb'
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Open the quadrilateral mesh file for reading
    print '(/"Input  Mesh File  : ",a )',trim(InpFile)
    
    ! Open the mesh file and check the version and dimension
    InpMsh=GmfOpenMeshF90(name=trim(InpFile),GmfKey=GmfRead,ver=ver,dim=dim)
    print '( "Input  Mesh Idx   : ",i0)',InpMsh
    print '( "Input  Mesh ver   : ",i0)',ver
    print '( "Input  Mesh dim   : ",i0)',dim
    
    if( InpMsh==0 ) stop ' InpMsh = 0'
    if( ver<=1    ) stop ' version <= 1'
    if( dim/=3    ) stop ' dimension <> 3'
    
    ! Read the vertices using a vector of 3 consecutive doubles to store the coordinates
    
    NmbVer = GmfstatkwdF90(unit=InpMsh, GmfKey=GmfVertices)
    print '( "Input  Mesh NmbVer: ",i0)', NmbVer
    allocate(VerTab(1:3,1:NmbVer))
    allocate(VerRef(    1:NmbVer))
    
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
    
    ! Read GmfQuadrilateralsQ2
    GmfCell=GmfQuadrilateralsQ2                 ! <=
    GmfOrd =GmfQuadrilateralsQ2Ordering         ! <=
    
    NmbQad=GmfstatkwdF90(unit=InpMsh,GmfKey=GmfCell)
    print '( "Input  Mesh NmbQad: ",i0)', NmbQad
    allocate(QadTab(1:9,1:NmbQad))
    allocate(QadRef(    1:NmbQad))
    
    if( .not. GmfstatkwdF90(unit=InpMsh,GmfKey=GmfOrd)==0 )then
      print '("Input  Mesh Reordering HO Nodes")'
      block
        integer :: BasTab(1:2,1:9)
        integer :: OrdTab(1:2,1:9)
        integer :: ord
        integer :: nNode
        !>  04 07 03 
        !>  08 09 06
        !>  01 05 02
        BasTab(1:2,01)=[0,0]
        BasTab(1:2,02)=[2,0]
        BasTab(1:2,03)=[2,2]
        BasTab(1:2,04)=[0,2]
        BasTab(1:2,05)=[1,0]
        BasTab(1:2,06)=[2,1]
        BasTab(1:2,07)=[1,2]
        BasTab(1:2,08)=[0,1]
        BasTab(1:2,09)=[1,1]
        
        print '("Input  Mesh Requested Order")'
        do i=1,size(BasTab,2)
          print '(3x,"uv(",i2.2,")=",2(i2,1x))',i,BasTab(1:2,i)
        enddo
        
        !> Q2 -> ord=2
        ord=2
        nNode=(ord+1)*(ord+1)  ! <=
        
        res=GmfGetBlockF90(         &
        &   unit=InpMsh            ,&
        &   GmfKey=GmfOrd          ,&
        &   ad0=1                  ,&
        &   ad1=nNode              ,&
        &   Tab=OrdTab(:,1:nNode)   )
        
        print '("Input  Mesh Order")'
        do i=1,size(OrdTab,2)
          print '(3x,"uv(",i2.2,")=",2(i2,1x))',i,OrdTab(1:2,i)
        enddo
        
        res=GmfSetHONodesOrderingF90(unit=InpMsh,GmfKey=GmfCell,BasTab=BasTab,OrdTab=OrdTab)
      end block
    endif
    
    ! Read the quads using one single vector of 5 consecutive integers    
    res=GmfGetBlockF90(            &
    &   unit=InpMsh               ,&
    &   GmfKey=GmfQuadrilateralsQ2,&
    &   ad0=1                     ,&
    &   ad1=NmbQad                ,&
    &   Tab=QadTab(:,1:)          ,&
    &   Ref=QadRef(  1:)           )
    
    ! Close the quadrilateral mesh
    print '("Input  Mesh Close : ",a)',trim(InpFile)
    
    !print '("Input  Mesh")'
    !do i=1,10 !NmbQad
    !  print '(3x,"qad",i6," nd:",9(i6,1x)," ref: ",i0)',i,QadTab(1:9,i),QadRef(i)
    !enddo
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Convert the quad Q2 mesh into a triangular P2 one
    
    ! Allocate TriTab and TriRef
    NmbTri=2*NmbQad
    allocate(TriTab(1:6,1:NmbTri))
    allocate(TriRef(    1:NmbTri))
    
    !>  04 07 03          03   04 07 03
    !>  08 09 06 =>    09 06 + 08 09   
    !>  01 05 02    01 05 02   01      
    
    !>  03 
    !>  06 05
    !>  01 04 02
    do i=1,NmbQad
      iTria=2*i-1
      TriTab(1,iTria) = QadTab(1,i)
      TriTab(2,iTria) = QadTab(2,i)
      TriTab(3,iTria) = QadTab(3,i)
      TriTab(4,iTria) = QadTab(5,i)
      TriTab(5,iTria) = QadTab(6,i)
      TriTab(6,iTria) = QadTab(9,i)
      TriRef(  iTria) = QadRef(  i)
      
      iTria=2*i
      TriTab(1,iTria) = QadTab(1,i)
      TriTab(2,iTria) = QadTab(3,i)
      TriTab(3,iTria) = QadTab(4,i)
      TriTab(4,iTria) = QadTab(9,i)
      TriTab(5,iTria) = QadTab(7,i)
      TriTab(6,iTria) = QadTab(8,i)
      TriRef(  iTria) = QadRef(  i) 
    enddo
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Write a triangular mesh
    
    print '(/"Output Mesh File  : ",a )',trim(OutFile)
    
    !print '("Output Mesh")'
    !do i=1,10
    !  print '(3x,"tri",i6," nd:",6(i6,1x)," ref: ",i0)',i,TriTab(1:6,i),TriRef(i)
    !enddo
    
    ! Open the mesh file and check the version and dimension
    OutMsh=GmfOpenMeshF90(name=trim(OutFile),GmfKey=GmfWrite,ver=ver,dim=dim)
    print '( "Output Mesh Idx   : ",i0)',InpMsh
    print '( "Output Mesh ver   : ",i0)',ver
    print '( "Output Mesh dim   : ",i0)',dim
    if( OutMsh==0 ) STOP ' OutMsh = 0'
    
    ! Set the number of vertices
    res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfVertices, Nmb=NmbVer)
    print '( "Output Mesh NmbVer: ",i0)', NmbVer
    
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
    res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfTrianglesP2, Nmb=NmbTri)
    print '( "Output Mesh NmbTri: ",i0)', NmbTri
    
    res=GmfSetBlockF90(        &
    &   unit=OutMsh           ,&
    &   GmfKey=GmfTrianglesP2 ,&
    &   ad0=1                 ,&
    &   ad1=NmbTri            ,&
    &   Tab=TriTab(:,1:NmbTri),&
    &   Ref=TriRef(  1:NmbVer) )
    
    ! Don't forget to close the file
    res=GmfCloseMeshF90(unit=OutMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Write a triangular P3 Solution on triangular mesh
    
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    !> Cleanning Memory
    deallocate(VerTab,VerRef)
    deallocate(QadTab,QadRef)
    deallocate(TriTab,TriRef)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    print '(/"control:"/"vizir4 -in ",a/)',trim(OutFile)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end program test_libmeshb_HO_f90
  
  