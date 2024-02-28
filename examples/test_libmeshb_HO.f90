! libMeshb 7 basic example:
! read a Q2 quad mesh while using the automatic HO reordering feature,
! split it into P2 triangles and write the result back using fast block transfer


function baseLagrangeTriangleP4(u,v) result(ai)
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  implicit none
  real(real64), intent(in) :: u,v
  real(real64)             :: ai(1:15)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  
  ai(01) = ((-3 + 4*(1 - u - v))*(-2 + 4*(1 - u - v))*(-1 + 4*(1 - u - v))*(1 - u - v))/6.
  ai(02) = (8*u*(-2 + 4*(1 - u - v))*(-1 + 4*(1 - u - v))*(1 - u - v))/3.
  ai(03) = 4*u*(-1 + 4*u)*(-1 + 4*(1 - u - v))*(1 - u - v)
  ai(04) = (8*u*(-2 + 4*u)*(-1 + 4*u)*(1 - u - v))/3.
  ai(05) = (u*(-3 + 4*u)*(-2 + 4*u)*(-1 + 4*u))/6.
  ai(06) = (8*(-2 + 4*(1 - u - v))*(-1 + 4*(1 - u - v))*(1 - u - v)*v)/3.
  ai(07) = 32*u*(-1 + 4*(1 - u - v))*(1 - u - v)*v
  ai(08) = 32*u*(-1 + 4*u)*(1 - u - v)*v
  ai(09) = (8*u*(-2 + 4*u)*(-1 + 4*u)*v)/3.
  ai(10) = 4*(-1 + 4*(1 - u - v))*(1 - u - v)*v*(-1 + 4*v)
  ai(11) = 32*u*(1 - u - v)*v*(-1 + 4*v)
  ai(12) = 4*u*(-1 + 4*u)*v*(-1 + 4*v)
  ai(13) = (8*(1 - u - v)*v*(-2 + 4*v)*(-1 + 4*v))/3.
  ai(14) = (8*u*v*(-2 + 4*v)*(-1 + 4*v))/3.
  ai(15) = (v*(-3 + 4*v)*(-2 + 4*v)*(-1 + 4*v))/6.  
 !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  return
end function baseLagrangeTriangleP4

program test_libmeshb_HO_f90
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
    integer(int32)          :: i,iTria
    integer(int32)          :: GmfCell,GmfOrd
    integer(int32)          :: NmbVer,NmbQad,NmbTri,ver,dim,res
    real(real64)  , pointer :: VerTab(:,:)=>null()
    integer(int32), pointer :: VerRef(  :)=>null()
    integer(int32), pointer :: QadTab(:,:)=>null(),QadRef(:)=>null()
    integer(int32), pointer :: TriTab(:,:)=>null(),TriRef(:)=>null()
    integer(int32)          :: GmfKey
    
    interface 
      function     baseLagrangeTriangleP4(u,v) result(ai)
        use iso_fortran_env
        real(real64), intent(in) :: u,v
        real(real64)             :: ai(1:15)
      end function baseLagrangeTriangleP4
    end interface
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
        integer :: nNod
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
        nNod=(ord+1)*(ord+1)  ! <=
        
        res=GmfGetBlockF90(         &
        &   unit=InpMsh            ,&
        &   GmfKey=GmfOrd          ,&
        &   ad0=1                  ,&
        &   ad1=nNod               ,&
        &   Tab=OrdTab(:,1:nNod)    )
        
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
    block
      integer(int32)          :: ord,nNod
      real(real64)  , pointer :: uvw(:,:)
      integer(int32)          :: strd
      integer(int32)          :: NmbFields
      integer(int32), pointer :: fieldsKind(:)=>null()
      character(32) , pointer :: fieldsName(:)=>null()
      real(real64)  , pointer :: solTab(:,:)=>null()
      
      print '(/"Output Solu Open    : ",a )',trim(SolFile)
      
      OutSol=GmfOpenMeshF90(name=trim(SolFile),GmfKey=GmfWrite,ver=ver,dim=dim)
      
      print '( "Output Solu Idx     : ",i0)',OutSol
      print '( "Output Solu ver     : ",i0)',ver
      print '( "Output Solu dim     : ",i0)',dim
      if( OutSol==0 ) STOP ' OutSol = 0'
      
      ! Set the solution kinds
      NmbFields=3
      allocate( fieldsKind(1:NmbFields))
      allocate( fieldsName(1:NmbFields))
      fieldsKind(1:NmbFields)=[GmfSca ,GmfVec ,GmfSca ]
      fieldsName(1:NmbFields)=['sca_1','vec_1','sca_2']
      
      ! Write iteration number in file
      res=GmfSetKwdF90 (unit=OutSol, GmfKey=GmfIterations, Nmb=1 )
      res=GmfSetLineF90(unit=OutSol, GmfKey=GmfIterations, Tab=int(10,kind=int32)) ! number of iteration (example 10)  
      
      ! Write Time in solution file
      res=GmfSetKwdF90 (unit=OutSol, GmfKey=GmfTime, Nmb=1)
      res=GmfSetLineF90(unit=OutSol, GmfKey=GmfTime, Tab=real(60,kind=real64))
      
      ! Solution Stride
      strd=5 ! 1+3+1 (GmfSca,GmfVec,GmfSca)
      
      ! Writing HO Interoplation Nodes
      ord=4
      nNod=(ord+1)*(ord+2)/2
      print '( "Output Solu ord     : ",i0)', ord
      print '( "Output Solu nNod    : ",i0)', nNod
      
      allocate(uvw(1:3,1:nNod))
      
      ! Triangles P2 Nodes Positions {1-u-v,u,v}  (order=4)   (Grille régulière)
      uvw(1:3,01)= [1.00d0, 0.00d0, 0.00d0]
      uvw(1:3,02)= [0.75d0, 0.25d0, 0.00d0]
      uvw(1:3,03)= [0.50d0, 0.50d0, 0.00d0]
      uvw(1:3,04)= [0.25d0, 0.75d0, 0.00d0]
      uvw(1:3,05)= [0.00d0, 1.00d0, 0.00d0]
      uvw(1:3,06)= [0.75d0, 0.00d0, 0.25d0]
      uvw(1:3,07)= [0.50d0, 0.25d0, 0.25d0]
      uvw(1:3,08)= [0.25d0, 0.50d0, 0.25d0]
      uvw(1:3,09)= [0.00d0, 0.75d0, 0.25d0]
      uvw(1:3,10)= [0.50d0, 0.00d0, 0.50d0]
      uvw(1:3,11)= [0.25d0, 0.25d0, 0.50d0]
      uvw(1:3,12)= [0.00d0, 0.50d0, 0.50d0]
      uvw(1:3,13)= [0.25d0, 0.00d0, 0.75d0]
      uvw(1:3,14)= [0.00d0, 0.25d0, 0.75d0]   
      uvw(1:3,15)= [0.00d0, 0.00d0, 1.00d0]
      
      GmfKey=GmfHOSolAtTrianglesP2NodesPositions
      
      res=GmfSetKwdF90(unit=OutSol, GmfKey=GmfKey, Nmb=nNod)
      
      res=GmfSetBlockF90(    &
      &   unit=OutSol       ,&
      &   GmfKey=GmfKey     ,&
      &   ad0=1             ,&
      &   ad1=nNod          ,&
      &   Tab=uvw(:,1:)      )
      
      !NmbDeg=NmbTri*nNod      
      allocate(solTab(1:strd*nNod,1:NmbTri))
      print '("Output Solu  size(solTab): ",i0,"x",i0)',size(solTab,1),size(solTab,2)
      
      ! Computing HO Solu(x,y,z)
      soluXYZ :block
        use iso_c_binding, only: c_loc,c_f_pointer
        real(real64)  , pointer :: uv0 (:,:)=>null()
        real(real64)  , pointer :: li0 (:,:)=>null()
        real(real64)  , pointer :: xyz0(:,:)=>null()
        real(real64)  , pointer :: li  (:,:)=>null()
        real(real64)  , pointer :: xyz (:,:)=>null()
        real(real64)  , pointer :: sol (:,:)=>null()
        real(real64)  , pointer :: sol1(:)  =>null()
        
        
        allocate(li0(1:nNod,1:6),uv0(1:2,1:6))
        allocate(xyz0(1:3,1:6))
        allocate(li(1:6,1:nNod))
        allocate(xyz(1:3,1:nNod))
        allocate(sol(1:strd,1:nNod))
        
        ! Triangle P2: uv0
        !>  03 
        !>  06 05
        !>  01 04 02
        uv0(1:2,1)=[0.0d0,0.0d0]
        uv0(1:2,2)=[1.0d0,0.0d0]
        uv0(1:2,3)=[0.0d0,1.0d0]
        uv0(1:2,4)=[0.5d0,0.0d0]
        uv0(1:2,5)=[0.5d0,0.5d0]
        uv0(1:2,6)=[0.0d0,0.5d0]
        
        do i=1,6
          li0(1:nNod,i)=baseLagrangeTriangleP4(u=uv0(1,i),v=uv0(2,i))
        enddo
        li(1:6,1:nNod)=transpose(li0(1:nNod,1:6))
        
        do iTria=1,NmbTri          
          do i=1,6
            xyz0(1:3,i)=VerTab(1:3,TriTab(i,iTria))
          enddo
          xyz(1:3,1:nNod)=matmul(xyz0(1:3,1:6),li(1:6,1:nNod))
          
          do i=1,nNod
            sol(  1,i)=xyz(1,i)
            sol(2:4,i)=[xyz(1,i),xyz(2,i),0d0]
            sol(  5,i)=xyz(2,i)
          enddo
          call c_f_pointer(cptr=c_loc(sol), fptr=sol1, shape=[strd*nNod]) ! bind shape (1:strd,1:nNod) to shape (1:strd*nNod)
          solTab(:,iTria)=sol1(:)
        enddo
        
        deallocate(li0,uv0)
        deallocate(xyz0)
        deallocate(li)
        deallocate(xyz)
        deallocate(sol)
        sol1=>null() ! no memory allocated, sol1 is binded to sol
      end block soluXYZ
      
      ! Write Solution strd*nNods solution per triangleP2 => strd*nNod*nTri)
      GmfKey=GmfHOSolAtTrianglesP2
      
      res=GmfSetKwdF90(                  &
      &   unit=OutSol                   ,&
      &   GmfKey=GmfKey                 ,&
      &   Nmb=NmbTri                    ,&
      &   NmbFields=NmbFields           ,&
      &   fields=fieldsKind(1:NmbFields),&
      &   ord=ord                       ,&
      &   nNod=nNod                      )
      
      res=GmfSetBlockF90(                &
      &    unit=OutSol                  ,&
      &    GmfKey=GmfKey                ,&
      &    ad0=1                        ,&
      &    ad1=NmbTri                   ,&
      &    Tab=solTab(:,1:)              )
      
      ! Don't forget to close the file
      res=GmfCloseMeshF90(unit=OutSol)
      print '("Output Solu Close   : ",a)',trim(SolFile)    
      
      deallocate(uvw)
      deallocate(solTab)
    end block
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    !> Cleanning Memory
    deallocate(VerTab,VerRef)
    deallocate(QadTab,QadRef)
    deallocate(TriTab,TriRef)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    print '(/"Constrol"/"vizir4 -in ",a," -sol ",a,/)',trim(OutFile),trim(SolFile)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end program test_libmeshb_HO_f90



  