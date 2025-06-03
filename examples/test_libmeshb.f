
c     libMeshb 8.0 basic example:
c     read a quad mesh, split it into triangles and write the result back
c     write an associated dummy .sol file containing some data

      include 'libmeshb8.ins'

      integer n
      parameter (n=4000)
      integer i,NmbVer,NmbQad,ver,dim,res,RefTab(n),QadTab(5,n),kwd
      integer t(10),d,ho,s,dummyint(1),dummyref
      integer*8 InpMsh, OutMsh
      real*8 VerTab(3,n), sol(10), dummyreal(1)


c     --------------------------------------------
c     Open the quadrilateral mesh file for reading
c     --------------------------------------------

c     Open the mesh file and check the version and dimension
      InpMsh = gmfopenmeshf77('../sample_meshes/quad.mesh',
     +GmfRead,ver,dim)
      print*, 'input mesh :', InpMsh,'version:',ver,'dim:',dim
      if(InpMsh.eq.0) STOP ' InpMsh = 0'
      if(ver.le.1) STOP ' version <= 1'
      if(dim.ne.3) STOP ' dimension <> 3'

c     Check memory bounds
      NmbVer = gmfstatkwdf77(InpMsh, GmfVertices, 0, s, t, d, ho)
      if(NmbVer.gt.n) STOP 'Too many vertices'
      NmbQad = gmfstatkwdf77(InpMsh, GmfQuadrilaterals, 0, s, t, d, ho)
      if(NmbQad.gt.n) STOP 'Too many quads'
      print*, 'input mesh : ',NmbVer,' vertices,',NmbQad,'quads'

c     Read the vertices
      res = gmfgotokwdf77(InpMsh, GmfVertices)
      do i = 1, NmbVer
          res = gmfgetlinef77(InpMsh, GmfVertices, dummyint(1),
     +VerTab(1,i), RefTab(i))
      end do

c     Read the quads
      res = gmfgotokwdf77(InpMsh, GmfQuadrilaterals)
      do i = 1, NmbQad
          res =gmfgetlinef77(InpMsh, GmfQuadrilaterals,
     +    QadTab(1,i), dummyreal(1), QadTab(5,i))
      end do

c     Close the quadrilateral mesh
      res = gmfclosemeshf77(InpMsh)


c     ------------------------
c     Create a triangular mesh
c     ------------------------

      OutMsh = gmfopenmeshf77('tri.mesh', GmfWrite, 2, 3)
      if(OutMsh.eq.0) STOP ' OutMsh = 0'
      print*, 'output IDX: ',OutMsh

c     Set the number of vertices
      res = gmfsetkwdf77(OutMsh, GmfVertices, NmbVer, 0, t, 0, ho)

c     Then write them down
      do i = 1, NmbVer
          res = gmfsetlinef77(OutMsh, GmfVertices, dummyint,
     +VerTab(1,i), RefTab(i))
      end do

c     Write the triangles
      res = gmfsetkwdf77(OutMsh, GmfTriangles, 2*NmbQad, 0, t, 0, ho)
      do i=1,NmbQad
          res = gmfsetlinef77(OutMsh, GmfTriangles,
     +    QadTab(1,i), dummyreal, QadTab(5,i))
c     Modify the quad to build the other triangle's diagonal
          QadTab(2,i) = QadTab(3,i);
          QadTab(3,i) = QadTab(4,i);
          res = gmfsetlinef77(OutMsh, GmfTriangles,
     +    QadTab(1,i), dummyreal, QadTab(5,i))
      end do

c     Don't forget to close the file
      res = gmfclosemeshf77(OutMsh)

      print*, 'output mesh: ',NmbVer,' vertices,',
     +         2*NmbQad,'triangles'


c     ----------------------
c     Create a solution file
c     ----------------------

      OutMsh = gmfopenmeshf77('tri.sol', GmfWrite, 2, 3)
      if(OutMsh.eq.0) STOP ' OutMsh = 0'
      print*, 'output IDX: ',OutMsh

      res = gmfsetkwdf77(OutMsh, GmfReferenceStrings, 3, 0, t, 0, ho)
      res = gmfsetreferencestringf77(OutMsh, GmfSolAtVertices,
     +1, 'first scalar')
      res = gmfsetreferencestringf77(OutMsh, GmfSolAtVertices,
     +2, 'a vector')
      res = gmfsetreferencestringf77(OutMsh, GmfSolAtVertices,
     +3, 'second scalar')

c     Set the solution kinds
      t(1) = GmfSca;
      t(2) = GmfVec;
      t(3) = GmfSca;
c     Set the number of solutions (one per vertex)
      res = gmfsetkwdf77(OutMsh, GmfSolAtVertices, NmbVer, 3, t, 0, ho)

c     Write the dummy solution fields
      do i = 1, NmbVer
         sol(1) = i
         sol(2) = i*2
         sol(3) = i*3
         sol(4) = i*4
         sol(5) = -i
         res = gmfsetlinef77(OutMsh, GmfSolAtVertices,
     +dummyint, sol, dummyref)
      end do

c     Don't forget to close the file
      res = gmfclosemeshf77(OutMsh)

      print*, 'output sol: ',NmbVer,' solutions'

      end
