
// libMeshb7_helpers: Read and prints a polyhedral mesh using the helpers functions

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb7.h>
#include "../utilities/libmeshb7_helpers.h"

int main()
{
   int         i, j, k, NmbVer, ver, dim, *RefTab, ret, deg, buf[256], deg2, buf2[256];
   int64_t     InpMsh;
   double      (*VerTab)[3];
   PolMshSct   *pol;


   // Open and check the polyhedral mesh file
   if(!(InpMsh = GmfOpenMesh("../sample_meshes/polyhedra.mesh", GmfRead, &ver, &dim)))
   {
      puts("Could not open ../sample_meshes/polyhedra.mesh");
      return(1);
   }

   printf("InpMsh: idx = %lld, version = %d, dimension = %d\n", InpMsh, ver, dim);

   if( (ver != 2) || (dim != 3) )
   {
      printf("Wrong version (%d) or dimension (%d)\n", ver, dim);
      return(1);
   }

   // Read the number of vertices and allocate memory
   NmbVer = GmfStatKwd(InpMsh, GmfVertices);
   printf("InpMsh: nmb vertices = %d\n", NmbVer);
   VerTab = malloc((NmbVer+1) * 3 * sizeof(double));
   RefTab = malloc((NmbVer+1) * sizeof(int));

   // Read the number of polygons/polyhedra and allocate memory
   pol = GmfAllocatePolyghedralStructure(InpMsh);

   if(!pol)
   {
      puts("Could not allocate the polyhedral structure");
      return(1);
   }

   ret = GmfReadBoundaryPolygons(pol);

   if(!ret)
   {
      puts("Could not read the boundary polygons");
      return(1);
   }

   for(i=1;i<=pol->NmbBndHdr;i++)
   {
      deg = GmfGetBoundaryPolygon(pol, i, buf);
      printf("polygon %d (%d): ", i, deg);
      for(j=0;j<deg;j++)
         printf("%d ", buf[j]);
      puts("");
   }

   ret = GmfReadPolyhedra(pol);

   if(!ret)
   {
      puts("Could not read the polyhedra");
      return(1);
   }

   for(i=1;i<=pol->NmbVolHdr;i++)
   {
      deg = GmfGetPolyhedron(pol, i, buf);
      printf("polyhedron %d (%d): ", i, deg);

      for(j=0;j<deg;j++)
         printf("%d ", buf[j]);
      puts("");

      for(j=0;j<deg;j++)
      {
         deg2 = GmfGetInnerPolygon(pol, buf[j], buf2);
         printf("polygon %d (%d): ", buf[j], deg2);
         for(k=0;k<deg2;k++)
            printf("%d ", buf2[k]);
         puts("");
      }
   }

   // Close the quad mesh
   GmfCloseMesh(InpMsh);


   GmfFreePolyghedralStructure(pol);
   free(RefTab);
   free(VerTab);

   return(0);
}
