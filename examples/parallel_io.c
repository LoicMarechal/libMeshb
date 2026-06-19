

/*----------------------------------------------------------------------------*/
/*                                                                            */
/*             PARALLEL BLOCK READ AND WRITES WITH THE LIBMESHB               */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/*   Description:       open a mesh sequentialy then read & write its fields  */
/*                      in a multithread way. Also create and write an        */
/*                      associated solb in parallel                           */
/*   Author:            Loic MARECHAL                                         */
/*   Creation date:     feb 25 2025                                           */
/*   Last modification: jun 19 2026                                           */
/*                                                                            */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
/* Includes                                                                   */
/*----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb8.h>
#include <lplib4.h>


/*----------------------------------------------------------------------------*/
/* Structure's prototype                                                      */
/*----------------------------------------------------------------------------*/

typedef struct
{
   int      ver, dim, TetTyp, TriTyp, VerTyp, NmbCpu;
   int      (*TriTab)[4], (*TetTab)[5], *RefTab;
   int64_t  NmbVer, NmbTri, NmbTet, InpMsh, OutMsh, OutSol, ParIdx;
   char     *InpNam, *OutNam, *SolNam;
   double   (*VerTab)[3];
}MshSct;


/*----------------------------------------------------------------------------*/
/* Read the vertices in parallel                                              */
/*----------------------------------------------------------------------------*/

void ScaVer(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int ver, dim;
   int64_t InpMsh;

   if(!(InpMsh = GmfOpenMesh(msh->InpNam, GmfRead, &ver, &dim)))
   {
      printf("Thread %d failed to reopen file %s\n", PthIdx, msh->InpNam);
      exit(1);
   }

   printf("THREAD %3d: read vertices  %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   GmfGetBlock(InpMsh, GmfVertices, BegIdx, EndIdx, 0, NULL, NULL,
               GmfDoubleVec, 3, msh->VerTab[ BegIdx ],  msh->VerTab[ EndIdx ],
               GmfInt,         &msh->RefTab[ BegIdx ], &msh->RefTab[ EndIdx ]);

   GmfCloseMesh(InpMsh);
}


/*----------------------------------------------------------------------------*/
/* Read the triangles in parallel                                             */
/*----------------------------------------------------------------------------*/

void ScaTri(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int ver, dim;
   int64_t InpMsh;

   if(!(InpMsh = GmfOpenMesh(msh->InpNam, GmfRead, &ver, &dim)))
   {
      printf("Thread %d failed to reopen file %s\n", PthIdx, msh->InpNam);
      exit(1);
   }

   printf("THREAD %3d: read triangles %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   GmfGetBlock(InpMsh, GmfTriangles, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 4, msh->TriTab[ BegIdx ], msh->TriTab[ EndIdx ]);

   GmfCloseMesh(InpMsh);
}


/*----------------------------------------------------------------------------*/
/* Read the tets in parallel                                                  */
/*----------------------------------------------------------------------------*/

void ScaTet(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int ver, dim;
   int64_t InpMsh;

   if(!(InpMsh = GmfOpenMesh(msh->InpNam, GmfRead, &ver, &dim)))
   {
      printf("Thread %d failed to reopen file %s\n", PthIdx, msh->InpNam);
      exit(1);
   }

   printf("THREAD %3d: read tets      %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   GmfGetBlock(InpMsh, GmfTetrahedra, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 5, msh->TetTab[ BegIdx ], msh->TetTab[ EndIdx ]);

   GmfCloseMesh(InpMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the vertices in parallel                                             */
/*----------------------------------------------------------------------------*/

void RecVer(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int res;
   int64_t OutMsh;

   if(!(OutMsh = GmfOpenMesh(msh->OutNam, GmfStartParallelWrite, msh->ver, msh->dim)))
   {
      printf("Thread %d failed to reopen file %s\n", PthIdx, msh->OutNam);
      exit(1);
   }

   printf("THREAD %3d: write vertices  %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   res = GmfSetBlock(OutMsh, GmfVertices, BegIdx, EndIdx, 0, NULL, NULL,
               GmfDoubleVec, 3, msh->VerTab[ BegIdx ],  msh->VerTab[ EndIdx ],
               GmfInt,         &msh->RefTab[ BegIdx ], &msh->RefTab[ EndIdx ]);

   GmfCloseUnfinishedMesh(OutMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the triangles in parallel                                            */
/*----------------------------------------------------------------------------*/

void RecTri(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int res;
   int64_t OutMsh;

   if(!(OutMsh = GmfOpenMesh(msh->OutNam, GmfStartParallelWrite, msh->ver, msh->dim)))
   {
      printf("Thread %d failed to reopen file %s\n", PthIdx, msh->OutNam);
      exit(1);
   }

   printf("THREAD %3d: write triangles %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   res = GmfSetBlock(OutMsh, GmfTriangles, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 4, msh->TriTab[ BegIdx ], msh->TriTab[ EndIdx ]);

   GmfCloseUnfinishedMesh(OutMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the tets in parallel                                                 */
/*----------------------------------------------------------------------------*/

void RecTet(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int res;
   int64_t OutMsh;

   if(!(OutMsh = GmfOpenMesh(msh->OutNam, GmfStartParallelWrite, msh->ver, msh->dim)))
   {
      printf("Thread %d failed to reopen file %s\n", PthIdx, msh->OutNam);
      exit(1);
   }

   printf("THREAD %3d: write tets      %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   res = GmfSetBlock(OutMsh, GmfTetrahedra, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 5, msh->TetTab[ BegIdx ], msh->TetTab[ EndIdx ]);

   GmfCloseUnfinishedMesh(OutMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the solutions at vertices in parallel                                */
/*----------------------------------------------------------------------------*/

void RecSol(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int res;
   int64_t OutSol;
   int TypTab[3], SizTab[3];
   char *BegTab[3], *EndTab[3];

   TypTab[0] = GmfDoubleVec;
   SizTab[0] = 3;
   BegTab[0] = (char *)msh->VerTab[ BegIdx ];
   EndTab[0] = (char *)msh->VerTab[ EndIdx ];

   if(!(OutSol = GmfOpenMesh(msh->SolNam, GmfStartParallelWrite, msh->ver, msh->dim)))
   {
      printf("Thread %d failed to reopen file %s\n", PthIdx, msh->OutNam);
      exit(1);
   }

   printf("THREAD %3d: write solution  %10d -> %10d\n", PthIdx, BegIdx, EndIdx);

   res = GmfSetBlock(OutSol, GmfSolAtVertices, BegIdx, EndIdx, 0, NULL, NULL,
               GmfDoubleVec, 3, msh->VerTab[ BegIdx ], msh->VerTab[ EndIdx ]);

   GmfCloseUnfinishedMesh(OutSol);
}


/*----------------------------------------------------------------------------*/
/* Open and allocate a mesh in serial, then read and write it in parallel     */
/*----------------------------------------------------------------------------*/

int main(int ArgCnt, char **ArgVec)
{
   int      i, BegIdx, EndIdx, TypTab[3];
   double   timer;
   MshSct   msh;


   // Read the number of threads and the filenames from the command line
   if(ArgCnt == 5)
   {
      msh.InpNam = (char *)*++ArgVec;
      msh.OutNam = (char *)*++ArgVec;
      msh.SolNam = (char *)*++ArgVec;
      msh.NmbCpu = atoi(*++ArgVec);
   }
   else
   {
      puts("parallel_io   InputMesh   OutputMesh   OutputSolution   NmbThreads");
      exit(0);
   }


   /*-----------------------------------*/
   /* Open mesh file "tets.meshb"       */
   /*-----------------------------------*/

   if(!(msh.InpMsh = GmfOpenMesh(msh.InpNam, GmfRead, &msh.ver, &msh.dim)))
   {
      printf("Unable to open the input mesh: %s\n", msh.InpNam);
      exit(1);
   }

   printf("InpMsh : idx = %lld, version = %d, dimension = %d\n", msh.InpMsh, msh.ver, msh.dim);

   if(msh.dim != 3)
   {
      puts("Dimension must 3");
      exit(1);
   }

   // Read the number of vertices, triangles and tets
   msh.NmbVer = GmfStatKwd(msh.InpMsh, GmfVertices);
   printf("InpMsh : nmb vertices  = %lld\n", msh.NmbVer);

   msh.NmbTri = GmfStatKwd(msh.InpMsh, GmfTriangles);
   printf("InpMsh : nmb triangles = %lld\n\n", msh.NmbTri);

   msh.NmbTet = GmfStatKwd(msh.InpMsh, GmfTetrahedra);
   printf("InpMsh : nmb tets      = %lld\n\n", msh.NmbTet);

   if(!msh.NmbVer || !msh.NmbTri || !msh.NmbTet)
   {
      puts("This example only works on meshes made of vertices, triangles and tetrahedra");
      exit(1);
   }

   // Allocate all tables
   msh.VerTab = malloc((msh.NmbVer+1) * 3 * sizeof(double));
   msh.RefTab = malloc((msh.NmbVer+1) * sizeof(int));
   msh.TriTab = malloc((msh.NmbTri+1) * 4 * sizeof(int));
   msh.TetTab = malloc((msh.NmbTet+1) * 5 * sizeof(int));

   if(!msh.VerTab || !msh.RefTab || !msh.TriTab || !msh.TetTab)
   {
      puts("Failed to allocate memory");
      exit(1);
   }

   msh.ParIdx = InitParallel(msh.NmbCpu);
   msh.VerTyp = NewType(msh.ParIdx, msh.NmbVer);
   msh.TriTyp = NewType(msh.ParIdx, msh.NmbTri);
   msh.TetTyp = NewType(msh.ParIdx, msh.NmbTet);

   if(!msh.ParIdx || !msh.VerTyp || !msh.TriTyp || !msh.TetTyp)
   {
      puts("Failed to initialize the parallelism with the LPlib");
      exit(1);
   }

   // Close the input tet mesh
   GmfCloseMesh(msh.InpMsh);

   timer = GetWallClock();
   LaunchParallel(msh.ParIdx, msh.VerTyp, 0, (void *)ScaVer, (void *)&msh);
   LaunchParallel(msh.ParIdx, msh.TriTyp, 0, (void *)ScaTri, (void *)&msh);
   LaunchParallel(msh.ParIdx, msh.TetTyp, 0, (void *)ScaTet, (void *)&msh);
   printf("Time for reading: %g seconds\n\n", GetWallClock() - timer);


   /*-----------------------------------*/
   /* Write the tet mesh                */
   /*-----------------------------------*/

   timer = GetWallClock();

   // Create the mesh file
   if(!(msh.OutMsh = GmfOpenMesh(msh.OutNam, GmfWrite, msh.ver, msh.dim)))
   {
      printf("Unable to create the output mesh: %s\n", msh.OutNam);
      exit(1);
   }

   // Write the vertices
   GmfSetKwd(msh.OutMsh, GmfVertices, msh.NmbVer);

   if(!GmfCloseUnfinishedMesh(msh.OutMsh))
   {
      puts("Parallel I/O are not available: please recompile with -DWITH_GMF_AIO");
      exit(1);
   }

   LaunchParallel(msh.ParIdx, msh.VerTyp, 0, (void *)RecVer, (void *)&msh);

   // Write the triangles
   if(!(msh.OutMsh = GmfOpenMesh(msh.OutNam, GmfStopParallelWrite, msh.ver, msh.dim)))
   {
      printf("Unable to reopen the output mesh: %s\n", msh.OutNam);
      exit(1);
   }

   GmfSetKwd(msh.OutMsh, GmfTriangles, msh.NmbTri);
   GmfCloseUnfinishedMesh(msh.OutMsh);
   LaunchParallel(msh.ParIdx, msh.TriTyp, 0, (void *)RecTri, (void *)&msh);

   // Write the tetrahedra
   if(!(msh.OutMsh = GmfOpenMesh(msh.OutNam, GmfStopParallelWrite, msh.ver, msh.dim)))
   {
      printf("Unable to reopen the output mesh: %s\n", msh.OutNam);
      exit(1);
   }

   GmfSetKwd(msh.OutMsh, GmfTetrahedra, msh.NmbTet);
   GmfCloseUnfinishedMesh(msh.OutMsh);
   LaunchParallel(msh.ParIdx, msh.TetTyp, 0, (void *)RecTet, (void *)&msh);

   // Final reopen in sequential mode and proposer file closing
   if(!(msh.OutMsh = GmfOpenMesh(msh.OutNam, GmfStopParallelWrite, msh.ver, msh.dim)))
   {
      printf("Unable to reopen the output mesh: %s\n", msh.OutNam);
      exit(1);
   }

   GmfCloseMesh(msh.OutMsh);


   /*-----------------------------------*/
   /* Write the solb file               */
   /*-----------------------------------*/

   // Create the mesh file
   if(!(msh.OutSol = GmfOpenMesh(msh.SolNam, GmfWrite, msh.ver, msh.dim)))
   {
      printf("Unable to create the output mesh: %s\n", msh.SolNam);
      exit(1);
   }

   // Write the solutions at vertices
   TypTab[0] = GmfVec;
   GmfSetKwd(msh.OutSol, GmfSolAtVertices, msh.NmbVer, 1, TypTab);

   if(!GmfCloseUnfinishedMesh(msh.OutSol))
   {
      puts("Parallel I/O are not available: please recompile with -DWITH_GMF_AIO");
      exit(1);
   }

   LaunchParallel(msh.ParIdx, msh.VerTyp, 0, (void *)RecSol, (void *)&msh);

   // Final reopen in sequential mode and proposer file closing
   if(!(msh.OutSol = GmfOpenMesh(msh.OutNam, GmfStopParallelWrite, msh.ver, msh.dim)))
   {
      printf("Unable to reopen the output mesh: %s\n", msh.OutNam);
      exit(1);
   }

   GmfCloseMesh(msh.OutSol);


   printf("Time for writing: %g seconds\n\n", GetWallClock() - timer);

   StopParallel(msh.ParIdx);
   free(msh.TetTab);
   free(msh.RefTab);
   free(msh.VerTab);

   return(0);
}
