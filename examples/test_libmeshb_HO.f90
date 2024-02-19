
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
    integer(8)            :: InpMsh, OutMsh, m(1)
    character(80)         :: InpFile
    character(80)         :: OutFile
    integer               :: i,iTria
    integer               :: NmbVer,NmbQad,NmbTri,ver,dim,res
      real(real64)          :: sol(1:10)
    real(real64), pointer :: VerTab(:,:)
    integer     , pointer :: VerRef(  :)
    integer     , pointer :: QadTab(:,:),QadRef(  :)
    integer     , pointer :: TriTab(:,:),TriRef(  :)
    integer               :: t(1),d,ho,s
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    print '(/"test_libmeshb_HO_f90")'
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    InpFile='../sample_meshes/quad_q2.mesh'
    OutFile='./tri_p2.mesh'
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
    NmbQad=Gmfstatkwdf77(InpMsh, GmfQuadrilateralsQ2, 0, s, t, d, ho)  
    allocate(QadTab(1:9,1:NmbQad))
    allocate(QadRef(    1:NmbQad))
    
    print '("Input mesh : ",i0," vertices: ",i0," quadsQ2")',NmbVer,NmbQad
    
    print '("input mesh: ",i0)', InpMsh
    print '("version   : ",i0)', ver
    print '("dimension : ",i0)', dim
    print '("vertices  : ",i0)', NmbVer
    print '("quadsQ2   : ",i0)', NmbQad
    
    ! Read the vertices using a vector of 3 consecutive doubles to store the coordinates
    res=GmfGetVertices(                &
    &   InpMsh                        ,&
    &   1                             ,&
    &   NmbVer                        ,&
    &   0, m                          ,&
    &   VerTab(1,1), VerTab(1,NmbVer) ,&
    &   VerRef(  1), VerRef(  NmbVer)  )
    
    ! Read the quads using one single vector of 5 consecutive integers
    res=GmfGetElements(               &
    &   InpMsh                       ,&
    &   GmfQuadrilateralsQ2          ,&
    &   1                            ,& 
    &   NmbQad                       ,&
    &   0, m                         ,&
    &   QadTab(1,1), QadTab(1,NmbQad),&
    &   QadRef(  1), QadRef(  NmbQad) )
      
    ! Close the quadrilateral mesh
    res=GmfCloseMeshf77(InpMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      
    ! Allocate TriTab and TriRef
    NmbTri=2*NmbQad
    allocate(TriTab(1:6,1:NmbTri))
    allocate(TriRef(    1:NmbTri))
    
    ! Convert the quad Q2 mesh into a triangular P2 one
    do i=1,NmbQad
       iTria=2*i-1
       TriTab(1,iTria) = QadTab(1,i)
       TriTab(2,iTria) = QadTab(3,i)
       TriTab(3,iTria) = QadTab(9,i)
       TriTab(4,iTria) = QadTab(2,i)
       TriTab(5,iTria) = QadTab(6,i)
       TriTab(6,iTria) = QadTab(5,i)
       TriRef(  iTria) = QadRef(  i)
       
       iTria=2*i
       TriTab(1,iTria) = QadTab(1,i)
       TriTab(2,iTria) = QadTab(9,i)
       TriTab(3,iTria) = QadTab(7,i)
       TriTab(4,iTria) = QadTab(5,i)
       TriTab(5,iTria) = QadTab(8,i)
       TriTab(6,iTria) = QadTab(5,i)
       TriRef(  iTria) = QadRef(  i)
    enddo
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Write a triangular mesh
       
    OutMsh = GmfOpenMeshf77(trim(OutFile), GmfWrite, ver, dim)
    print '(/"Output Mesh File: ",a," Idx=",i0," version: ",i0," dim: ",i0)',trim(OutFile),OutMsh,ver,dim
    print '( "vertices   : ",i0)', NmbVer
    print '( "triangleP2 : ",i0)', NmbTri

    if(OutMsh==0) STOP ' OutMsh = 0'
    
    ! Set the number of vertices
    res=Gmfsetkwdf77(OutMsh, GmfVertices, NmbVer, 0, t, 0, ho)
    
    ! Write them down using separate pointers for each scalar entry
    res=Gmfsetvertices(               &
    &   OutMsh                       ,&
    &   1                            ,&
    &   NmbVer                       ,&
    &   0, m                         ,&
    &   VerTab(1,1), VerTab(1,NmbVer),&
    &   VerRef(  1), VerRef(  NmbVer) )
    
    ! Write the triangles using 4 independant set of arguments 
    ! for each scalar entry: node1, node2, node3 and reference
    res=Gmfsetkwdf77(OutMsh, GmfTrianglesP2, NmbTri, 0, t, 0, ho)

    res = GmfSetElements(               &
    &     OutMsh                       ,&
    &     GmfTrianglesP2               ,&
    &     1                            ,&
    &     NmbTri                       ,&
    &     0, m                         ,&
    &     TriTab(1,1), TriTab(1,NmbTri),&
    &     TriRef(  1), TriRef(  NmbTri) )
    
    ! Don't forget to close the file
    res=GmfCloseMeshf77(OutMsh)
    
    print '("output mesh :",i0," vertices: ",i0," triangles")',NmbVer,NmbTri
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    !> Cleanning Memory
    deallocate(VerTab,VerRef)
    deallocate(QadTab,QadRef)
    deallocate(TriTab,TriRef)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    print '(/"vizir4 -in ",a)',trim(OutFile)
    print '(/"test_libmeshb_HO_f90")'
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end program test_libmeshb_HO_f90
  
  