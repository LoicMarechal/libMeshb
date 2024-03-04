! libMeshb 7.79 basic example:
! read a quad mesh, split it into triangles and write the result back
! write an associated dummy .sol file containing some data

!> A FAIRE ajouter time
!> A FAIRE ajouter iteration
!> A FAIRE ajouter nom des champs


function equal_int32(x,y) result(test)
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  integer(int32) , intent(in)  :: x(:)
  integer(int32) , intent(in)  :: y(:)
  logical                      :: test
  !>
  integer(int32)               :: i,nx,ny
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  nx=size(x) ; ny=size(y)
  if( .not.nx==ny )stop 'dimensions non compatibles'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  do i=1,nx
    if( .not.x(i)==y(i) )then
      test=.false.
      return
    endif
  enddo
  test=.true.
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  return
end function equal_int32

function     equal_real64(x,y) result(test)
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  real(real64) , intent(in)    :: x(:)
  real(real64) , intent(in)    :: y(:)
  logical                      :: test
  !>
  integer(int32)               :: i,nx,ny
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  nx=size(x) ; ny=size(y)
  if( .not.nx==ny )stop 'dimensions non compatibles'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  do i=1,nx
    if( .not.x(i)==y(i) )then
      test=.false.
      return
    endif
  enddo
  test=.true.
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  return
end function equal_real64



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
  integer(int32)          :: NmbFields,ho,s,d
  integer(int32), pointer :: fields(:)
  character(32) , pointer :: fieldsName(:)=>null()
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
  
  InpMsh=GmfOpenMeshF90(name=trim(InpFile),GmfKey=GmfRead,ver=ver,dim=dim)
  
  print '( "Input  Mesh Idx     : ",i0)',InpMsh
  print '( "Input  Mesh ver     : ",i0)',ver
  print '( "Input  Mesh dim     : ",i0)',dim
  
  if( InpMsh==0 ) stop ' InpMsh = 0'
  if( ver<=1    ) stop ' version <= 1'
  if( dim/=3    ) stop ' dimension <> 3'
  
  ! Read the vertices
  
  NmbVer = GmfstatkwdF90(unit=InpMsh, GmfKey=GmfVertices)
  print '( "Input  Mesh NmbVer  : ",i0)', NmbVer
  allocate(VerTab(1:3,1:NmbVer))
  allocate(VerRef(    1:NmbVer))
  
  res=GmfGotoKwdF90(unit=InpMsh, GmfKey=GmfVertices)
  do i=1,NmbVer
    res=GmfGetLineF90(unit=InpMsh, GmfKey=GmfVertices, Tab=VerTab(:,i), Ref=VerRef(i))
  end do
  
  ! Read the quads
  
  NmbQad = GmfstatkwdF90(unit=InpMsh, GmfKey=GmfQuadrilaterals)
  print '( "Input  Mesh NmbQad  : ",i0)', NmbQad
  allocate(QadTab(1:4,1:NmbQad))
  allocate(QadRef(    1:NmbQad))
  
  res=GmfgotokwdF90(unit=InpMsh, GmfKey=GmfQuadrilaterals)
  do i=1,NmbQad
    res=GmfGetLineF90(unit=InpMsh, GmfKey=GmfQuadrilaterals, Tab=QadTab(:,i), Ref=QadRef(i))
  enddo
  
  ! Close the quadrilateral mesh
  res=GmfCloseMeshF90(unit=InpMsh)
  print '("Input  Mesh Close   : ",a)',trim(InpFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Create a triangular mesh
  NmbTri=2*NmbQad
  
  print '(/"Output Mesh Open    : ",a )',trim(OutFile)
  
  OutMsh=GmfOpenMeshF90(name=trim(OutFile),GmfKey=GmfWrite,ver=ver,dim=dim)
  
  print '( "Output Mesh Idx     : ",i0)',InpMsh
  print '( "Output Mesh ver     : ",i0)',ver
  print '( "Output Mesh dim     : ",i0)',dim
  if( OutMsh==0 ) STOP ' OutMsh = 0'
  
  ! Set the number of vertices
  res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfVertices, Nmb=NmbVer)
  print '( "Output Mesh NmbVer  : ",i0)', NmbVer
  
  ! Then write them down
  do i=1,NmbVer
    res=GmfSetLineF90(unit=OutMsh, GmfKey=GmfVertices, Tab=VerTab(:,i), Ref=VerRef(i))
  end do
  
  ! Write the triangles
  res=GmfSetKwdF90(unit=OutMsh, GmfKey=GmfTriangles, Nmb=NmbTri)
  print '( "Output Mesh NmbTri  : ",i0)', NmbTri
  
  do i=1,NmbQad
    res=GmfSetLineF90(unit=OutMsh, GmfKey=GmfTriangles, Tab=QadTab(1:3,i), Ref=QadRef(i))
    !     Modify the quad to build the other triangle's diagonal
    QadTab(2,i) = QadTab(3,i)
    QadTab(3,i) = QadTab(4,i)
    res=GmfSetLineF90(unit=OutMsh, GmfKey=GmfTriangles, Tab=QadTab(1:3,i), Ref=QadRef(i))
  end do
  
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
  
  ! Write iteration number in file
  res=GmfSetKwdF90 (unit=OutSol, GmfKey=GmfIterations, Nmb=1 )
  res=GmfSetLineF90(unit=OutSol, GmfKey=GmfIterations, Tab=int(10,kind=int32)) ! number of iteration (example 10)  
  
  ! Write Time in solution file
  res=GmfSetKwdF90 (unit=OutSol, GmfKey=GmfTime, Nmb=1)
  res=GmfSetLineF90(unit=OutSol, GmfKey=GmfTime, Tab=real(60,kind=real64))
  
  ! Set the solution kinds
  NmbFields=3
  allocate( fields    (1:NmbFields))
  allocate( fieldsName(1:NmbFields))
  fields(1:NmbFields) = [GmfSca,GmfVec,GmfSca]  
  fieldsName(1:NmbFields)=['sca_1','vec_1','sca_2']
  
  allocate(sol(1:5)) !       1+   dim+     1
  print '( "Output Solu NmbVer  : ",i0)',NmbVer
  print '( "Output Solu nFields : ",i0)',NmbFields
  print '( "Output Solu fields  : ", *(i0,1x))',fields(1:NmbFields)
  
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
  
  ! Write the dummy solution fields
  do i=1,NmbVer
    sol(  1)=VerTab(1,i)
    sol(2:4)=[VerTab(1,i),VerTab(2,i),0d0]
    sol(  5)=VerTab(2,i)
    res=GmfSetLineF90(unit=OutSol, GmfKey=GmfSolAtVertices, Tab=sol(:))
  enddo
  
  ! Don't forget to close the file
  res=GmfCloseMeshF90(unit=OutSol)
  print '("Output Solu Close   : ",a)',trim(SolFile)
  
  deallocate(fields,fieldsName,sol)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Cleanning Memory
  deallocate(VerTab,VerRef)
  deallocate(QadTab,QadRef)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> User Control
  print '(/"Control:"/"vizir4 -in ",a," -sol ",a/)',trim(OutFile),trim(SolFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Write/Read Int Map Solutions on triangular mesh and Read it
  IntMap: block
    integer(int64)          :: OutMap
    character(80)           :: MapFile
    integer(int32), pointer :: map(:),map2(:),map3(:,:)
    integer                 :: iField,nFld,nSol,strd
    logical                 :: test,testGlob=.true.
    integer                 :: iSfx
    character(5)            :: sufix(1:2)
    
    !interface operator(==)
    interface operator(.equal.)
      function equal_int32(x,y) result(test)
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        use iso_fortran_env
        integer(int32) , intent(in)  :: x(:)
        integer(int32) , intent(in)  :: y(:)
        logical                      :: test
      end function
    end interface
    
    sufix(1)=".sol"    
    sufix(2)=".solb"
    
    do iSfx=1,size(sufix)
      
      IntMapTestsLoop : do NmbFields=1,5
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test Init
        allocate( fields(1:NmbFields)) ; fields(:)=[(GmfSca, i=1,NmbFields)]
        
        allocate(fieldsName(1:NmbFields))
        do iField=1,NmbFields
          write(fieldsName(iField),'("order",i0)')iField
          !print '("fieldsName(",i2.2,"): ",a)',i, trim(fieldsName(iField))
        enddo
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test 1    
        ! ---
        ! Ecriture par ligne
        
        allocate( map   (1:NmbFields)) ; map   (:)=[(i     , i=1,NmbFields)]
        
        write(MapFile,'( "./tri_map_",i0,a)') NmbFields,trim(sufix(iSfx))
  
        !print '(/"Int32  Map     Open    : ",a)',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfWrite,ver=2,dim=3)
        
        ! Set the number of solutions (one per Tringle)
        if( NmbFields==1 )then
          res=GmfSetKwdF90(            &
          &   unit=OutMap             ,& 
          &   GmfKey=GmfSolAtTriangles,& 
          &   Nmb=NmbTri              ,&
          &   NmbFields=NmbFields     ,&
          &   fields=[GmfSca]          ) ! <= optional
          
          do i=1,NmbTri
            res=GmfSetLineF90(unit=OutMap, GmfKey=GmfSolAtTriangles, Tab=map(1)) ! teste la fonction GmfSetLineF90_sol_i_
          enddo
        else      
          ! Set the number of solutions (one per Tringle)
          res=GmfSetKwdF90(            &
          &   unit=OutMap             ,& 
          &   GmfKey=GmfSolAtTriangles,& 
          &   Nmb=NmbTri              ,&
          &   NmbFields=NmbFields     ,&
          &   fields=fields            ) ! <= optional
          
          do i=1,NmbTri
            res=GmfSetLineF90(unit=OutMap, GmfKey=GmfSolAtTriangles, Tab=map(:)) ! teste la fonction GmfSetLineF90_sol_i
          enddo
        endif
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Int32  Map     Close   : ",a)',trim(MapFile)
        
        ! ---
        ! lecture par ligne
        !print '(/"Int32  Map     Open    : ",a)',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfRead,ver=ver,dim=dim)
  
        Test=.true.
        do i=1,NmbTri
          res=GmfGetLineF90(unit=OutSol, GmfKey=GmfSolAtTriangles, Tab=map(:))
          if( .not. ( map(1:NmbFields).equal.[(i, i=1,NmbFields)] ) )test=.false.
          !if( i<=5 )print '("map="*(i0,1x))',map(:)
        enddo
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Int32  Map     Close   : ",a)',trim(MapFile)
        
        if( .not.test )testGlob=.false.
        print '( "Int32  Map    Test1    : NmbFields=",i0,"   R/W Line",t55,l1)',NmbFields,Test
        
        deallocate(map)
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test 2
        
        ! ---
        ! Ecriture par block (:)
        
        allocate( map2(1:NmbTri*NmbFields))
        do i=1,NmbTri*NmbFields,NmbFields
          map2(i:i+NmbFields-1)=[(iField , iField=1,NmbFields)]
        enddo
        
        write(MapFile,'( "./tri_map2_",i0,a)') NmbFields,trim(sufix(iSfx))
        !print '(/"Int32  Map     Open    : ",a )',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfWrite,ver=2,dim=3)
        
        res=GmfSetKwdF90(            &
        &   unit=OutMap             ,& 
        &   GmfKey=GmfSolAtTriangles,& 
        &   Nmb=NmbTri              ,&
        &   NmbFields=NmbFields     ,&
        &   fields=fields            ) ! <= optional
        
        res=GmfSetBlockF90(          &
        &   unit=OutMap             ,&
        &   GmfKey=GmfSolAtTriangles,&
        &   ad0=1                   ,&
        &   ad1=NmbTri              ,&
        &   strd=NmbFields          ,& !<= add stride when using Tab(:)
        &   Tab=map2(1:)             )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Int32  Map     Close   : ",a)',trim(MapFile)
        
        ! ---
        ! Lecture block (:)
        
        map2(:)=0
        
        !print '(/"Int32  Map     Open    : ",a )',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfRead,ver=ver,dim=dim)
              
        nSol=GmfStatKwdF90(             &
        &    unit=OutMap               ,&
        &    GmfKey=GmfSolAtTriangles  ,&
        &    NmbFields=nFld            ,&
        &    strd=strd                 ,&
        &    fields=fields(1:NmbFields) )
        
        !print '("fields=",*(i0,1x))',fields
        !print '("nFld=",i0)',nFld
        !print '("strd=",i0)',strd
        
        res=GmfGetBlockF90(                 &
        &   unit=OutMap                    ,&
        &   GmfKey=GmfSolAtTriangles       ,&
        &   ad0=1                          ,&
        &   ad1=NmbTri                     ,&
        &   strd=NmbFields                 ,& !<= add stride when using Tab(:)
        &   Tab=map2(1:)                    )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Int32  Map     Close   : ",a)',trim(MapFile)
        
        Test=.true.
        do i=1,NmbFields*NmbTri,NmbFields
          !if( i<5*NmbFields )print '("map2="*(i0,1x))',map2(i:i+NmbFields-1)
          if( .not. ( map2(i:i+NmbFields-1).equal.[(i, i=1,NmbFields)] ) )Test=.false.
        enddo
        if( .not.test )testGlob=.false.
        print '( "Int32  Map    Test2    : NmbFields=",i0,"   R/W Block(:)",t55,l1)',NmbFields,Test
        
        deallocate(map2)
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test 3 R/W block (:,:)
        
        ! ---
        ! Ecriture block (:,:)
        
        allocate( map3(1:NmbFields,1:NmbTri))
        do i=1,NmbTri
          map3(1:NmbFields,i)=[(iField , iField=1,NmbFields)]
        enddo
        
        write(MapFile,'( "./tri_map3_",i0,a)') NmbFields,trim(sufix(iSfx))
        !print '(/"Int32  Map     Open    : ",a )',trim(MapFile)      
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfWrite,ver=2,dim=3)
        
        res=GmfSetKwdF90(            &
        &   unit=OutMap             ,& 
        &   GmfKey=GmfSolAtTriangles,& 
        &   Nmb=NmbTri              ,&
        &   NmbFields=NmbFields     ,&
        &   fields=fields            ) ! <= optional
        
        res=GmfSetBlockF90(          &
        &   unit=OutMap             ,&
        &   GmfKey=GmfSolAtTriangles,&
        &   ad0=1                   ,&
        &   ad1=NmbTri              ,&
        &   Tab=map3(:,1:)           )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Int32  Map     Close   : ",a)',trim(MapFile)
        
        ! ---
        ! Lecture block (:,:)
        
        map3(:,:)=0
        
        !print '(/"Int32  Map     Open    : ",a )',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfRead,ver=ver,dim=dim)
        
        nSol=GmfStatKwdF90(             &
        &    unit=OutMap               ,&
        &    GmfKey=GmfSolAtTriangles  ,&
        &    NmbFields=nFld            ,&
        &    strd=strd                 ,&
        &    fields=fields(1:nFld)      )
        
        !print '("fields=",*(i0,1x))',fields
        !print '("nFld=",i0)',nFld
        !print '("strd=",i0)',strd
        
        res=GmfGetBlockF90(                 &
        &   unit=OutMap                    ,&
        &   GmfKey=GmfSolAtTriangles       ,&
        &   ad0=1                          ,&
        &   ad1=NmbTri                     ,&
        &   Tab=map3(:,1:)                  )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Int32  Map     Close   : ",a)',trim(MapFile)
        
        Test=.true.
        do i=1,NmbFields,NmbFields
          !if( i<5 )print '("map3="*(i0,1x))',map3(1:NmbFields,i)
          if( .not. ( map3(1:NmbFields,i).equal.[(i, i=1,NmbFields)] ) )Test=.false.
        enddo
        if( .not.test )testGlob=.false.
        print '( "Int32  Map    Test3    : NmbFields=",i0,"   R/W Block(:,:)",t55,l1)',NmbFields,Test
        
        deallocate(map3)
        ! ---
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test Finalize
        deallocate(fields)
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
      enddo IntMapTestsLoop
    enddo
    print '(/"Output int32  Map TestGlob : ",l1/)',TestGlob
    
  end block IntMap
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Write/Read Real64 Map Solutions on triangular mesh and Read it
  realMap: block
    integer(int64)          :: OutMap
    character(80)           :: MapFile
    real(real64), pointer   :: map(:),map2(:),map3(:,:)
    integer                 :: iField,nFld,nSol,strd
    logical                 :: test,testGlob=.true.
    integer                 :: iSfx
    character(5)            :: sufix(1:2)
    
    !interface operator(==)
    interface operator(.equal.)
      function equal_real64(x,y) result(test)
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        use iso_fortran_env
        real(real64) , intent(in)  :: x(:)
        real(real64) , intent(in)  :: y(:)
        logical                    :: test
      end function
    end interface
    
    sufix(1)=".sol"    
    sufix(2)=".solb"
    
    do iSfx=1,size(sufix)
      
      realMapTestsLoop : do NmbFields=1,5
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test Init
        allocate( fields(1:NmbFields)) ; fields(:)=[(GmfSca, i=1,NmbFields)]
        
        allocate(fieldsName(1:NmbFields))
        do iField=1,NmbFields
          write(fieldsName(iField),'("order",i0)')iField
          !print '("fieldsName(",i2.2,"): ",a)',i, trim(fieldsName(iField))
        enddo
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test 1    
        ! ---
        ! Ecriture par ligne
        
        allocate( map   (1:NmbFields)) ; map   (:)=real([(i     , i=1,NmbFields)],kind=real64)
        
        write(MapFile,'( "./tri_map_",i0,a)') NmbFields,trim(sufix(iSfx))
  
        !print '(/"Real64 Map     Open    : ",a)',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfWrite,ver=2,dim=3)
        
        ! Set the number of solutions (one per Tringle)
        if( NmbFields==1 )then
          res=GmfSetKwdF90(            &
          &   unit=OutMap             ,& 
          &   GmfKey=GmfSolAtTriangles,& 
          &   Nmb=NmbTri              ,&
          &   NmbFields=NmbFields     ,&
          &   fields=[GmfSca]          ) ! <= optional
          
          do i=1,NmbTri
            res=GmfSetLineF90(unit=OutMap, GmfKey=GmfSolAtTriangles, Tab=map(1)) ! teste la fonction GmfSetLineF90_sol_i_
          enddo
        else      
          ! Set the number of solutions (one per Tringle)
          res=GmfSetKwdF90(            &
          &   unit=OutMap             ,& 
          &   GmfKey=GmfSolAtTriangles,& 
          &   Nmb=NmbTri              ,&
          &   NmbFields=NmbFields     ,&
          &   fields=fields            ) ! <= optional
          
          do i=1,NmbTri
            res=GmfSetLineF90(unit=OutMap, GmfKey=GmfSolAtTriangles, Tab=map(:)) ! teste la fonction GmfSetLineF90_sol_i
          enddo
        endif
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Real64 Map     Close   : ",a)',trim(MapFile)
        
        ! ---
        ! lecture par ligne
        !print '(/"Real64 Map     Open    : ",a)',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfRead,ver=ver,dim=dim)
  
        Test=.true.
        do i=1,NmbTri
          res=GmfGetLineF90(unit=OutSol, GmfKey=GmfSolAtTriangles, Tab=map(:))
          if( .not. ( map(1:NmbFields).equal.real([(i, i=1,NmbFields)],kind=real64) ))test=.false.
          !if( i<=5 )print '("map="*(i0,1x))',map(:)
        enddo
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Real64 Map     Close   : ",a)',trim(MapFile)
        
        if( .not.test )testGlob=.false.
        print '( "Real64 Map    Test1    : NmbFields=",i0,"   R/W Line",t55,l1)',NmbFields,Test
        
        deallocate(map)
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test 2
        
        ! ---
        ! Ecriture par block (:)
        
        allocate( map2(1:NmbTri*NmbFields))
        do i=1,NmbTri*NmbFields,NmbFields
          map2(i:i+NmbFields-1)=[(iField , iField=1,NmbFields)]
        enddo
        
        write(MapFile,'( "./tri_map2_",i0,a)') NmbFields,trim(sufix(iSfx))
        !print '(/"Real64 Map     Open    : ",a )',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfWrite,ver=2,dim=3)
        
        res=GmfSetKwdF90(            &
        &   unit=OutMap             ,& 
        &   GmfKey=GmfSolAtTriangles,& 
        &   Nmb=NmbTri              ,&
        &   NmbFields=NmbFields     ,&
        &   fields=fields            ) ! <= optional
        
        res=GmfSetBlockF90(          &
        &   unit=OutMap             ,&
        &   GmfKey=GmfSolAtTriangles,&
        &   ad0=1                   ,&
        &   ad1=NmbTri              ,&
        &   strd=NmbFields          ,& !<= add stride when using Tab(:)
        &   Tab=map2(1:)             )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Real64 Map     Close   : ",a)',trim(MapFile)
        
        ! ---
        ! Lecture block (:)
        
        map2(:)=0
        
        !print '(/"Real64 Map     Open    : ",a )',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfRead,ver=ver,dim=dim)
              
        nSol=GmfStatKwdF90(             &
        &    unit=OutMap               ,&
        &    GmfKey=GmfSolAtTriangles  ,&
        &    NmbFields=nFld            ,&
        &    strd=strd                 ,&
        &    fields=fields(1:NmbFields) )
        
        !print '("fields=",*(i0,1x))',fields
        !print '("nFld=",i0)',nFld
        !print '("strd=",i0)',strd
        
        res=GmfGetBlockF90(                 &
        &   unit=OutMap                    ,&
        &   GmfKey=GmfSolAtTriangles       ,&
        &   ad0=1                          ,&
        &   ad1=NmbTri                     ,&
        &   strd=NmbFields                 ,& !<= add stride when using Tab(:)
        &   Tab=map2(1:)                    )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Real64 Map     Close   : ",a)',trim(MapFile)
        
        Test=.true.
        do i=1,NmbFields*NmbTri,NmbFields
          !if( i<5*NmbFields )print '("map2="*(i0,1x))',map2(i:i+NmbFields-1)
          if( .not. ( map2(i:i+NmbFields-1).equal.real([(i, i=1,NmbFields)],kind=real64) ))Test=.false.
        enddo
        if( .not.test )testGlob=.false.
        print '( "Real64 Map    Test2    : NmbFields=",i0,"   R/W Block(:)",t55,l1)',NmbFields,Test
        
        deallocate(map2)
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test 3 R/W block (:,:)
        
        ! ---
        ! Ecriture block (:,:)
        
        allocate( map3(1:NmbFields,1:NmbTri))
        do i=1,NmbTri
          map3(1:NmbFields,i)=[(iField , iField=1,NmbFields)]
        enddo
        
        write(MapFile,'( "./tri_map3_",i0,a)') NmbFields,trim(sufix(iSfx))
        !print '(/"Real64 Map     Open    : ",a )',trim(MapFile)      
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfWrite,ver=2,dim=3)
        
        res=GmfSetKwdF90(            &
        &   unit=OutMap             ,& 
        &   GmfKey=GmfSolAtTriangles,& 
        &   Nmb=NmbTri              ,&
        &   NmbFields=NmbFields     ,&
        &   fields=fields            ) ! <= optional
        
        res=GmfSetBlockF90(          &
        &   unit=OutMap             ,&
        &   GmfKey=GmfSolAtTriangles,&
        &   ad0=1                   ,&
        &   ad1=NmbTri              ,&
        &   Tab=map3(:,1:)           )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Real64 Map     Close   : ",a)',trim(MapFile)
        
        ! ---
        ! Lecture block (:,:)
        
        map3(:,:)=0
        
        !print '(/"Real64 Map     Open    : ",a )',trim(MapFile)
        OutMap=GmfOpenMeshF90(name=trim(MapFile),GmfKey=GmfRead,ver=ver,dim=dim)
        
        nSol=GmfStatKwdF90(             &
        &    unit=OutMap               ,&
        &    GmfKey=GmfSolAtTriangles  ,&
        &    NmbFields=nFld            ,&
        &    strd=strd                 ,&
        &    fields=fields(1:nFld)      )
        
        !print '("fields=",*(i0,1x))',fields
        !print '("nFld=",i0)',nFld
        !print '("strd=",i0)',strd
        
        res=GmfGetBlockF90(                 &
        &   unit=OutMap                    ,&
        &   GmfKey=GmfSolAtTriangles       ,&
        &   ad0=1                          ,&
        &   ad1=NmbTri                     ,&
        &   Tab=map3(:,1:)                  )
        
        res=GmfCloseMeshF90(unit=OutMap)
        !print '( "Real64 Map     Close   : ",a)',trim(MapFile)
        
        Test=.true.
        do i=1,NmbFields,NmbFields
          !if( i<5 )print '("map3="*(i0,1x))',map3(1:NmbFields,i)
          if( .not. ( map3(1:NmbFields,i).equal.real([(i, i=1,NmbFields)],kind=real64) ))Test=.false.
        enddo
        if( .not.test )testGlob=.false.
        print '( "Real64 Map    Test3    : NmbFields=",i0,"   R/W Block(:,:)",t55,l1)',NmbFields,Test
        
        deallocate(map3)
        ! ---
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        ! Test Finalize
        deallocate(fields)
        !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
      enddo realMapTestsLoop
    enddo
    print '(/"Output Real64 Map TestGlob : ",l1/)',TestGlob
    
  end block realMap
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
end program test_libmeshb_f90
