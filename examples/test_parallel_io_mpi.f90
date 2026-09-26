

!----------------------------------------------------------------------------!
!                                                                            !
!             PARALLEL BLOCK READ AND WRITES WITH THE LIBMESHB               !
!                                                                            !
!----------------------------------------------------------------------------!
!                                                                            !
!   Description:       open a mesh sequentialy then read & write its fields  !
!                      with several MPI processes. Also create and write an  !
!                      associated solb in parallel                           !
!   Author:            Loic MARECHAL                                         !
!                      Christophe PEYRET                                     !
!   Creation date:     sep 26 2026                                           !
!                                                                            !
!----------------------------------------------------------------------------!


!------------------------------------------------------------------------------
!
!   Version MPI (use mpi_f08) de test_parallel_io_omp.f90.
!
!   Differences avec la version OpenMP :
!     - chaque processus MPI ne traite et n'alloue QUE son bloc
!       [BegIdx:EndIdx] de sommets, triangles et tetraedres (tableaux
!       alloues avec ces bornes, d'ou des indices globaux inchanges) ;
!     - les operations sequentielles (lecture de l'entete, GmfSetKwd,
!       reouvertures GmfStopParallelWrite, fermeture finale) sont faites
!       par le rang 0 seul, encadrees par des MPI_Barrier : un processus ne
!       doit rouvrir le fichier en GmfStartParallelWrite qu'une fois que le
!       rang 0 a ecrit l'en-tete du mot-cle et ferme le fichier, et le
!       rang 0 ne doit le rouvrir en GmfStopParallelWrite qu'une fois tous
!       les blocs ecrits ;
!     - le rang 0 diffuse (MPI_Bcast) la version, la dimension, les nombres
!       d'entites et le diagnostic AIO.
!
!   Comme la version OpenMP, necessite une libMeshb compilee avec
!   -DWITH_GMF_AIO=ON, et un systeme de fichiers partage par tous les
!   processus (chaque rang ecrit ses blocs par pwrite a leur position
!   dans le fichier).
!
!   Lancement :
!     mpirun -np 4 test_parallel_io_mpi_f90 InputMesh OutputMesh OutputSolution
!------------------------------------------------------------------------------

module mod_msh_mpi

  use iso_fortran_env
  use libmeshb8
  implicit none

  type :: MshSct
     integer(int32)          :: ver, dim
     integer(int32)          :: NmbVer, NmbTri, NmbTet
     integer(int64)          :: InpMsh, OutMsh, OutSol
     character(len=256)      :: InpNam, OutNam, SolNam
     ! Blocs locaux au processus, alloues avec les bornes globales
     integer(int32)          :: VerBeg, VerEnd, TriBeg, TriEnd, TetBeg, TetEnd
     real(real64),  pointer  :: VerTab(:,:) => null()   ! (3,VerBeg:VerEnd)
     integer(int32),pointer  :: VerRef(  :) => null()   ! (  VerBeg:VerEnd)
     integer(int32),pointer  :: TriTab(:,:) => null()   ! (3,TriBeg:TriEnd)
     integer(int32),pointer  :: TriRef(  :) => null()   ! (  TriBeg:TriEnd)
     integer(int32),pointer  :: TetTab(:,:) => null()   ! (4,TetBeg:TetEnd)
     integer(int32),pointer  :: TetRef(  :) => null()   ! (  TetBeg:TetEnd)
     ! NB : l'API Fortran route toujours la reference des elements vers
     ! l'argument Ref separe (F77RefFlg dans libmeshb8.c) : Tab + Ref.
  end type MshSct

contains

  subroutine ComputeRange(Rank, NmbPrc, NmbItm, BegIdx, EndIdx)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Decoupe [1..NmbItm] en NmbPrc plages pour le processus Rank (0-based).
    ! Le reste de la division est reparti sur les premiers rangs ; si
    ! NmbItm < NmbPrc, certains rangs recoivent une plage vide
    ! (EndIdx = BegIdx - 1).
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)  :: Rank, NmbPrc, NmbItm
    integer(int32), intent(out) :: BegIdx, EndIdx
    !>
    integer(int32)              :: Chk, Rst
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    Chk    = NmbItm / NmbPrc
    Rst    = mod(NmbItm, NmbPrc)
    BegIdx = Rank * Chk + min(Rank, Rst) + 1
    EndIdx = BegIdx + Chk - 1
    if( Rank<Rst ) EndIdx = EndIdx + 1
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ComputeRange

  subroutine ScaVer(Rank, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Lecture du bloc local de sommets
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: Rank
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: InpMsh
    integer(int32)                :: ver, dim, res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if( msh%VerEnd<msh%VerBeg ) return

    InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, ver, dim)
    if( InpMsh==0 ) call StopAll(Rank, 'failed to reopen file '//trim(msh%InpNam))

    write(*,'(A,I3,A,I10,A,I10)') 'RANK ', Rank, ': read vertices   ', msh%VerBeg, ' -> ', msh%VerEnd

    res = GmfGetBlockF90(InpMsh, GmfVertices, msh%VerBeg, msh%VerEnd, &
                          msh%VerTab(:,msh%VerBeg:msh%VerEnd), msh%VerRef(msh%VerBeg:msh%VerEnd))

    res = GmfCloseMeshF90(InpMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ScaVer

  subroutine ScaTri(Rank, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Lecture du bloc local de triangles
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: Rank
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: InpMsh
    integer(int32)                :: ver, dim, res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if( msh%TriEnd<msh%TriBeg ) return

    InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, ver, dim)
    if( InpMsh==0 ) call StopAll(Rank, 'failed to reopen file '//trim(msh%InpNam))

    write(*,'(A,I3,A,I10,A,I10)') 'RANK ', Rank, ': read triangles  ', msh%TriBeg, ' -> ', msh%TriEnd

    res = GmfGetBlockF90(InpMsh, GmfTriangles, msh%TriBeg, msh%TriEnd, &
                          msh%TriTab(:,msh%TriBeg:msh%TriEnd), msh%TriRef(msh%TriBeg:msh%TriEnd))

    res = GmfCloseMeshF90(InpMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ScaTri

  subroutine ScaTet(Rank, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Lecture du bloc local de tetraedres
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: Rank
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: InpMsh
    integer(int32)                :: ver, dim, res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if( msh%TetEnd<msh%TetBeg ) return

    InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, ver, dim)
    if( InpMsh==0 ) call StopAll(Rank, 'failed to reopen file '//trim(msh%InpNam))

    write(*,'(A,I3,A,I10,A,I10)') 'RANK ', Rank, ': read tets       ', msh%TetBeg, ' -> ', msh%TetEnd

    res = GmfGetBlockF90(InpMsh, GmfTetrahedra, msh%TetBeg, msh%TetEnd, &
                          msh%TetTab(:,msh%TetBeg:msh%TetEnd), msh%TetRef(msh%TetBeg:msh%TetEnd))

    res = GmfCloseMeshF90(InpMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ScaTet

  subroutine RecVer(Rank, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture du bloc local de sommets (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: Rank
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: OutMsh
    integer(int32)                :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if( msh%VerEnd<msh%VerBeg ) return

    OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if( OutMsh==0 ) call StopAll(Rank, 'failed to reopen file '//trim(msh%OutNam))

    write(*,'(A,I3,A,I10,A,I10)') 'RANK ', Rank, ': write vertices  ', msh%VerBeg, ' -> ', msh%VerEnd

    res = GmfSetBlockF90(OutMsh, GmfVertices, msh%VerBeg, msh%VerEnd, &
                          msh%VerTab(:,msh%VerBeg:msh%VerEnd), msh%VerRef(msh%VerBeg:msh%VerEnd))

    res = GmfCloseUnfinishedMeshF90(OutMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecVer

  subroutine RecTri(Rank, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture du bloc local de triangles (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: Rank
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: OutMsh
    integer(int32)                :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if( msh%TriEnd<msh%TriBeg ) return

    OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if( OutMsh==0 ) call StopAll(Rank, 'failed to reopen file '//trim(msh%OutNam))

    write(*,'(A,I3,A,I10,A,I10)') 'RANK ', Rank, ': write triangles ', msh%TriBeg, ' -> ', msh%TriEnd

    res = GmfSetBlockF90(OutMsh, GmfTriangles, msh%TriBeg, msh%TriEnd, &
                          msh%TriTab(:,msh%TriBeg:msh%TriEnd), msh%TriRef(msh%TriBeg:msh%TriEnd))

    res = GmfCloseUnfinishedMeshF90(OutMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecTri

  subroutine RecTet(Rank, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture du bloc local de tetraedres (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: Rank
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: OutMsh
    integer(int32)                :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if( msh%TetEnd<msh%TetBeg ) return

    OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if( OutMsh==0 ) call StopAll(Rank, 'failed to reopen file '//trim(msh%OutNam))

    write(*,'(A,I3,A,I10,A,I10)') 'RANK ', Rank, ': write tets      ', msh%TetBeg, ' -> ', msh%TetEnd

    res = GmfSetBlockF90(OutMsh, GmfTetrahedra, msh%TetBeg, msh%TetEnd, &
                          msh%TetTab(:,msh%TetBeg:msh%TetEnd), msh%TetRef(msh%TetBeg:msh%TetEnd))

    res = GmfCloseUnfinishedMeshF90(OutMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecTet

  subroutine RecSol(Rank, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture du bloc local de la solution aux sommets (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: Rank
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: OutSol
    integer(int32)                :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    if( msh%VerEnd<msh%VerBeg ) return

    OutSol = GmfOpenMeshF90(trim(msh%SolNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if( OutSol==0 ) call StopAll(Rank, 'failed to reopen file '//trim(msh%SolNam))

    write(*,'(A,I3,A,I10,A,I10)') 'RANK ', Rank, ': write solution  ', msh%VerBeg, ' -> ', msh%VerEnd

    res = GmfSetBlockF90(OutSol, GmfSolAtVertices, msh%VerBeg, msh%VerEnd, &
                          msh%VerTab(:,msh%VerBeg:msh%VerEnd))

    res = GmfCloseUnfinishedMeshF90(OutSol)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecSol

  subroutine StopAll(Rank, Message)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Arret de tous les processus sur erreur
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    use mpi_f08
    integer(int32), intent(in) :: Rank
    character(*)  , intent(in) :: Message
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    write(error_unit,'(A,I0,A,A)') 'RANK ', Rank, ': ', Message
    call MPI_Abort(MPI_COMM_WORLD, 1)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  end subroutine StopAll

end module mod_msh_mpi



program parallel_io_mpi
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Programme principal : le rang 0 ouvre le maillage et diffuse ses
  ! dimensions, puis chaque processus lit et ecrit son propre bloc
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  use mpi_f08
  use libmeshb8
  use mod_msh_mpi
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  implicit none

  type(MshSct)       :: msh
  integer(int32)     :: Rank, NmbPrc, res, ArgCnt, TypTab(3)
  integer(int32)     :: Hdr(5), AioOk
  real(real64)       :: timer
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  call MPI_Init()
  call MPI_Comm_rank(MPI_COMM_WORLD, Rank  )
  call MPI_Comm_size(MPI_COMM_WORLD, NmbPrc)

  ! Lecture des arguments (identiques sur tous les rangs)
  ArgCnt = command_argument_count()
  if(ArgCnt == 3) then
    call get_command_argument(1, msh%InpNam)
    call get_command_argument(2, msh%OutNam)
    call get_command_argument(3, msh%SolNam)
  else
    if( Rank==0 ) write(*,*) 'mpirun -np N parallel_io_mpi   InputMesh   OutputMesh   OutputSolution'
    call MPI_Finalize()
    stop
  endif
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Ouverture du maillage d'entree par le rang 0, diffusion des dimensions
  if( Rank==0 )then
    msh%InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, msh%ver, msh%dim)

    if( msh%InpMsh==0 ) call StopAll(Rank, 'Unable to open the input mesh: '//trim(msh%InpNam))

    write(output_unit,'(/"Opening: ",a)')trim(msh%InpNam)
    write(*,'(A,I0,A,I0,A,I0)') 'InpMsh : idx = ', msh%InpMsh, &
         ', version = ', msh%ver, ', dimension = ', msh%dim

    msh%NmbVer = GmfStatKwdF90(msh%InpMsh, GmfVertices)
    msh%NmbTri = GmfStatKwdF90(msh%InpMsh, GmfTriangles)
    msh%NmbTet = GmfStatKwdF90(msh%InpMsh, GmfTetrahedra)

    write(*,'(A,I0)') 'InpMsh : nmb vertices  = ', msh%NmbVer
    write(*,'(A,I0)') 'InpMsh : nmb triangles = ', msh%NmbTri
    write(*,'(A,I0)') 'InpMsh : nmb tets      = ', msh%NmbTet
    write(*,'(A,I0)') 'MPI    : nmb processes = ', NmbPrc

    res = GmfCloseMeshF90(msh%InpMsh)

    Hdr = [msh%ver, msh%dim, msh%NmbVer, msh%NmbTri, msh%NmbTet]
  endif

  call MPI_Bcast(Hdr, 5, MPI_INTEGER, 0, MPI_COMM_WORLD)
  msh%ver    = Hdr(1)
  msh%dim    = Hdr(2)
  msh%NmbVer = Hdr(3)
  msh%NmbTri = Hdr(4)
  msh%NmbTet = Hdr(5)

  if( msh%dim/=3 ) call StopAll(Rank, 'Dimension must 3')

  if( msh%NmbVer==0 .or. msh%NmbTri==0 .or. msh%NmbTet==0 ) &
    call StopAll(Rank, 'This example only works on meshes made of vertices, triangles and tetrahedra')
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Decoupage et allocation des blocs locaux (bornes globales)
  call ComputeRange(Rank, NmbPrc, msh%NmbVer, msh%VerBeg, msh%VerEnd)
  call ComputeRange(Rank, NmbPrc, msh%NmbTri, msh%TriBeg, msh%TriEnd)
  call ComputeRange(Rank, NmbPrc, msh%NmbTet, msh%TetBeg, msh%TetEnd)

  allocate(msh%VerTab(3, msh%VerBeg:msh%VerEnd))
  allocate(msh%VerRef(   msh%VerBeg:msh%VerEnd))
  allocate(msh%TriTab(3, msh%TriBeg:msh%TriEnd))
  allocate(msh%TriRef(   msh%TriBeg:msh%TriEnd))
  allocate(msh%TetTab(4, msh%TetBeg:msh%TetEnd))
  allocate(msh%TetRef(   msh%TetBeg:msh%TetEnd))
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Lecture parallele des blocs
  call MPI_Barrier(MPI_COMM_WORLD)
  timer = MPI_Wtime()

  call ScaVer(Rank, msh)
  call ScaTri(Rank, msh)
  call ScaTet(Rank, msh)

  call MPI_Barrier(MPI_COMM_WORLD)
  if( Rank==0 ) write(*,'(A,F0.6,A)') 'Time for reading: ', MPI_Wtime() - timer, ' seconds'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Ecriture du maillage de sortie, en parallele (AIO)
  timer = MPI_Wtime()

  ! Rang 0 : creation du fichier et en-tete du mot-cle Vertices
  if( Rank==0 )then
    msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfWrite, msh%ver, msh%dim)
    if( msh%OutMsh==0 ) call StopAll(Rank, 'Unable to create the output mesh: '//trim(msh%OutNam))
    write(output_unit,'(/"Opening: ",a)')trim(msh%OutNam)

    res   = GmfSetKwdF90(msh%OutMsh, GmfVertices, msh%NmbVer)
    AioOk = GmfCloseUnfinishedMeshF90(msh%OutMsh)
  endif

  call MPI_Bcast(AioOk, 1, MPI_INTEGER, 0, MPI_COMM_WORLD)
  if( AioOk==0 ) call StopAll(Rank, 'Parallel I/O are not available: please recompile with -DWITH_GMF_AIO')

  call RecVer(Rank, msh)
  call MPI_Barrier(MPI_COMM_WORLD)

  ! Rang 0 : en-tete du mot-cle Triangles
  if( Rank==0 )then
    msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStopParallelWrite, msh%ver, msh%dim)
    if( msh%OutMsh==0 ) call StopAll(Rank, 'Unable to reopen the output mesh: '//trim(msh%OutNam))
    res = GmfSetKwdF90(msh%OutMsh, GmfTriangles, msh%NmbTri)
    res = GmfCloseUnfinishedMeshF90(msh%OutMsh)
  endif
  call MPI_Barrier(MPI_COMM_WORLD)

  call RecTri(Rank, msh)
  call MPI_Barrier(MPI_COMM_WORLD)

  ! Rang 0 : en-tete du mot-cle Tetrahedra
  if( Rank==0 )then
    msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStopParallelWrite, msh%ver, msh%dim)
    if( msh%OutMsh==0 ) call StopAll(Rank, 'Unable to reopen the output mesh: '//trim(msh%OutNam))
    res = GmfSetKwdF90(msh%OutMsh, GmfTetrahedra, msh%NmbTet)
    res = GmfCloseUnfinishedMeshF90(msh%OutMsh)
  endif
  call MPI_Barrier(MPI_COMM_WORLD)

  call RecTet(Rank, msh)
  call MPI_Barrier(MPI_COMM_WORLD)

  ! Rang 0 : reouverture finale en sequentiel pour clore proprement le fichier
  if( Rank==0 )then
    msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStopParallelWrite, msh%ver, msh%dim)
    if( msh%OutMsh==0 ) call StopAll(Rank, 'Unable to reopen the output mesh: '//trim(msh%OutNam))
    res = GmfCloseMeshF90(msh%OutMsh)
  endif
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Ecriture du fichier solb, en parallele (AIO)
  if( Rank==0 )then
    msh%OutSol = GmfOpenMeshF90(trim(msh%SolNam), GmfWrite, msh%ver, msh%dim)
    if( msh%OutSol==0 ) call StopAll(Rank, 'Unable to create the output sol: '//trim(msh%SolNam))
    write(output_unit,'(/"Opening: ",a)')trim(msh%SolNam)

    TypTab(1) = GmfVec
    res = GmfSetKwdF90(msh%OutSol, GmfSolAtVertices, msh%NmbVer, NmbFields=1, fields=TypTab(1:1))
    res = GmfCloseUnfinishedMeshF90(msh%OutSol)
  endif
  call MPI_Barrier(MPI_COMM_WORLD)

  call RecSol(Rank, msh)
  call MPI_Barrier(MPI_COMM_WORLD)

  if( Rank==0 )then
    msh%OutSol = GmfOpenMeshF90(trim(msh%SolNam), GmfStopParallelWrite, msh%ver, msh%dim)
    if( msh%OutSol==0 ) call StopAll(Rank, 'Unable to reopen the output sol: '//trim(msh%SolNam))
    res = GmfCloseMeshF90(msh%OutSol)

    write(*,'(A,F0.6,A)') 'Time for writing: ', MPI_Wtime() - timer, ' seconds'
  endif

  deallocate(msh%TetTab, msh%TetRef, msh%VerRef, msh%VerTab, msh%TriTab, msh%TriRef)

  call MPI_Finalize()
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end program parallel_io_mpi
