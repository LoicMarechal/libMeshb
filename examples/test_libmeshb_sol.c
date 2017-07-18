
// libMeshb 7.2 basic example: read a general purpose solution file

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb7.h>


int main()
{
   int i, j, NmbSol, ver, dim, SolSiz, NmbTyp, TypTab[ GmfMaxTyp ];
   long long InpMsh;
   double *SolTab, *PtrTab1[ GmfMaxTyp ], *PtrTab2[ GmfMaxTyp ];


   // Open the "out.sol" mesh file
   if(!(InpMsh = GmfOpenMesh("../sample_meshes/out.sol", GmfRead, &ver, &dim)))
      return(1);

   printf("InpMsh: idx = %lld, version = %d, dimension = %d\n", InpMsh, ver, dim);

   if(ver < 2)
      return(1);

   // Read the number vertices and associated solution size for memory allocation
   NmbSol = GmfStatKwd(InpMsh, GmfSolAtVertices, &NmbTyp, &SolSiz, TypTab);
   printf("NmbSol = %d, NmbTyp = %d, SolSiz = %d\n", NmbSol, NmbTyp, SolSiz);
   SolTab = malloc( (NmbSol+1) * SolSiz * sizeof(double));

   // Fill the pointer tables with pointers on first and last entries
   // of each solution fields in user's data structures so that
   // the libMeshb is able to compute the strides
   PtrTab1[0] = &SolTab[      1 * SolSiz ];
   PtrTab2[0] = &SolTab[ NmbSol * SolSiz ];

   // solution field block reading
   GmfGetBlock(InpMsh, GmfSolAtVertices, 1, NmbSol, 0, NULL, NULL, GmfDouble, PtrTab1, PtrTab2);

   // Print each solutions of each vertices
   for(i=1;i<=NmbSol;i++)
      for(j=0;j<SolSiz;j++)
         printf("%d, %d = %g\n", i, j, SolTab[ i * SolSiz + j ]);

   // Close the mesh file and free memory
   GmfCloseMesh(InpMsh);
   free(SolTab);

   return(0);
}
