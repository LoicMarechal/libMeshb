
// libMeshb 7.66 basic example: read a general purpose solution file

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb7.h>


int main()
{
   int      i, j, NmbSolLin, ver, dim, TotSolSiz, NmbSolTyp, SolTypTab[ GmfMaxTyp ];
   int      DatTypTab[10], DatSizTab[10];
   int64_t  MshIdx;
   double   *SolTab;
   char     *DatBegTab[10], *DatEndTab[10];
   char     *TypStr[5] = {"", "GmfSca", "GmfVec", "GmfSymMat", "GmfMat"};


   // Open the "out.sol" mesh file
   if(!(MshIdx = GmfOpenMesh("../sample_meshes/out.sol", GmfRead, &ver, &dim)))
      return(1);

   printf("MshIdx: idx = %lld, version = %d, dimension = %d\n", MshIdx, ver, dim);

   if(ver < 2)
      return(1);

   // Read the number vertices and associated solution size for memory allocation
   NmbSolLin = GmfStatKwd(MshIdx, GmfSolAtVertices, &NmbSolTyp, &TotSolSiz, SolTypTab);
   printf("NmbSol = %d, NmbTyp = %d, SolSiz = %d\n", NmbSolLin, NmbSolTyp, TotSolSiz);
   for(i=0;i<NmbSolTyp;i++)
      printf("type %d = %s\n", i, TypStr[ SolTypTab[i] ]);

   SolTab = malloc( (NmbSolLin+1) * TotSolSiz * sizeof(double));

   // Solution field block reading via arguments tables
   DatTypTab[0] = GmfDoubleVec;
   DatSizTab[0] = 5;
   DatBegTab[0] = (char *)&SolTab[         1 * TotSolSiz ];
   DatEndTab[0] = (char *)&SolTab[ NmbSolLin * TotSolSiz ];

   GmfGetBlock(MshIdx, GmfSolAtVertices, 1, NmbSolLin, 0, NULL, NULL,
               GmfArgTab, DatTypTab, DatSizTab, DatBegTab, DatEndTab);

   // Print each solutions of each vertices
   for(i=1;i<=NmbSolLin;i++)
      for(j=0;j<TotSolSiz;j++)
         printf("%d, %d = %g\n", i, j, SolTab[ i * TotSolSiz + j ]);

   // Close the mesh file
   GmfCloseMesh(MshIdx);


   // Open a new mesh file for creation
   if(!(MshIdx = GmfOpenMesh("../sample_meshes/out2.sol", GmfWrite, ver, dim)))
      return(1);

   // Create a new solution field from the previsous one made of two scalars followed by a 3D vector
   SolTypTab[0] = GmfSca;
   SolTypTab[1] = GmfSca;
   SolTypTab[2] = GmfVec;

   // Write the number vertices and associated solution size for memory allocation
   GmfSetKwd(MshIdx, GmfSolAtVertices, NmbSolLin, 3, SolTypTab);

   // Solution field block reading
   GmfSetBlock(MshIdx, GmfSolAtVertices, 1, NmbSolLin, 0, NULL, NULL,
               GmfSca, &SolTab[ 1 * TotSolSiz     ], &SolTab[ NmbSolLin * TotSolSiz     ],
               GmfVec, &SolTab[ 1 * TotSolSiz + 1 ], &SolTab[ NmbSolLin * TotSolSiz + 1 ],
               GmfSca, &SolTab[ 1 * TotSolSiz + 4 ], &SolTab[ NmbSolLin * TotSolSiz + 4 ]);

   // Close the mesh file
   GmfCloseMesh(MshIdx);


   // Free the solutions table
   free(SolTab);

   return(0);
}
