
c     libMeshb 7.79 basic example: 
c     read a quad mesh, split it into triangles and write the result back

      include 'libmeshb7.ins'

      integer n
      parameter (n=4000)
      integer i,NmbVer,NmbQad,ver,dim,res,RefTab(n),QadTab(5,n),kwd
      integer*8 InpMsh, OutMsh
      real*8 VerTab(3,n)


c     --------------------------------------------
c     Open the quadrilateral mesh file for reading
c     --------------------------------------------

c     Open the mesh file and check the version and dimension
      InpMsh = gmfopenmeshf77('../sample_meshes/quad.mesh ',
     +GmfRead,ver,dim)
      print*, 'input mesh :', InpMsh,'version:',ver,'dim:',dim
      if(InpMsh.eq.0) STOP ' InpMsh = 0'
      if(ver.le.1) STOP ' version <= 1'
      if(dim.ne.3) STOP ' dimension <> 3'

c     Check memory bounds
      NmbVer = gmfstatkwdf77(InpMsh, GmfVertices)
      if(NmbVer.gt.n) STOP 'Too many vertices'
      NmbQad = gmfstatkwdf77(InpMsh, GmfQuadrilaterals)
      if(NmbQad.gt.n) STOP 'Too many quads'
      print*, 'input mesh : ',NmbVer,' vertices,',NmbQad,'quads'

c     Read the quads
      res = gmfgotokwdf77(InpMsh, GmfQuadrilaterals)
      do i = 1, NmbQad
          res =gmfgetquadrilateral(InpMsh,QadTab(1,i),QadTab(5,i))
      end do

c     Read the vertices
      res = gmfgotokwdf77(InpMsh, GmfVertices)
      do i = 1, NmbVer
          res = gmfgetvertex(InpMsh, VerTab(1,i), RefTab(i))
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
      res = gmfsetkwdf77(OutMsh, GmfVertices, NmbVer, 0 , 0)

c     Then write them down
      do i = 1, NmbVer
          res = gmfsetvertex(OutMsh, VerTab(1,i), RefTab(i))
      end do

c     Write the triangles
      res = gmfsetkwdf77(OutMsh, GmfTriangles, 2*NmbQad, 0, 0)
      do i=1,NmbQad
          res = gmfsettriangle(OutMsh,QadTab(1,i),QadTab(5,i))
c     Modify the quad to build the other triangle's diagonal
          QadTab(2,i) = QadTab(3,i);
          QadTab(3,i) = QadTab(4,i);
          res = gmfsettriangle(OutMsh,QadTab(1,i),QadTab(5,i))
      end do

c     Don't forget to close the file
      res = gmfclosemeshf77(OutMsh)

      print*, 'output mesh: ',NmbVer,' vertices,',
     +         2*NmbQad,'triangles'

      end      
