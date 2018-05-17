
/* libMeshb 7.2 basic example: read a quad mesh, split it into triangles
   and write the result back */

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb7.h>

int main()
{
   char str[ GmfStrSiz ];
   int i, NmbVer, NmbQad, ver, dim, *RefTab, (*QadTab)[5], NmbInt, NmbDbl, StrSiz;
   int64_t InpMsh, OutMsh, IntTab[ GmfMaxTyp ];
   double (*VerTab)[3], DblTab[ GmfMaxTyp ];


   /*-----------------------------------*/
   /* Open mesh file "quad.meshb"       */
   /*-----------------------------------*/

   if(!(InpMsh = GmfOpenMesh("../sample_meshes/quad.mesh", GmfRead, &ver, &dim)))
      return(1);

   printf("InpMsh: idx = %lld, version = %d, dimension = %d\n", InpMsh, ver, dim);

   if( (ver != 2) || (dim != 3) )
      exit(1);

   // Read the number of vertices and allocate memory
   NmbVer = GmfStatKwd(InpMsh, GmfVertices);
   printf("InpMsh: nmb vertices = %d\n", NmbVer);
   VerTab = malloc((NmbVer+1) * 3 * sizeof(double));
   RefTab = malloc((NmbVer+1) * sizeof(int));

   // Read the number of quads and allocate memory
   NmbQad = GmfStatKwd(InpMsh, GmfQuadrilaterals);
   printf("InpMsh: nmb quads = %d\n", NmbQad);
   QadTab = malloc((NmbQad+1) * 5 * sizeof(int));

   // Read the vertices
   GmfGotoKwd(InpMsh, GmfVertices);

   for(i=1;i<=NmbVer;i++)
   {
      GmfGetLinTab(InpMsh, GmfVertices, IntTab, &NmbInt, DblTab, &NmbDbl, str, &StrSiz);
      VerTab[i][0] = DblTab[0];
      VerTab[i][1] = DblTab[1];
      VerTab[i][2] = DblTab[2];
      RefTab[i]    = IntTab[0];
   }

   // Read the quads
   GmfGotoKwd(InpMsh, GmfQuadrilaterals);

   for(i=1;i<=NmbQad;i++)
   {
      GmfGetLinTab(InpMsh, GmfQuadrilaterals, IntTab, &NmbInt, DblTab, &NmbDbl, str, &StrSiz);
      QadTab[i][0] = IntTab[0];
      QadTab[i][1] = IntTab[1];
      QadTab[i][2] = IntTab[2];
      QadTab[i][3] = IntTab[3];
      QadTab[i][4] = IntTab[4];
   }

   // Close the quad mesh
   GmfCloseMesh(InpMsh);


   /*-----------------------------------*/
   /* Write the triangle mesh           */
   /*-----------------------------------*/

   if(!(OutMsh = GmfOpenMesh("tri.mesh", GmfWrite, ver, dim)))
      return(1);

   // Write the vertices
   GmfSetKwd(OutMsh, GmfVertices, NmbVer);

   for(i=1;i<=NmbVer;i++)
      GmfSetLin(  OutMsh, GmfVertices, VerTab[i][0], \
                  VerTab[i][1], VerTab[i][2], RefTab[i] );

   // Write the triangles
   GmfSetKwd(OutMsh, GmfTriangles, 2*NmbQad);

   // Split each quad into two triangles on the fly
   for(i=1;i<=NmbQad;i++)
   {
      GmfSetLin(  OutMsh, GmfTriangles, QadTab[i][0], \
                  QadTab[i][1], QadTab[i][2], QadTab[i][4] );
      GmfSetLin(  OutMsh, GmfTriangles, QadTab[i][0], \
                  QadTab[i][2], QadTab[i][3], QadTab[i][4] );
   }

   // Do not forget to close the mesh file
   GmfCloseMesh(OutMsh);
   printf("OutMsh: nmb triangles = %d\n", 2 * NmbQad);

   free(QadTab);
   free(RefTab);
   free(VerTab);

   return(0);
}
