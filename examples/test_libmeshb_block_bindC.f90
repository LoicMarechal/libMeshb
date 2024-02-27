program test_libmeshb_block_bindC
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use, intrinsic :: iso_fortran_env
  use, intrinsic :: iso_c_binding
  use libmeshb7
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  implicit none

  character(80)           :: InpFile
  character(80)           :: OutFile
  
  integer(c_long)         :: InpMsh
  integer(c_long)         :: OutMsh
  integer(c_int)          :: NmbVer
  real(c_double), pointer :: VerTab(:,:)
  integer(c_int), pointer :: VerRef(  :)
  integer(c_int)          :: NmbQad
  integer(c_int)          :: ver
  integer(c_int)          :: dim
  type(c_ptr)             :: RefTab
  type(c_ptr)             :: QadTab
  type(c_ptr)             :: TriTab
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !if(!(InpMsh = GmfOpenMesh("../sample_meshes/quad.meshb", GmfRead, &ver, &dim)))
  interface
    function     GmfOpenMesh(name, Gmf, ver, dim) result(unit) bind(c, name="GmfOpenMesh")
        use, intrinsic :: iso_c_binding
        type(c_ptr)   , value  :: name
        integer(c_int), value  :: Gmf
        integer(c_int)         :: ver
        integer(c_int)         :: dim
        integer(c_long)        :: unit
    end function GmfOpenMesh
    
    function     GmfStatKwd(unit, Gmf) result(numb) bind(c, name="GmfStatKwd")
      use, intrinsic :: iso_c_binding
      integer(c_long), value  :: unit
      integer(c_int) , value  :: Gmf
      integer(c_int)          :: numb
    end function GmfStatKwd
    
    subroutine     GmfSetKwd(unit, Gmf, numb) bind(c, name="GmfSetKwd")
      use, intrinsic :: iso_c_binding
      integer(c_long), value  :: unit
      integer(c_int) , value  :: Gmf
      integer(c_int)          :: numb
    end subroutine GmfSetKwd
    
    subroutine     GmfCloseMesh(unit) bind(c, name="GmfCloseMesh")
      use, intrinsic :: iso_c_binding
      integer(c_long), value  :: unit
    end subroutine GmfCloseMesh
    
    !GmfGetBlock(InpMsh, GmfVertices, 1, NmbVer, 0, NULL, NULL,
    !GmfFloat, &VerTab[1][0], &VerTab[ NmbVer ][0],
    !GmfFloat, &VerTab[1][1], &VerTab[ NmbVer ][1],
    !GmfFloat, &VerTab[1][2], &VerTab[ NmbVer ][2],
    !GmfInt,   &RefTab[1],    &RefTab[ NmbVer ] );
    
    !subroutine GmfGetBlock(unit, Gmf,  )
    !
    !end subroutine

  end interface
  
  
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  InpFile='../sample_meshes/quad.mesh'
  OutFile='./tri.mesh'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   
  !block 
  !  integer               :: nChar
  !  character(:), pointer :: nameC=>null()
  !  
  !  nChar=len_trim(InpFile)                      !> print '("nChar: ",i0)',nChar
  !  allocate(character(len=nChar+1) :: nameC)
  !  nameC = trim(InpFile)  // C_NULL_CHAR
  !  
  !  InpMsh=GmfOpenMesh(name=c_loc(nameC), Gmf=GmfRead, ver=ver, dim=dim)
  !
  !end block
  
  InpMsh=GmfOpenMesh(name=convertName(name=InpFile), Gmf=GmfRead, ver=ver, dim=dim)
  
  print '(/"Input Mesh File: ",a," Idx=",i0," version: ",i0," dim: ",i0)',trim(InpFile),InpMsh,ver,dim
  if( InpMsh==0) stop ' InpMsh = 0'
  if( ver<=1   ) stop ' version <= 1'
  if( dim/=3   ) stop ' dimension <> 3'
  
  NmbVer=GmfStatKwd(unit=InpMsh, Gmf=GmfVertices)
  allocate(VerTab(1:3,1:NmbVer))
  allocate(VerRef(    1:NmbVer))
  print '("vertices  : ",i0)', NmbVer
  
  NmbQad=GmfStatKwd(unit=InpMsh, Gmf=GmfQuadrilaterals)
  !allocate(QadTab(1:4,1:NmbQad))
  !allocate(QadRef(    1:NmbQad))  
  print '("quads     : ",i0)', NmbQad


  call GmfCloseMesh(unit=InpMsh)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  OutMsh=GmfOpenMesh(name=convertName(name=OutFile), Gmf=GmfWrite, ver=ver, dim=dim)
  
  print '(/"Output Mesh File: ",a," Idx=",i0," version: ",i0," dim: ",i0)',trim(OutFile),OutMsh,ver,dim
  if( OutMsh==0) stop ' OutMsh = 0'

  call GmfSetKwd(unit=OutMsh, Gmf=GmfVertices, numb=NmbVer);
  call GmfCloseMesh(unit=OutMsh)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

contains
  
  function convertName(name) result (res)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    character(*)          :: name
    integer               :: nChar
    character(:), pointer :: nameC=>null()
    type(c_ptr)           :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>    
    nChar=len_trim(name) ! print '("nChar: ",i0)',nChar
    allocate(character(len=nChar+1) :: nameC)
    nameC=trim(name)  // C_NULL_CHAR
    res=c_loc(nameC)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  
    return
  end function convertName
  
end program test_libmeshb_block_bindC
