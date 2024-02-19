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

  
    integer*8 gmfopenmeshf77
    integer gmfclosemeshf77
    integer gmfstatkwdf77
    integer gmfsetkwdf77
    integer gmfgotokwdf77
    integer gmfsethonodesorderingf77
    integer gmfgetvertex
    integer gmfsetvertex
    integer gmfgetelement
    integer gmfsetelement
    integer gmfgetvertices
    integer gmfsetvertices
    integer gmfgetelements
    integer gmfsetelements
    integer gmfgetsolution
    integer gmfsetsolution
  
  
    ! Parameters definition
    integer gmfmaxtyp
    integer gmfmaxkwd
    integer gmfread
    integer gmfwrite
    integer gmfsca
    integer gmfvec
    integer gmfsymmat
    integer gmfmat
    integer gmffloat
    integer gmfdouble
    integer gmfint
    integer gmflong
    integer gmfinttab
    integer gmflongtab
    integer gmffloatvec
    integer gmfdoublevec
    integer gmfintvec
    integer gmflongvec
    integer gmfargtab
    integer gmfarglst
  
    parameter (gmfmaxtyp=1000)
    parameter (gmfmaxkwd=227)
    parameter (gmfread=1)
    parameter (gmfwrite=2)
    parameter (gmfsca=1)
    parameter (gmfvec=2)
    parameter (gmfsymmat=3)
    parameter (gmfmat=4)
    parameter (gmffloat=8)
    parameter (gmfdouble=9)
    parameter (gmfint=10)
    parameter (gmflong=11)
    parameter (gmfinttab=14)
    parameter (gmflongtab=15)
    parameter (gmffloatvec=12)
    parameter (gmfdoublevec=13)
    parameter (gmfintvec=14)
    parameter (gmflongvec=15)
    parameter (gmfargtab=100)
    parameter (gmfarglst=101)
  
  
    ! Keywords list
    integer gmfmeshversionformatted
    integer gmfdimension
    integer gmfvertices
    integer gmfedges
    integer gmftriangles
    integer gmfquadrilaterals
    integer gmftetrahedra
    integer gmfprisms
    integer gmfhexahedra
    integer gmfiterationsall
    integer gmftimesall
    integer gmfcorners
    integer gmfridges
    integer gmfrequiredvertices
    integer gmfrequirededges
    integer gmfrequiredtriangles
    integer gmfrequiredquadrilaterals
    integer gmftangentatedgevertices
    integer gmfnormalatvertices
    integer gmfnormalattrianglevertices
    integer gmfnormalatquadrilateralvertices
    integer gmfangleofcornerbound
    integer gmftrianglesp2
    integer gmfedgesp2
    integer gmfsolatpyramids
    integer gmfquadrilateralsq2
    integer gmfisolatpyramids
    integer gmfsubdomainfromgeom
    integer gmftetrahedrap2
    integer gmffault_neartri
    integer gmffault_inter
    integer gmfhexahedraq2
    integer gmfextraverticesatedges
    integer gmfextraverticesattriangles
    integer gmfextraverticesatquadrilaterals
    integer gmfextraverticesattetrahedra
    integer gmfextraverticesatprisms
    integer gmfextraverticesathexahedra
    integer gmfverticesongeometricvertices
    integer gmfverticesongeometricedges
    integer gmfverticesongeometrictriangles
    integer gmfverticesongeometricquadrilaterals
    integer gmfedgesongeometricedges
    integer gmffault_freeedge
    integer gmfpolyhedra
    integer gmfpolygons
    integer gmffault_overlap
    integer gmfpyramids
    integer gmfboundingbox
    integer gmfbody
    integer gmfprivatetable
    integer gmffault_badshape
    integer gmfend
    integer gmftrianglesongeometrictriangles
    integer gmftrianglesongeometricquadrilaterals
    integer gmfquadrilateralsongeometrictriangles
    integer gmfquadrilateralsongeometricquadrilaterals
    integer gmftangents
    integer gmfnormals
    integer gmftangentatvertices
    integer gmfsolatvertices
    integer gmfsolatedges
    integer gmfsolattriangles
    integer gmfsolatquadrilaterals
    integer gmfsolattetrahedra
    integer gmfsolatprisms
    integer gmfsolathexahedra
    integer gmfdsolatvertices
    integer gmfisolatvertices
    integer gmfisolatedges
    integer gmfisolattriangles
    integer gmfisolatquadrilaterals
    integer gmfisolattetrahedra
    integer gmfisolatprisms
    integer gmfisolathexahedra
    integer gmfiterations
    integer gmftime
    integer gmffault_smalltri
    integer gmfcoarsehexahedra
    integer gmfcomments
    integer gmfperiodicvertices
    integer gmfperiodicedges
    integer gmfperiodictriangles
    integer gmfperiodicquadrilaterals
    integer gmfprismsp2
    integer gmfpyramidsp2
    integer gmfquadrilateralsq3
    integer gmfquadrilateralsq4
    integer gmftrianglesp3
    integer gmftrianglesp4
    integer gmfedgesp3
    integer gmfedgesp4
    integer gmfirefgroups
    integer gmfdrefgroups
    integer gmftetrahedrap3
    integer gmftetrahedrap4
    integer gmfhexahedraq3
    integer gmfhexahedraq4
    integer gmfpyramidsp3
    integer gmfpyramidsp4
    integer gmfprismsp3
    integer gmfprismsp4
    integer gmfhosolatedgesp1
    integer gmfhosolatedgesp2
    integer gmfhosolatedgesp3
    integer gmfhosolattrianglesp1
    integer gmfhosolattrianglesp2
    integer gmfhosolattrianglesp3
    integer gmfhosolatquadrilateralsq1
    integer gmfhosolatquadrilateralsq2
    integer gmfhosolatquadrilateralsq3
    integer gmfhosolattetrahedrap1
    integer gmfhosolattetrahedrap2
    integer gmfhosolattetrahedrap3
    integer gmfhosolatpyramidsp1
    integer gmfhosolatpyramidsp2
    integer gmfhosolatpyramidsp3
    integer gmfhosolatprismsp1
    integer gmfhosolatprismsp2
    integer gmfhosolatprismsp3
    integer gmfhosolathexahedraq1
    integer gmfhosolathexahedraq2
    integer gmfhosolathexahedraq3
    integer gmfbezierbasis
    integer gmfbyteflow
    integer gmfedgesp2ordering
    integer gmfedgesp3ordering
    integer gmftrianglesp2ordering
    integer gmftrianglesp3ordering
    integer gmfquadrilateralsq2ordering
    integer gmfquadrilateralsq3ordering
    integer gmftetrahedrap2ordering
    integer gmftetrahedrap3ordering
    integer gmfpyramidsp2ordering
    integer gmfpyramidsp3ordering
    integer gmfprismsp2ordering
    integer gmfprismsp3ordering
    integer gmfhexahedraq2ordering
    integer gmfhexahedraq3ordering
    integer gmfedgesp1ordering
    integer gmfedgesp4ordering
    integer gmftrianglesp1ordering
    integer gmftrianglesp4ordering
    integer gmfquadrilateralsq1ordering
    integer gmfquadrilateralsq4ordering
    integer gmftetrahedrap1ordering
    integer gmftetrahedrap4ordering
    integer gmfpyramidsp1ordering
    integer gmfpyramidsp4ordering
    integer gmfprismsp1ordering
    integer gmfprismsp4ordering
    integer gmfhexahedraq1ordering
    integer gmfhexahedraq4ordering
    integer gmffloatingpointprecision
    integer gmfhosolatedgesp4
    integer gmfhosolattrianglesp4
    integer gmfhosolatquadrilateralsq4
    integer gmfhosolattetrahedrap4
    integer gmfhosolatpyramidsp4
    integer gmfhosolatprismsp4
    integer gmfhosolathexahedraq4
    integer gmfhosolatedgesp1nodespositions
    integer gmfhosolatedgesp2nodespositions
    integer gmfhosolatedgesp3nodespositions
    integer gmfhosolatedgesp4nodespositions
    integer gmfhosolattrianglesp1nodespositions
    integer gmfhosolattrianglesp2nodespositions
    integer gmfhosolattrianglesp3nodespositions
    integer gmfhosolattrianglesp4nodespositions
    integer gmfhosolatquadrilateralsq1nodespositions
    integer gmfhosolatquadrilateralsq2nodespositions
    integer gmfhosolatquadrilateralsq3nodespositions
    integer gmfhosolatquadrilateralsq4nodespositions
    integer gmfhosolattetrahedrap1nodespositions
    integer gmfhosolattetrahedrap2nodespositions
    integer gmfhosolattetrahedrap3nodespositions
    integer gmfhosolattetrahedrap4nodespositions
    integer gmfhosolatpyramidsp1nodespositions
    integer gmfhosolatpyramidsp2nodespositions
    integer gmfhosolatpyramidsp3nodespositions
    integer gmfhosolatpyramidsp4nodespositions
    integer gmfhosolatprismsp1nodespositions
    integer gmfhosolatprismsp2nodespositions
    integer gmfhosolatprismsp3nodespositions
    integer gmfhosolatprismsp4nodespositions
    integer gmfhosolathexahedraq1nodespositions
    integer gmfhosolathexahedraq2nodespositions
    integer gmfhosolathexahedraq3nodespositions
    integer gmfhosolathexahedraq4nodespositions
    integer gmfedgesreferenceelement
    integer gmftrianglereferenceelement
    integer gmfquadrilateralreferenceelement
    integer gmftetrahedronreferenceelement
    integer gmfpyramidreferenceelement
    integer gmfprismreferenceelement
    integer gmfhexahedronreferenceelement
    integer gmfboundarylayers
    integer gmfreferencestrings
    integer gmfprisms9
    integer gmfhexahedra12
    integer gmfquadrilaterals6
    integer gmfboundarypolygonheaders
    integer gmfboundarypolygonvertices
    integer gmfinnerpolygonheaders
    integer gmfinnerpolygonvertices
    integer gmfpolyhedraheaders
    integer gmfpolyhedrafaces
    integer gmfdomains
    integer gmfverticesgid
    integer gmfedgesgid
    integer gmftrianglesgid
    integer gmfquadrilateralsgid
    integer gmftetrahedragid
    integer gmfpyramidsgid
    integer gmfprismsgid
    integer gmfhexahedragid
    integer gmfsolatboundarypolygons
    integer gmfsolatpolyhedra
    integer gmfverticesongeometrynodes
    integer gmfverticesongeometryedges
    integer gmfedgesongeometryedges
    integer gmfverticesongeometryfaces
    integer gmfedgesongeometryfaces
    integer gmftrianglesongeometryfaces
    integer gmfquadrialteralsongeometryfaces
    integer gmfmeshongeometry
  
    parameter (gmfmeshversionformatted=1)
    parameter (gmfdimension=3)
    parameter (gmfvertices=4)
    parameter (gmfedges=5)
    parameter (gmftriangles=6)
    parameter (gmfquadrilaterals=7)
    parameter (gmftetrahedra=8)
    parameter (gmfprisms=9)
    parameter (gmfhexahedra=10)
    parameter (gmfiterationsall=11)
    parameter (gmftimesall=12)
    parameter (gmfcorners=13)
    parameter (gmfridges=14)
    parameter (gmfrequiredvertices=15)
    parameter (gmfrequirededges=16)
    parameter (gmfrequiredtriangles=17)
    parameter (gmfrequiredquadrilaterals=18)
    parameter (gmftangentatedgevertices=19)
    parameter (gmfnormalatvertices=20)
    parameter (gmfnormalattrianglevertices=21)
    parameter (gmfnormalatquadrilateralvertices=22)
    parameter (gmfangleofcornerbound=23)
    parameter (gmftrianglesp2=24)
    parameter (gmfedgesp2=25)
    parameter (gmfsolatpyramids=26)
    parameter (gmfquadrilateralsq2=27)
    parameter (gmfisolatpyramids=28)
    parameter (gmfsubdomainfromgeom=29)
    parameter (gmftetrahedrap2=30)
    parameter (gmffault_neartri=31)
    parameter (gmffault_inter=32)
    parameter (gmfhexahedraq2=33)
    parameter (gmfextraverticesatedges=34)
    parameter (gmfextraverticesattriangles=35)
    parameter (gmfextraverticesatquadrilaterals=36)
    parameter (gmfextraverticesattetrahedra=37)
    parameter (gmfextraverticesatprisms=38)
    parameter (gmfextraverticesathexahedra=39)
    parameter (gmfverticesongeometricvertices=40)
    parameter (gmfverticesongeometricedges=41)
    parameter (gmfverticesongeometrictriangles=42)
    parameter (gmfverticesongeometricquadrilaterals=43)
    parameter (gmfedgesongeometricedges=44)
    parameter (gmffault_freeedge=45)
    parameter (gmfpolyhedra=46)
    parameter (gmfpolygons=47)
    parameter (gmffault_overlap=48)
    parameter (gmfpyramids=49)
    parameter (gmfboundingbox=50)
    parameter (gmfbody=51)
    parameter (gmfprivatetable=52)
    parameter (gmffault_badshape=53)
    parameter (gmfend=54)
    parameter (gmftrianglesongeometrictriangles=55)
    parameter (gmftrianglesongeometricquadrilaterals=56)
    parameter (gmfquadrilateralsongeometrictriangles=57)
    parameter (gmfquadrilateralsongeometricquadrilaterals=58)
    parameter (gmftangents=59)
    parameter (gmfnormals=60)
    parameter (gmftangentatvertices=61)
    parameter (gmfsolatvertices=62)
    parameter (gmfsolatedges=63)
    parameter (gmfsolattriangles=64)
    parameter (gmfsolatquadrilaterals=65)
    parameter (gmfsolattetrahedra=66)
    parameter (gmfsolatprisms=67)
    parameter (gmfsolathexahedra=68)
    parameter (gmfdsolatvertices=69)
    parameter (gmfisolatvertices=70)
    parameter (gmfisolatedges=71)
    parameter (gmfisolattriangles=72)
    parameter (gmfisolatquadrilaterals=73)
    parameter (gmfisolattetrahedra=74)
    parameter (gmfisolatprisms=75)
    parameter (gmfisolathexahedra=76)
    parameter (gmfiterations=77)
    parameter (gmftime=78)
    parameter (gmffault_smalltri=79)
    parameter (gmfcoarsehexahedra=80)
    parameter (gmfcomments=81)
    parameter (gmfperiodicvertices=82)
    parameter (gmfperiodicedges=83)
    parameter (gmfperiodictriangles=84)
    parameter (gmfperiodicquadrilaterals=85)
    parameter (gmfprismsp2=86)
    parameter (gmfpyramidsp2=87)
    parameter (gmfquadrilateralsq3=88)
    parameter (gmfquadrilateralsq4=89)
    parameter (gmftrianglesp3=90)
    parameter (gmftrianglesp4=91)
    parameter (gmfedgesp3=92)
    parameter (gmfedgesp4=93)
    parameter (gmfirefgroups=94)
    parameter (gmfdrefgroups=95)
    parameter (gmftetrahedrap3=96)
    parameter (gmftetrahedrap4=97)
    parameter (gmfhexahedraq3=98)
    parameter (gmfhexahedraq4=99)
    parameter (gmfpyramidsp3=100)
    parameter (gmfpyramidsp4=101)
    parameter (gmfprismsp3=102)
    parameter (gmfprismsp4=103)
    parameter (gmfhosolatedgesp1=104)
    parameter (gmfhosolatedgesp2=105)
    parameter (gmfhosolatedgesp3=106)
    parameter (gmfhosolattrianglesp1=107)
    parameter (gmfhosolattrianglesp2=108)
    parameter (gmfhosolattrianglesp3=109)
    parameter (gmfhosolatquadrilateralsq1=110)
    parameter (gmfhosolatquadrilateralsq2=111)
    parameter (gmfhosolatquadrilateralsq3=112)
    parameter (gmfhosolattetrahedrap1=113)
    parameter (gmfhosolattetrahedrap2=114)
    parameter (gmfhosolattetrahedrap3=115)
    parameter (gmfhosolatpyramidsp1=116)
    parameter (gmfhosolatpyramidsp2=117)
    parameter (gmfhosolatpyramidsp3=118)
    parameter (gmfhosolatprismsp1=119)
    parameter (gmfhosolatprismsp2=120)
    parameter (gmfhosolatprismsp3=121)
    parameter (gmfhosolathexahedraq1=122)
    parameter (gmfhosolathexahedraq2=123)
    parameter (gmfhosolathexahedraq3=124)
    parameter (gmfbezierbasis=125)
    parameter (gmfbyteflow=126)
    parameter (gmfedgesp2ordering=127)
    parameter (gmfedgesp3ordering=128)
    parameter (gmftrianglesp2ordering=129)
    parameter (gmftrianglesp3ordering=130)
    parameter (gmfquadrilateralsq2ordering=131)
    parameter (gmfquadrilateralsq3ordering=132)
    parameter (gmftetrahedrap2ordering=133)
    parameter (gmftetrahedrap3ordering=134)
    parameter (gmfpyramidsp2ordering=135)
    parameter (gmfpyramidsp3ordering=136)
    parameter (gmfprismsp2ordering=137)
    parameter (gmfprismsp3ordering=138)
    parameter (gmfhexahedraq2ordering=139)
    parameter (gmfhexahedraq3ordering=140)
    parameter (gmfedgesp1ordering=141)
    parameter (gmfedgesp4ordering=142)
    parameter (gmftrianglesp1ordering=143)
    parameter (gmftrianglesp4ordering=144)
    parameter (gmfquadrilateralsq1ordering=145)
    parameter (gmfquadrilateralsq4ordering=146)
    parameter (gmftetrahedrap1ordering=147)
    parameter (gmftetrahedrap4ordering=148)
    parameter (gmfpyramidsp1ordering=149)
    parameter (gmfpyramidsp4ordering=150)
    parameter (gmfprismsp1ordering=151)
    parameter (gmfprismsp4ordering=152)
    parameter (gmfhexahedraq1ordering=153)
    parameter (gmfhexahedraq4ordering=154)
    parameter (gmffloatingpointprecision=155)
    parameter (gmfhosolatedgesp4=156)
    parameter (gmfhosolattrianglesp4=157)
    parameter (gmfhosolatquadrilateralsq4=158)
    parameter (gmfhosolattetrahedrap4=159)
    parameter (gmfhosolatpyramidsp4=160)
    parameter (gmfhosolatprismsp4=161)
    parameter (gmfhosolathexahedraq4=162)
    parameter (gmfhosolatedgesp1nodespositions=163)
    parameter (gmfhosolatedgesp2nodespositions=164)
    parameter (gmfhosolatedgesp3nodespositions=165)
    parameter (gmfhosolatedgesp4nodespositions=166)
    parameter (gmfhosolattrianglesp1nodespositions=167)
    parameter (gmfhosolattrianglesp2nodespositions=168)
    parameter (gmfhosolattrianglesp3nodespositions=169)
    parameter (gmfhosolattrianglesp4nodespositions=170)
    parameter (gmfhosolatquadrilateralsq1nodespositions=171)
    parameter (gmfhosolatquadrilateralsq2nodespositions=172)
    parameter (gmfhosolatquadrilateralsq3nodespositions=173)
    parameter (gmfhosolatquadrilateralsq4nodespositions=174)
    parameter (gmfhosolattetrahedrap1nodespositions=175)
    parameter (gmfhosolattetrahedrap2nodespositions=176)
    parameter (gmfhosolattetrahedrap3nodespositions=177)
    parameter (gmfhosolattetrahedrap4nodespositions=178)
    parameter (gmfhosolatpyramidsp1nodespositions=179)
    parameter (gmfhosolatpyramidsp2nodespositions=180)
    parameter (gmfhosolatpyramidsp3nodespositions=181)
    parameter (gmfhosolatpyramidsp4nodespositions=182)
    parameter (gmfhosolatprismsp1nodespositions=183)
    parameter (gmfhosolatprismsp2nodespositions=184)
    parameter (gmfhosolatprismsp3nodespositions=185)
    parameter (gmfhosolatprismsp4nodespositions=186)
    parameter (gmfhosolathexahedraq1nodespositions=187)
    parameter (gmfhosolathexahedraq2nodespositions=188)
    parameter (gmfhosolathexahedraq3nodespositions=189)
    parameter (gmfhosolathexahedraq4nodespositions=190)
    parameter (gmfedgesreferenceelement=191)
    parameter (gmftrianglereferenceelement=192)
    parameter (gmfquadrilateralreferenceelement=193)
    parameter (gmftetrahedronreferenceelement=194)
    parameter (gmfpyramidreferenceelement=195)
    parameter (gmfprismreferenceelement=196)
    parameter (gmfhexahedronreferenceelement=197)
    parameter (gmfboundarylayers=198)
    parameter (gmfreferencestrings=199)
    parameter (gmfprisms9=200)
    parameter (gmfhexahedra12=201)
    parameter (gmfquadrilaterals6=202)
    parameter (gmfboundarypolygonheaders=203)
    parameter (gmfboundarypolygonvertices=204)
    parameter (gmfinnerpolygonheaders=205)
    parameter (gmfinnerpolygonvertices=206)
    parameter (gmfpolyhedraheaders=207)
    parameter (gmfpolyhedrafaces=208)
    parameter (gmfdomains=209)
    parameter (gmfverticesgid=210)
    parameter (gmfedgesgid=211)
    parameter (gmftrianglesgid=212)
    parameter (gmfquadrilateralsgid=213)
    parameter (gmftetrahedragid=214)
    parameter (gmfpyramidsgid=215)
    parameter (gmfprismsgid=216)
    parameter (gmfhexahedragid=217)
    parameter (gmfsolatboundarypolygons=218)
    parameter (gmfsolatpolyhedra=219)
    parameter (gmfverticesongeometrynodes=220)
    parameter (gmfverticesongeometryedges=221)
    parameter (gmfedgesongeometryedges=222)
    parameter (gmfverticesongeometryfaces=223)
    parameter (gmfedgesongeometryfaces=224)
    parameter (gmftrianglesongeometryfaces=225)
    parameter (gmfquadrialteralsongeometryfaces=226)
    parameter (gmfmeshongeometry=227)
  
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