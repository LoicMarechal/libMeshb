
c     libMeshb 7.79 example: transform a quadrilateral mesh into a triangular one
c     using fast block transfer

      include 'libmeshb7.ins'

      integer n
      parameter (n=4000)
      integer i, ver, dim, res, NmbVer, NmbQad
     +, RefTab(n), TriTab(4,2*n), QadTab(5,n)
      integer t(1),d,ho,s
      integer*8 InpMsh, OutMsh, m(1)
      real*8 VerTab(3,n)


c     --------------------------------------------
c     Open the quadrilateral mesh file for reading
c     --------------------------------------------

      InpMsh = gmfopenmeshf77('../sample_meshes/quad.meshb'
     +,GmfRead,ver,dim)

      if(InpMsh.eq.0) STOP ' InpMsh = 0'
      if(dim.ne.3) STOP ' dimension <> 3'

c     Check memory bounds
      NmbVer = gmfstatkwdf77(InpMsh, GmfVertices, 0, s, t, 0, ho)
      if(NmbVer.gt.n) STOP 'Too many vertices'

      NmbQad = gmfstatkwdf77(InpMsh, GmfQuadrilaterals, 0, s, t, 0, ho)
      if(NmbQad.gt.n) STOP 'Too many quads'

c     Print some information on the open file
      print*, 'input mesh  :', InpMsh
      print*, 'version     :', ver
      print*, 'dimension   :', dim
      print*, 'vertices    :', NmbVer
      print*, 'quads       :', NmbQad

c     Read the vertices using a vector of 3 consecutive doubles
c     to store the coordinates
      res = gmfgetvertices(InpMsh,
     +        1, NmbVer, 0, m,
     +        VerTab(1,1), VerTab(1,NmbVer),
     +        RefTab(  1), RefTab(  NmbVer))

c     Read the quads using one single vector of 5 consecutive integers
      res = gmfgetelements(InpMsh, GmfQuadrilaterals,
     +        1, NmbQad, 0, m,
     +        QadTab(1,1), QadTab(1,NmbQad),
     +        QadTab(5,1), QadTab(5,NmbQad))

c     Close the quadrilateral mesh
      res = gmfclosemeshf77(InpMsh)


c     -------------------------------------------
c     Convert the quad mesh into a triangular one
c     -------------------------------------------

      do i = 1,2*NmbQad
         if(mod(i,2) .EQ. 1) then
            TriTab(1,i) = QadTab(1,(i+1)/2)
            TriTab(2,i) = QadTab(2,(i+1)/2)
            TriTab(3,i) = QadTab(3,(i+1)/2)
            TriTab(4,i) = QadTab(5,(i+1)/2)
         else
            TriTab(1,i) = QadTab(1,(i+1)/2)
            TriTab(2,i) = QadTab(3,(i+1)/2)
            TriTab(3,i) = QadTab(4,(i+1)/2)
            TriTab(4,i) = QadTab(5,(i+1)/2)
         endif
      end do


c     -----------------------
c     Write a triangular mesh
c     -----------------------

      OutMsh = gmfopenmeshf77('tri.meshb', GmfWrite, ver, dim)
      if(OutMsh.eq.0) STOP ' OutMsh = 0'

c     Set the number of vertices
      res = gmfsetkwdf77(OutMsh, GmfVertices, NmbVer, 0, t, 0, ho)

c     Write them down using separate pointers for each scalar entry
      res = gmfsetvertices(OutMsh,
     +         1, NmbVer, 0, m,
     +         VerTab(1,1), VerTab(1,NmbVer),
     +         RefTab(1),   RefTab(NmbVer))

c     Write the triangles using 4 independant set of arguments
c     for each scalar entry: node1, node2, node3 and reference
      res = gmfsetkwdf77(OutMsh, GmfTriangles, 2*NmbQad, 0, t, 0, ho)
      res = gmfsetelements(OutMsh, GmfTriangles,
     +                  1, 2*NmbQad, 0, m,
     +                  TriTab(1,1), TriTab(1,2*NmbQad),
     +                  TriTab(4,1), TriTab(4,2*NmbQad))

c     Don't forget to close the file
      res = gmfclosemeshf77(OutMsh)

      print*, 'output mesh :',NmbVer,' vertices,',
     +         2*NmbQad,'triangles'

      end      
