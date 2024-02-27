! libMeshb 7.79 basic example:
! read a quad mesh, split it into triangles and write the result back
! write an associated dummy .sol file containing some data

!> A FAIRE ajouter time
!> A FAIRE ajouter iteration
!> A FAIRE ajouter nom des champs

program  test_libmeshb_f90
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  use iso_c_binding, only: C_NULL_CHAR
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
  SolFile='./tri.sol'
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
  
  !nomDesChamps : block
  !  integer               :: iField,nChar
  !  character(:), pointer :: fieldName=>null()
  !  res=GmfSetKwdF90(unit=OutSol, GmfKey=GmfReferenceStrings, Nmb=NmbFields)
  !  do iField=1,NmbFields
  !    nChar=len_trim(fieldsName(iField)) ! print '("nChar: ",i0)',nChar
  !    allocate(character(len=nChar+3) :: fieldName)
  !    write(fieldName,'(a,1x,i0,a)')trim(fieldsName(iField)),iField,C_NULL_CHAR
  !    print '("fieldName: ",a)',fieldName
  !    
  !    !ress=GmfSetLin(unit=OutSol, GmfKey=GmfReferenceStrings, GmfSolAtVertices, 1, fieldName)
  !    
  !    deallocate(fieldName)
  !  enddo
  !end block nomDesChamps
  

  allocate(sol(1:5)) !       1+   dim+     1
  print '( "Output Solu NmbVer  : ",i0)',NmbVer
  print '( "Output Solu nFields : ",i0)',NmbFields
  print '( "Output Solu fields  : ", *(i0,1x))',fields(1:NmbFields)
  
  ! Set the number of solutions (one per vertex)
  res=GmfSetKwdF90(unit=OutSol, GmfKey=GmfSolAtVertices, Nmb=NmbVer, NmbFields=NmbFields, fields=fields(1:NmbFields))
  
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
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Cleanning Memory
  deallocate(VerTab,VerRef)
  deallocate(QadTab,QadRef)
  deallocate(fields,fieldsName,sol)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> User Control
  print '(/"Control:"/"vizir4 -in ",a," -sol ",a/)',trim(OutFile),trim(SolFile)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
end program test_libmeshb_f90
