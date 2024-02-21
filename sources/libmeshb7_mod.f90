!----------------------------------------------------------
!
!                       LIBMESH V 7.79
! 
!----------------------------------------------------------
!
!   Description:         handles .meshb file format I/O
!   Author:              Loic MARECHAL
!   Creation date:       dec 08 2015
!   Last modification:   feb 12 2024
!
!----------------------------------------------------------

  module libmeshb7
    
    use iso_fortran_env
    use, intrinsic :: iso_c_binding, only: c_int,c_long,c_loc,c_ptr
    
    implicit none
    
    !Procedures definition
    external gmfopenmeshf77
    external gmfclosemeshf77
    external gmfstatkwdf77
    external gmfsetkwdf77
    external gmfgotokwdf77
    external gmfsethonodesorderingf77
    external gmfgetvertex
    external gmfsetvertex
    external gmfgetelement
    external gmfsetelement
    external gmfgetvertices
    external gmfsetvertices
    external gmfgetelements
    external gmfsetelements
    external gmfgetsolution
    external gmfsetsolution

  
    integer(int64) gmfopenmeshf77
    integer(int32) gmfclosemeshf77
    integer(int32) gmfstatkwdf77
    integer(int32) gmfsetkwdf77
    integer(int32) gmfgotokwdf77
    integer(int32) gmfsethonodesorderingf77
    integer(int32) gmfgetvertex
    integer(int32) gmfsetvertex
    integer(int32) gmfgetelement
    integer(int32) gmfsetelement
    integer(int32) gmfgetvertices
    integer(int32) gmfsetvertices
    integer(int32) gmfgetelements
    integer(int32) gmfsetelements
    integer(int32) gmfgetsolution
    integer(int32) gmfsetsolution
  
  
    ! Parameters definition

    integer(int32), parameter :: gmfmaxtyp=1000
    integer(int32), parameter :: gmfmaxkwd=227
    integer(int32), parameter :: gmfread=1
    integer(int32), parameter :: gmfwrite=2
    integer(int32), parameter :: gmfsca=1
    integer(int32), parameter :: gmfvec=2
    integer(int32), parameter :: gmfsymmat=3
    integer(int32), parameter :: gmfmat=4
    integer(int32), parameter :: gmffloat=8
    integer(int32), parameter :: gmfdouble=9
    integer(int32), parameter :: gmfint=10
    integer(int32), parameter :: gmflong=11
    integer(int32), parameter :: gmfinttab=14
    integer(int32), parameter :: gmflongtab=15
    integer(int32), parameter :: gmffloatvec=12
    integer(int32), parameter :: gmfdoublevec=13
    integer(int32), parameter :: gmfintvec=14
    integer(int32), parameter :: gmflongvec=15
    integer(int32), parameter :: gmfargtab=100
    integer(int32), parameter :: gmfarglst=101
  
  
    ! Keywords list
      
    integer(int32), parameter :: gmfdimension=3
    integer(int32), parameter :: gmfmeshversionformatted=1
    integer(int32), parameter :: gmfvertices=4
    integer(int32), parameter :: gmfedges=5
    integer(int32), parameter :: gmftriangles=6
    integer(int32), parameter :: gmfquadrilaterals=7
    integer(int32), parameter :: gmftetrahedra=8
    integer(int32), parameter :: gmfprisms=9
    integer(int32), parameter :: gmfhexahedra=10
    integer(int32), parameter :: gmfiterationsall=11
    integer(int32), parameter :: gmftimesall=12
    integer(int32), parameter :: gmfcorners=13
    integer(int32), parameter :: gmfridges=14
    integer(int32), parameter :: gmfrequiredvertices=15
    integer(int32), parameter :: gmfrequirededges=16
    integer(int32), parameter :: gmfrequiredtriangles=17
    integer(int32), parameter :: gmfrequiredquadrilaterals=18
    integer(int32), parameter :: gmftangentatedgevertices=19
    integer(int32), parameter :: gmfnormalatvertices=20
    integer(int32), parameter :: gmfnormalattrianglevertices=21
    integer(int32), parameter :: gmfnormalatquadrilateralvertices=22
    integer(int32), parameter :: gmfangleofcornerbound=23
    integer(int32), parameter :: gmftrianglesp2=24
    integer(int32), parameter :: gmfedgesp2=25
    integer(int32), parameter :: gmfsolatpyramids=26
    integer(int32), parameter :: gmfquadrilateralsq2=27
    integer(int32), parameter :: gmfisolatpyramids=28
    integer(int32), parameter :: gmfsubdomainfromgeom=29
    integer(int32), parameter :: gmftetrahedrap2=30
    integer(int32), parameter :: gmffault_neartri=31
    integer(int32), parameter :: gmffault_inter=32
    integer(int32), parameter :: gmfhexahedraq2=33
    integer(int32), parameter :: gmfextraverticesatedges=34
    integer(int32), parameter :: gmfextraverticesattriangles=35
    integer(int32), parameter :: gmfextraverticesatquadrilaterals=36
    integer(int32), parameter :: gmfextraverticesattetrahedra=37
    integer(int32), parameter :: gmfextraverticesatprisms=38
    integer(int32), parameter :: gmfextraverticesathexahedra=39
    integer(int32), parameter :: gmfverticesongeometricvertices=40
    integer(int32), parameter :: gmfverticesongeometricedges=41
    integer(int32), parameter :: gmfverticesongeometrictriangles=42
    integer(int32), parameter :: gmfverticesongeometricquadrilaterals=43
    integer(int32), parameter :: gmfedgesongeometricedges=44
    integer(int32), parameter :: gmffault_freeedge=45
    integer(int32), parameter :: gmfpolyhedra=46
    integer(int32), parameter :: gmfpolygons=47
    integer(int32), parameter :: gmffault_overlap=48
    integer(int32), parameter :: gmfpyramids=49
    integer(int32), parameter :: gmfboundingbox=50
    integer(int32), parameter :: gmfbody=51
    integer(int32), parameter :: gmfprivatetable=52
    integer(int32), parameter :: gmffault_badshape=53
    integer(int32), parameter :: gmfend=54
    integer(int32), parameter :: gmftrianglesongeometrictriangles=55
    integer(int32), parameter :: gmftrianglesongeometricquadrilaterals=56
    integer(int32), parameter :: gmfquadrilateralsongeometrictriangles=57
    integer(int32), parameter :: gmfquadrilateralsongeometricquadrilaterals=58
    integer(int32), parameter :: gmftangents=59
    integer(int32), parameter :: gmfnormals=60
    integer(int32), parameter :: gmftangentatvertices=61
    integer(int32), parameter :: gmfsolatvertices=62
    integer(int32), parameter :: gmfsolatedges=63
    integer(int32), parameter :: gmfsolattriangles=64
    integer(int32), parameter :: gmfsolatquadrilaterals=65
    integer(int32), parameter :: gmfsolattetrahedra=66
    integer(int32), parameter :: gmfsolatprisms=67
    integer(int32), parameter :: gmfsolathexahedra=68
    integer(int32), parameter :: gmfdsolatvertices=69
    integer(int32), parameter :: gmfisolatvertices=70
    integer(int32), parameter :: gmfisolatedges=71
    integer(int32), parameter :: gmfisolattriangles=72
    integer(int32), parameter :: gmfisolatquadrilaterals=73
    integer(int32), parameter :: gmfisolattetrahedra=74
    integer(int32), parameter :: gmfisolatprisms=75
    integer(int32), parameter :: gmfisolathexahedra=76
    integer(int32), parameter :: gmfiterations=77
    integer(int32), parameter :: gmftime=78
    integer(int32), parameter :: gmffault_smalltri=79
    integer(int32), parameter :: gmfcoarsehexahedra=80
    integer(int32), parameter :: gmfcomments=81
    integer(int32), parameter :: gmfperiodicvertices=82
    integer(int32), parameter :: gmfperiodicedges=83
    integer(int32), parameter :: gmfperiodictriangles=84
    integer(int32), parameter :: gmfperiodicquadrilaterals=85
    integer(int32), parameter :: gmfprismsp2=86
    integer(int32), parameter :: gmfpyramidsp2=87
    integer(int32), parameter :: gmfquadrilateralsq3=88
    integer(int32), parameter :: gmfquadrilateralsq4=89
    integer(int32), parameter :: gmftrianglesp3=90
    integer(int32), parameter :: gmftrianglesp4=91
    integer(int32), parameter :: gmfedgesp3=92
    integer(int32), parameter :: gmfedgesp4=93
    integer(int32), parameter :: gmfirefgroups=94
    integer(int32), parameter :: gmfdrefgroups=95
    integer(int32), parameter :: gmftetrahedrap3=96
    integer(int32), parameter :: gmftetrahedrap4=97
    integer(int32), parameter :: gmfhexahedraq3=98
    integer(int32), parameter :: gmfhexahedraq4=99
    integer(int32), parameter :: gmfpyramidsp3=100
    integer(int32), parameter :: gmfpyramidsp4=101
    integer(int32), parameter :: gmfprismsp3=102
    integer(int32), parameter :: gmfprismsp4=103
    integer(int32), parameter :: gmfhosolatedgesp1=104
    integer(int32), parameter :: gmfhosolatedgesp2=105
    integer(int32), parameter :: gmfhosolatedgesp3=106
    integer(int32), parameter :: gmfhosolattrianglesp1=107
    integer(int32), parameter :: gmfhosolattrianglesp2=108
    integer(int32), parameter :: gmfhosolattrianglesp3=109
    integer(int32), parameter :: gmfhosolatquadrilateralsq1=110
    integer(int32), parameter :: gmfhosolatquadrilateralsq2=111
    integer(int32), parameter :: gmfhosolatquadrilateralsq3=112
    integer(int32), parameter :: gmfhosolattetrahedrap1=113
    integer(int32), parameter :: gmfhosolattetrahedrap2=114
    integer(int32), parameter :: gmfhosolattetrahedrap3=115
    integer(int32), parameter :: gmfhosolatpyramidsp1=116
    integer(int32), parameter :: gmfhosolatpyramidsp2=117
    integer(int32), parameter :: gmfhosolatpyramidsp3=118
    integer(int32), parameter :: gmfhosolatprismsp1=119
    integer(int32), parameter :: gmfhosolatprismsp2=120
    integer(int32), parameter :: gmfhosolatprismsp3=121
    integer(int32), parameter :: gmfhosolathexahedraq1=122
    integer(int32), parameter :: gmfhosolathexahedraq2=123
    integer(int32), parameter :: gmfhosolathexahedraq3=124
    integer(int32), parameter :: gmfbezierbasis=125
    integer(int32), parameter :: gmfbyteflow=126
    integer(int32), parameter :: gmfedgesp2ordering=127
    integer(int32), parameter :: gmfedgesp3ordering=128
    integer(int32), parameter :: gmftrianglesp2ordering=129
    integer(int32), parameter :: gmftrianglesp3ordering=130
    integer(int32), parameter :: gmfquadrilateralsq2ordering=131
    integer(int32), parameter :: gmfquadrilateralsq3ordering=132
    integer(int32), parameter :: gmftetrahedrap2ordering=133
    integer(int32), parameter :: gmftetrahedrap3ordering=134
    integer(int32), parameter :: gmfpyramidsp2ordering=135
    integer(int32), parameter :: gmfpyramidsp3ordering=136
    integer(int32), parameter :: gmfprismsp2ordering=137
    integer(int32), parameter :: gmfprismsp3ordering=138
    integer(int32), parameter :: gmfhexahedraq2ordering=139
    integer(int32), parameter :: gmfhexahedraq3ordering=140
    integer(int32), parameter :: gmfedgesp1ordering=141
    integer(int32), parameter :: gmfedgesp4ordering=142
    integer(int32), parameter :: gmftrianglesp1ordering=143
    integer(int32), parameter :: gmftrianglesp4ordering=144
    integer(int32), parameter :: gmfquadrilateralsq1ordering=145
    integer(int32), parameter :: gmfquadrilateralsq4ordering=146
    integer(int32), parameter :: gmftetrahedrap1ordering=147
    integer(int32), parameter :: gmftetrahedrap4ordering=148
    integer(int32), parameter :: gmfpyramidsp1ordering=149
    integer(int32), parameter :: gmfpyramidsp4ordering=150
    integer(int32), parameter :: gmfprismsp1ordering=151
    integer(int32), parameter :: gmfprismsp4ordering=152
    integer(int32), parameter :: gmfhexahedraq1ordering=153
    integer(int32), parameter :: gmfhexahedraq4ordering=154
    integer(int32), parameter :: gmffloatingpointprecision=155
    integer(int32), parameter :: gmfhosolatedgesp4=156
    integer(int32), parameter :: gmfhosolattrianglesp4=157
    integer(int32), parameter :: gmfhosolatquadrilateralsq4=158
    integer(int32), parameter :: gmfhosolattetrahedrap4=159
    integer(int32), parameter :: gmfhosolatpyramidsp4=160
    integer(int32), parameter :: gmfhosolatprismsp4=161
    integer(int32), parameter :: gmfhosolathexahedraq4=162
    integer(int32), parameter :: gmfhosolatedgesp1nodespositions=163
    integer(int32), parameter :: gmfhosolatedgesp2nodespositions=164
    integer(int32), parameter :: gmfhosolatedgesp3nodespositions=165
    integer(int32), parameter :: gmfhosolatedgesp4nodespositions=166
    integer(int32), parameter :: gmfhosolattrianglesp1nodespositions=167
    integer(int32), parameter :: gmfhosolattrianglesp2nodespositions=168
    integer(int32), parameter :: gmfhosolattrianglesp3nodespositions=169
    integer(int32), parameter :: gmfhosolattrianglesp4nodespositions=170
    integer(int32), parameter :: gmfhosolatquadrilateralsq1nodespositions=171
    integer(int32), parameter :: gmfhosolatquadrilateralsq2nodespositions=172
    integer(int32), parameter :: gmfhosolatquadrilateralsq3nodespositions=173
    integer(int32), parameter :: gmfhosolatquadrilateralsq4nodespositions=174
    integer(int32), parameter :: gmfhosolattetrahedrap1nodespositions=175
    integer(int32), parameter :: gmfhosolattetrahedrap2nodespositions=176
    integer(int32), parameter :: gmfhosolattetrahedrap3nodespositions=177
    integer(int32), parameter :: gmfhosolattetrahedrap4nodespositions=178
    integer(int32), parameter :: gmfhosolatpyramidsp1nodespositions=179
    integer(int32), parameter :: gmfhosolatpyramidsp2nodespositions=180
    integer(int32), parameter :: gmfhosolatpyramidsp3nodespositions=181
    integer(int32), parameter :: gmfhosolatpyramidsp4nodespositions=182
    integer(int32), parameter :: gmfhosolatprismsp1nodespositions=183
    integer(int32), parameter :: gmfhosolatprismsp2nodespositions=184
    integer(int32), parameter :: gmfhosolatprismsp3nodespositions=185
    integer(int32), parameter :: gmfhosolatprismsp4nodespositions=186
    integer(int32), parameter :: gmfhosolathexahedraq1nodespositions=187
    integer(int32), parameter :: gmfhosolathexahedraq2nodespositions=188
    integer(int32), parameter :: gmfhosolathexahedraq3nodespositions=189
    integer(int32), parameter :: gmfhosolathexahedraq4nodespositions=190
    integer(int32), parameter :: gmfedgesreferenceelement=191
    integer(int32), parameter :: gmftrianglereferenceelement=192
    integer(int32), parameter :: gmfquadrilateralreferenceelement=193
    integer(int32), parameter :: gmftetrahedronreferenceelement=194
    integer(int32), parameter :: gmfpyramidreferenceelement=195
    integer(int32), parameter :: gmfprismreferenceelement=196
    integer(int32), parameter :: gmfhexahedronreferenceelement=197
    integer(int32), parameter :: gmfboundarylayers=198
    integer(int32), parameter :: gmfreferencestrings=199
    integer(int32), parameter :: gmfprisms9=200
    integer(int32), parameter :: gmfhexahedra12=201
    integer(int32), parameter :: gmfquadrilaterals6=202
    integer(int32), parameter :: gmfboundarypolygonheaders=203
    integer(int32), parameter :: gmfboundarypolygonvertices=204
    integer(int32), parameter :: gmfinnerpolygonheaders=205
    integer(int32), parameter :: gmfinnerpolygonvertices=206
    integer(int32), parameter :: gmfpolyhedraheaders=207
    integer(int32), parameter :: gmfpolyhedrafaces=208
    integer(int32), parameter :: gmfdomains=209
    integer(int32), parameter :: gmfverticesgid=210
    integer(int32), parameter :: gmfedgesgid=211
    integer(int32), parameter :: gmftrianglesgid=212
    integer(int32), parameter :: gmfquadrilateralsgid=213
    integer(int32), parameter :: gmftetrahedragid=214
    integer(int32), parameter :: gmfpyramidsgid=215
    integer(int32), parameter :: gmfprismsgid=216
    integer(int32), parameter :: gmfhexahedragid=217
    integer(int32), parameter :: gmfsolatboundarypolygons=218
    integer(int32), parameter :: gmfsolatpolyhedra=219
    integer(int32), parameter :: gmfverticesongeometrynodes=220
    integer(int32), parameter :: gmfverticesongeometryedges=221
    integer(int32), parameter :: gmfedgesongeometryedges=222
    integer(int32), parameter :: gmfverticesongeometryfaces=223
    integer(int32), parameter :: gmfedgesongeometryfaces=224
    integer(int32), parameter :: gmftrianglesongeometryfaces=225
    integer(int32), parameter :: gmfquadrialteralsongeometryfaces=226
    integer(int32), parameter :: gmfmeshongeometry=227
  
  !   !> interface GmfSetHONodesOrdering_c  
  !   interface
  !     function GmfSetHONodesOrdering_c(InpMsh, GmfKey, BasOrd, FilOrd) result(iErr) bind(c, name="GmfSetHONodesOrdering")
  !       !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !       import c_long,c_int,c_ptr
  !       !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !       !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !       integer(c_long)     , intent(in)        :: InpMsh
  !       integer(c_int)      , intent(in)        :: GmfKey
  !      !integer(c_int)      , intent(in)        :: BasOrd(:,:)
  !      !integer(c_int)      , intent(in)        :: FilOrd(:,:)
  !       type(c_ptr)         , intent(in)        :: BasOrd
  !       type(c_ptr)         , intent(in)        :: FilOrd
  !       integer(c_int)                          :: iErr
  !       !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     end function GmfSetHONodesOrdering_c    
  !     
  !     function GmfCloseMesh_c(InpMsh) result(iErr) bind(c, name="GmfCloseMesh")
  !       !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !       import c_long,c_int,c_ptr
  !       !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !       !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !       integer(c_long)     , intent(in)        :: InpMsh
  !       integer(c_int)                          :: iErr
  !       !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     end function GmfCloseMesh_c
  !     
  !   end interface
  !   
  !   
  !   public :: GmfSetHONodesOrdering_f90
  !   public :: GmfOpenMesh_f90
  !   public :: GmfCloseMesh_f90
    
    
    !> les lignes suivantes sont en conflit avec la variable integer(4) :: gmfsethonodesordering
    !interface GmfSetHONodesOrdering
    !  module procedure GmfSetHONodesOrdering_f90
    !  module procedure GmfSetHONodesOrdering_c
    !end interface
    
  contains
      
  !   subroutine GmfSetHONodesOrdering_f90(unit, GmfKey, BasOrd, FilOrd)
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     use, intrinsic :: iso_c_binding, only: c_loc,c_int,c_long,c_ptr
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     integer(8), intent(in)          :: unit
  !     integer(4), intent(in)          :: GmfKey
  !     integer(4), intent(in), pointer :: BasOrd(:,:)
  !     integer(4), intent(in), pointer :: FilOrd(:,:)
  !     !>
  !     integer(c_int)                  :: iErr
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     !> Broker
  !     iErr=GmfSetHONodesOrdering_c(            & 
  !     &    InpMsh=int(unit,kind=c_long)       ,&
  !     &    GmfKey=int(GmfKey,kind=c_int)      ,&
  !     &    BasOrd=c_loc(BasOrd)               ,&
  !     &    FilOrd=c_loc(FilOrd)                )
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     
  !     return
  !   end subroutine GmfSetHONodesOrdering_f90
  !   
  !   subroutine GmfOpenMesh_f90(unit, GmfKey, BasOrd, FilOrd)
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     use, intrinsic :: iso_c_binding, only: c_loc,c_int,c_long
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     integej1r(8), intent(in)          :: unit
  !     !>
  !     integer(c_int)                  :: iErr
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     !> Broker
  !     iErr=GmfOpenMesh_c(InpMsh=int(unit,kind=c_long)  )
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     return
  !   end subroutine GmfOpenMesh_f90
  !   
  !   subroutine GmfCloseMesh_f90(unit, GmfKey, BasOrd, FilOrd)
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     use, intrinsic :: iso_c_binding, only: c_loc,c_int,c_long
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     integer(8), intent(in)          :: unit
  !     !>
  !     integer(c_int)                  :: iErr
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  !     !> Broker
  !     iErr=GmfCloseMesh_c(InpMsh=int(unit,kind=c_long)  )
  !     !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  !     return
  !   end subroutine GmfCloseMesh_f90
    
    
  end module libmeshb7