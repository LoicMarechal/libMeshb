

!----------------------------------------------------------------------------!
!                                                                            !
!             PARALLEL BLOCK READ AND WRITES WITH THE LIBMESHB               !
!                                                                            !
!----------------------------------------------------------------------------!
!                                                                            !
!   Description:       open a mesh sequentialy then read & write its fields  !
!                      in a multithread way. Also create and write an        !
!                      associated solb in parallel                           !
!   Author:            Loic MARECHAL                                         !
!                      Christophe PEYRET                                     !
!   Creation date:     sep 25 2026                                           !
!                                                                            !
!----------------------------------------------------------------------------!




!------------------------------------------------------------------------------
!
!             LECTURE ET ECRITURE PARALLELES PAR BLOCS AVEC LA LIBMESHB
!
!------------------------------------------------------------------------------
!
!   Description :  portage Fortran 90 de examples/parallel_io.c (Loic MARECHAL,
!                   creation 25/02/2025), utilisant le vrai module Fortran de
!                   la libMeshb (sources/libmeshb8_mod.f90 + libmeshb8.c,
!                   Loic MARECHAL / Christophe PEYRET).
!
!   Parallelisme :  le C original s'appuie sur la LPlib4 (InitParallel /
!                   NewType / LaunchParallel), qui n'a pas de binding
!                   Fortran. Remplacee ici par OpenMP, qui fait exactement
!                   le meme travail : decouper [1..N] en plages et faire
!                   relire/reecrire le fichier par chaque thread.
!
!   Extension necessaire de la libMeshb pour ce portage (voir plus bas et
!   les fichiers sources/libmeshb8.c, libmeshb8_mod.f90, libmeshb8.ins) :
!     1) gmfopenmeshf77() (C) forwardait tout mode != GmfRead vers
!        GmfWrite : impossible jusqu'ici d'ouvrir un fichier en
!        GmfStartParallelWrite / GmfStopParallelWrite depuis Fortran.
!        Corrige pour transmettre *mod tel quel.
!     2) GmfCloseUnfinishedMesh (C) n'avait aucun binding Fortran :
!        ajout de gmfcloseunfinishedmeshf77 (C) + GmfCloseUnfinishedMeshF90
!        (module) + declarations dans libmeshb8.ins (F77).
!     3) Les constantes gmfstartparallelwrite (16) / gmfstopparallelwrite
!        (17) n'existaient ni dans le module F90 ni dans le .ins F77.
!
!   Necessite une libMeshb compilee avec -DWITH_GMF_AIO (cf. CMakeLists.txt,
!   option WITH_GMF_AIO) pour que GmfCloseUnfinishedMesh fonctionne
!   reellement (sinon elle retourne 0, cf. message d'erreur ci-dessous).
!------------------------------------------------------------------------------

module mod_msh
  
  use iso_fortran_env
  use libmeshb8
  implicit none
  
  type :: MshSct
     integer(int32)          :: ver, dim, NmbCpu
     integer(int32)          :: NmbVer, NmbTri, NmbTet
     integer(int64)          :: InpMsh, OutMsh, OutSol
     character(len=256)      :: InpNam, OutNam, SolNam
     real(real64),  pointer  :: VerTab(:,:) => null()   ! (3,NmbVer)
     integer(int32),pointer  :: VerRef(  :) => null()   ! (NmbVer)
     integer(int32),pointer  :: TriTab(:,:) => null()   ! (3,NmbTri) v1,v2,v3
     integer(int32),pointer  :: TriRef(  :) => null()   ! (NmbTri)
     integer(int32),pointer  :: TetTab(:,:) => null()   ! (4,NmbTet) v1,v2,v3,v4
     integer(int32),pointer  :: TetRef(  :) => null()   ! (NmbTet)
     ! NB : contrairement au C (GmfIntVec,4 incluant la ref), l'API Fortran
     ! route toujours la reference des elements vers l'argument Ref separe
     ! (F77RefFlg dans libmeshb8.c) : il faut donc Tab + Ref.
  end type MshSct
  
contains
  
  subroutine ComputeRange(PthIdx, NmbThd, NmbItm, BegIdx, EndIdx)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Decoupe [1..NmbItm] en NmbThd plages pour le thread PthIdx (0-based)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)  :: PthIdx, NmbThd, NmbItm
    integer(int32), intent(out) :: BegIdx, EndIdx
    !>
    integer(int32)              :: Chk
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    Chk    = NmbItm / NmbThd
    BegIdx = PthIdx * Chk + 1
    if( PthIdx==NmbThd-1 )then
       EndIdx = NmbItm
    else
       EndIdx = BegIdx + Chk - 1
    end if
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ComputeRange
  
  subroutine ScaVer(BegIdx, EndIdx, PthIdx, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Lecture des sommets, en parallele
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: BegIdx, EndIdx, PthIdx
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: InpMsh
    integer(int32)                :: ver, dim, res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  
    InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, ver, dim)
    if(InpMsh == 0) then
       write(*,*) 'Thread', PthIdx, 'failed to reopen file', trim(msh%InpNam)
       call exit(1)
    end if
    
    write(*,'(A,I3,A,I10,A,I10)') 'THREAD ', PthIdx, ': read vertices  ', BegIdx, ' -> ', EndIdx
    
    res = GmfGetBlockF90(InpMsh, GmfVertices, BegIdx, EndIdx, &
                          msh%VerTab(:,BegIdx:EndIdx), msh%VerRef(BegIdx:EndIdx))
    
    res = GmfCloseMeshF90(InpMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ScaVer
  
  subroutine ScaTri(BegIdx, EndIdx, PthIdx, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Lecture des triangles, en parallele
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: BegIdx, EndIdx, PthIdx
    type(MshSct),   intent(inout) :: msh
    !>
    integer(int64)                :: InpMsh
    integer(int32)                :: ver, dim, res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, ver, dim)
    if(InpMsh == 0) then
      write(*,*) 'Thread', PthIdx, 'failed to reopen file', trim(msh%InpNam)
      call exit(1)
    end if
    
    write(*,'(A,I3,A,I10,A,I10)') 'THREAD ', PthIdx, ': read triangles ', BegIdx, ' -> ', EndIdx
    
    res = GmfGetBlockF90(InpMsh, GmfTriangles, BegIdx, EndIdx, &
                          msh%TriTab(:,BegIdx:EndIdx), msh%TriRef(BegIdx:EndIdx))
    
    res = GmfCloseMeshF90(InpMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ScaTri
  
  subroutine ScaTet(BegIdx, EndIdx, PthIdx, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Lecture des tetraedres, en parallele
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: BegIdx, EndIdx, PthIdx
    type(MshSct),   intent(inout) :: msh
    integer(int64) :: InpMsh
    integer(int32) :: ver, dim, res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, ver, dim)
    if(InpMsh == 0) then
      write(*,*) 'Thread', PthIdx, 'failed to reopen file', trim(msh%InpNam)
      call exit(1)
    end if
    
    write(*,'(A,I3,A,I10,A,I10)') 'THREAD ', PthIdx, ': read tets      ', BegIdx, ' -> ', EndIdx
    
    res = GmfGetBlockF90(InpMsh, GmfTetrahedra, BegIdx, EndIdx, &
                          msh%TetTab(:,BegIdx:EndIdx), msh%TetRef(BegIdx:EndIdx))
    
    res = GmfCloseMeshF90(InpMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine ScaTet
  
  subroutine RecVer(BegIdx, EndIdx, PthIdx, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture des sommets, en parallele (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: BegIdx, EndIdx, PthIdx
    type(MshSct),   intent(inout) :: msh
    !>
    integer(int64)                :: OutMsh
    integer(int32)                :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if(OutMsh == 0) then
      write(*,*) 'Thread', PthIdx, 'failed to reopen file', trim(msh%OutNam)
      call exit(1)
    end if
    
    write(*,'(A,I3,A,I10,A,I10)') 'THREAD ', PthIdx, ': write vertices  ', BegIdx, ' -> ', EndIdx
    
    res = GmfSetBlockF90(OutMsh, GmfVertices, BegIdx, EndIdx, &
                          msh%VerTab(:,BegIdx:EndIdx), msh%VerRef(BegIdx:EndIdx))
    
    res = GmfCloseUnfinishedMeshF90(OutMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecVer
  
  subroutine RecTri(BegIdx, EndIdx, PthIdx, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture des triangles, en parallele (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: BegIdx, EndIdx, PthIdx
    type(MshSct),   intent(inout) :: msh
    integer(int64) :: OutMsh
    integer(int32) :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if(OutMsh == 0) then
      write(*,*) 'Thread', PthIdx, 'failed to reopen file', trim(msh%OutNam)
      call exit(1)
    endif
    
    write(*,'(A,I3,A,I10,A,I10)') 'THREAD ', PthIdx, ': write triangles ', BegIdx, ' -> ', EndIdx
    
    res = GmfSetBlockF90(OutMsh, GmfTriangles, BegIdx, EndIdx, &
                          msh%TriTab(:,BegIdx:EndIdx), msh%TriRef(BegIdx:EndIdx))
    
    res = GmfCloseUnfinishedMeshF90(OutMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecTri
  
  subroutine RecTet(BegIdx, EndIdx, PthIdx, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture des tetraedres, en parallele (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: BegIdx, EndIdx, PthIdx
    type(MshSct),   intent(inout) :: msh
    !>
    integer(int64)                :: OutMsh
    integer(int32)                :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if(OutMsh == 0) then
      write(*,*) 'Thread', PthIdx, 'failed to reopen file', trim(msh%OutNam)
      call exit(1)
    end if
    
    write(*,'(A,I3,A,I10,A,I10)') 'THREAD ', PthIdx, ': write tets      ', BegIdx, ' -> ', EndIdx
    
    res = GmfSetBlockF90(OutMsh, GmfTetrahedra, BegIdx, EndIdx, &
                          msh%TetTab(:,BegIdx:EndIdx), msh%TetRef(BegIdx:EndIdx))
    
    res = GmfCloseUnfinishedMeshF90(OutMsh)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecTet
  
  subroutine RecSol(BegIdx, EndIdx, PthIdx, msh)
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ! Ecriture de la solution aux sommets, en parallele (AIO)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    integer(int32), intent(in)    :: BegIdx, EndIdx, PthIdx
    type(MshSct)  , intent(inout) :: msh
    !>
    integer(int64)                :: OutSol
    integer(int32)                :: res
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    OutSol = GmfOpenMeshF90(trim(msh%SolNam), GmfStartParallelWrite, msh%ver, msh%dim)
    if(OutSol == 0) then
       write(*,*) 'Thread', PthIdx, 'failed to reopen file', trim(msh%SolNam)
       call exit(1)
    end if
    
    write(*,'(A,I3,A,I10,A,I10)') 'THREAD ', PthIdx, ': write solution  ', BegIdx, ' -> ', EndIdx
    
    res = GmfSetBlockF90(OutSol, GmfSolAtVertices, BegIdx, EndIdx, &
                          msh%VerTab(:,BegIdx:EndIdx))
    
    res = GmfCloseUnfinishedMeshF90(OutSol)
    !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    return
  end subroutine RecSol
  
end module mod_msh



program parallel_io_omp
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Programme principal : ouvre et alloue le maillage en sequentiel, puis
  ! le lit et l'ecrit en parallele
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  use iso_fortran_env
  use omp_lib
  use libmeshb8
  use mod_msh
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  implicit none
  
  type(MshSct)       :: msh
  integer(int32)     :: PthIdx, NmbThd, i, res, ArgCnt, TypTab(3)
  integer(int32)     :: BegIdx, EndIdx
  real(real64)       :: timer
  character(len=256) :: arg
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Lecture des arguments
  ArgCnt = command_argument_count()
  if(ArgCnt == 4) then
    call get_command_argument(1, msh%InpNam)
    call get_command_argument(2, msh%OutNam)
    call get_command_argument(3, msh%SolNam)
    call get_command_argument(4, arg)
    read(arg, *) msh%NmbCpu
  else
    write(*,*) 'parallel_io   InputMesh   OutputMesh   OutputSolution   NmbThreads'
    stop
  endif
  
  call omp_set_num_threads(msh%NmbCpu)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ! Ouverture du maillage d'entree
  
  msh%InpMsh = GmfOpenMeshF90(trim(msh%InpNam), GmfRead, msh%ver, msh%dim)
  
  if(msh%InpMsh == 0) then
    write(*,*) 'Unable to open the input mesh: ', trim(msh%InpNam)
    call exit(1)
  else
    write(output_unit,'(/"Opening: ",a)')trim(msh%InpNam)
  endif
  
  write(*,'(A,I0,A,I0,A,I0)') 'InpMsh : idx = ', msh%InpMsh, &
       ', version = ', msh%ver, ', dimension = ', msh%dim
  
  if(msh%dim /= 3) then
    write(*,*) 'Dimension must 3'
    call exit(1)
  end if
  
  msh%NmbVer = GmfStatKwdF90(msh%InpMsh, GmfVertices)
  write(*,'(A,I0)') 'InpMsh : nmb vertices  = ', msh%NmbVer
  
  msh%NmbTri = GmfStatKwdF90(msh%InpMsh, GmfTriangles)
  write(*,'(A,I0)') 'InpMsh : nmb triangles = ', msh%NmbTri
  
  msh%NmbTet = GmfStatKwdF90(msh%InpMsh, GmfTetrahedra)
  write(*,'(A,I0)') 'InpMsh : nmb tets      = ', msh%NmbTet
  
  if(msh%NmbVer == 0 .or. msh%NmbTri == 0 .or. msh%NmbTet == 0) then
    write(*,*) 'This example only works on meshes made of vertices, ', &
               'triangles and tetrahedra'
    call exit(1)
  endif
  
  allocate(msh%VerTab(3, msh%NmbVer))
  allocate(msh%VerRef(   msh%NmbVer))
  allocate(msh%TriTab(3, msh%NmbTri))
  allocate(msh%TriRef(   msh%NmbTri))
  allocate(msh%TetTab(4, msh%NmbTet))
  allocate(msh%TetRef(   msh%NmbTet))
  
  res = GmfCloseMeshF90(msh%InpMsh)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Lecture parallele des champs
  timer = omp_get_wtime()
  
  !$omp parallel private(PthIdx, NmbThd, BegIdx, EndIdx)
  PthIdx = omp_get_thread_num()
  NmbThd = omp_get_num_threads()
  
  call ComputeRange(PthIdx, NmbThd, msh%NmbVer, BegIdx, EndIdx)
  call ScaVer(BegIdx, EndIdx, PthIdx, msh)
  !$omp barrier
  
  call ComputeRange(PthIdx, NmbThd, msh%NmbTri, BegIdx, EndIdx)
  call ScaTri(BegIdx, EndIdx, PthIdx, msh)
  !$omp barrier
  
  call ComputeRange(PthIdx, NmbThd, msh%NmbTet, BegIdx, EndIdx)
  call ScaTet(BegIdx, EndIdx, PthIdx, msh)
  !$omp end parallel
  
  write(*,'(A,F0.6,A)') 'Time for reading: ', omp_get_wtime() - timer, ' seconds'
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Ecriture du maillage de sortie, en parallele (AIO)
  timer = omp_get_wtime()
  
  msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfWrite, msh%ver, msh%dim)
  if(msh%OutMsh == 0) then
    write(*,*) 'Unable to create the output mesh: ', trim(msh%OutNam)
    call exit(1)
  else
    write(output_unit,'(/"Opening: ",a)')trim(msh%OutNam)
  endif
  
  res = GmfSetKwdF90(msh%OutMsh, GmfVertices, msh%NmbVer)
  
  if(GmfCloseUnfinishedMeshF90(msh%OutMsh) == 0) then
    write(*,*) 'Parallel I/O are not available: please recompile with -DWITH_GMF_AIO'
    call exit(1)
  endif
  
  !$omp parallel private(PthIdx, NmbThd, BegIdx, EndIdx)
  PthIdx = omp_get_thread_num()
  NmbThd = omp_get_num_threads()
  call ComputeRange(PthIdx, NmbThd, msh%NmbVer, BegIdx, EndIdx)
  call RecVer(BegIdx, EndIdx, PthIdx, msh)
  !$omp end parallel

  msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStopParallelWrite, msh%ver, msh%dim)
  if(msh%OutMsh == 0) then
    write(*,*) 'Unable to reopen the output mesh: ', trim(msh%OutNam)
    call exit(1)
  endif
  
  res = GmfSetKwdF90(msh%OutMsh, GmfTriangles, msh%NmbTri)
  res = GmfCloseUnfinishedMeshF90(msh%OutMsh)
  
  !$omp parallel private(PthIdx, NmbThd, BegIdx, EndIdx)
  PthIdx = omp_get_thread_num()
  NmbThd = omp_get_num_threads()
  call ComputeRange(PthIdx, NmbThd, msh%NmbTri, BegIdx, EndIdx)
  call RecTri(BegIdx, EndIdx, PthIdx, msh)
  !$omp end parallel
  
  msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStopParallelWrite, msh%ver, msh%dim)
  if(msh%OutMsh == 0) then
     write(*,*) 'Unable to reopen the output mesh: ', trim(msh%OutNam)
     call exit(1)
  endif
  
  res = GmfSetKwdF90(msh%OutMsh, GmfTetrahedra, msh%NmbTet)
  res = GmfCloseUnfinishedMeshF90(msh%OutMsh)
  
  !$omp parallel private(PthIdx, NmbThd, BegIdx, EndIdx)
  PthIdx = omp_get_thread_num()
  NmbThd = omp_get_num_threads()
  call ComputeRange(PthIdx, NmbThd, msh%NmbTet, BegIdx, EndIdx)
  call RecTet(BegIdx, EndIdx, PthIdx, msh)
  !$omp end parallel
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  
  ! Reouverture finale en sequentiel pour clore proprement le fichier
  msh%OutMsh = GmfOpenMeshF90(trim(msh%OutNam), GmfStopParallelWrite, msh%ver, msh%dim)
  if(msh%OutMsh == 0) then
     write(*,*) 'Unable to reopen the output mesh: ', trim(msh%OutNam)
     call exit(1)
  end if
  
  res = GmfCloseMeshF90(msh%OutMsh)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !> Ecriture du fichier solb, en parallele (AIO)
  msh%OutSol = GmfOpenMeshF90(trim(msh%SolNam), GmfWrite, msh%ver, msh%dim)
  if(msh%OutSol == 0) then
    write(*,*) 'Unable to create the output sol: ', trim(msh%SolNam)
    call exit(1)
  else
    write(output_unit,'(/"Opening: ",a)')trim(msh%SolNam)
  endif
  
  TypTab(1) = GmfVec
  res = GmfSetKwdF90(msh%OutSol, GmfSolAtVertices, msh%NmbVer, NmbFields=1, fields=TypTab(1:1))
  
  if(GmfCloseUnfinishedMeshF90(msh%OutSol) == 0) then
    write(*,*) 'Parallel I/O are not available: please recompile with -DWITH_GMF_AIO'
    call exit(1)
  endif
  
  !$omp parallel private(PthIdx, NmbThd, BegIdx, EndIdx)
  PthIdx = omp_get_thread_num()
  NmbThd = omp_get_num_threads()
  call ComputeRange(PthIdx, NmbThd, msh%NmbVer, BegIdx, EndIdx)
  call RecSol(BegIdx, EndIdx, PthIdx, msh)
  !$omp end parallel
  
  ! Reouverture finale en sequentiel pour clore proprement le fichier
  ! (le C original rouvrait ici msh.OutNam par erreur au lieu de msh.SolNam :
  !  corrige dans ce portage)
  msh%OutSol = GmfOpenMeshF90(trim(msh%SolNam), GmfStopParallelWrite, msh%ver, msh%dim)
  if(msh%OutSol == 0) then
    write(*,*) 'Unable to reopen the output mesh: ', trim(msh%SolNam)
    call exit(1)
  endif
  
  res = GmfCloseMeshF90(msh%OutSol)
  
  write(*,'(A,F0.6,A)') 'Time for writing: ', omp_get_wtime() - timer, ' seconds'
  
  deallocate(msh%TetTab, msh%TetRef, msh%VerRef, msh%VerTab, msh%TriTab, msh%TriRef)
  !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  
end program parallel_io_omp
