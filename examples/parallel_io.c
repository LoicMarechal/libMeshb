

/*----------------------------------------------------------------------------*/
/*                                                                            */
/*             PARALLEL BLOCK READ AND WRITES WITH THE LIBMESHB               */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/*   Description:       open a mesh sequentialy and read/write                */
/*                      its fields in multithread                             */
/*   Author:            Loic MARECHAL                                         */
/*   Creation date:     feb 25 2025                                           */
/*   Last modification: feb 27 2026                                           */
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
   int      ver, dim, TetTyp, VerTyp, NmbCpu, (*TetTab)[5], *RefTab;
   int64_t  NmbVer, NmbTet, InpMsh, OutMsh, ParIdx;
   char     *InpNam, *OutNam;
   double   (*VerTab)[3];
}MshSct;


/*----------------------------------------------------------------------------*/
/* Read the vertices                                                          */
/*----------------------------------------------------------------------------*/

void ScaVer(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int ver, dim;
   int64_t InpMsh;

   if(!(InpMsh = GmfOpenMesh(msh->InpNam, GmfRead, &ver, &dim)))
      return;

   printf("THREAD %3d: read vertices %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   GmfGetBlock(InpMsh, GmfVertices, BegIdx, EndIdx, 0, NULL, NULL,
               GmfDoubleVec, 3, msh->VerTab[ BegIdx ],  msh->VerTab[ EndIdx ],
               GmfInt,         &msh->RefTab[ BegIdx ], &msh->RefTab[ EndIdx ]);

   GmfCloseMesh(InpMsh);
}


/*----------------------------------------------------------------------------*/
/* Read the tets                                                              */
/*----------------------------------------------------------------------------*/

void ScaTet(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int ver, dim;
   int64_t InpMsh;

   if(!(InpMsh = GmfOpenMesh(msh->InpNam, GmfRead, &ver, &dim)))
      return;

   printf("THREAD %3d: read tets     %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   GmfGetBlock(InpMsh, GmfTetrahedra, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 5, msh->TetTab[ BegIdx ], msh->TetTab[ EndIdx ]);

   GmfCloseMesh(InpMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the vertices                                                         */
/*----------------------------------------------------------------------------*/

void RecVer(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int res;
   int64_t OutMsh;

   printf("THREAD %3d: write vertices %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   if(!(OutMsh = GmfOpenMesh(msh->OutNam, GmfStartParallelWrite, msh->ver, msh->dim)))
      return;

   res = GmfSetBlock(OutMsh, GmfVertices, BegIdx, EndIdx, 0, NULL, NULL,
               GmfDoubleVec, 3, msh->VerTab[ BegIdx ],  msh->VerTab[ EndIdx ],
               GmfInt,         &msh->RefTab[ BegIdx ], &msh->RefTab[ EndIdx ]);

   GmfCloseUnfinishedMesh(OutMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the tets                                                             */
/*----------------------------------------------------------------------------*/

void RecTet(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int res;
   int64_t OutMsh;

   printf("THREAD %3d: write tets     %10d -> %10d\n", PthIdx, BegIdx, EndIdx);
   if(!(OutMsh = GmfOpenMesh(msh->OutNam, GmfStartParallelWrite, msh->ver, msh->dim)))
      return;

   res = GmfSetBlock(OutMsh, GmfTetrahedra, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 5, msh->TetTab[ BegIdx ], msh->TetTab[ EndIdx ]);

   GmfCloseUnfinishedMesh(OutMsh);
}


/*----------------------------------------------------------------------------*/
/* Open and allocate a mesh in serial, then read and write it in parallel     */
/*----------------------------------------------------------------------------*/

int main(int ArgCnt, char **ArgVec)
{
   int      i, BegIdx, EndIdx;
   double   timer;
   MshSct   msh;


   // Read the number of threads and the filenames from the command line
   if(ArgCnt == 4)
   {
      msh.InpNam = (char *)*++ArgVec;
      msh.OutNam = (char *)*++ArgVec;
      msh.NmbCpu = atoi(*++ArgVec);
   }
   else
   {
      puts("parallel_io   InputMesh   OutpuMesh   NmbThreads");
      exit(0);
   }


   /*-----------------------------------*/
   /* Open mesh file "tets.meshb"       */
   /*-----------------------------------*/

   if(!(msh.InpMsh = GmfOpenMesh(msh.InpNam, GmfRead, &msh.ver, &msh.dim)))
      return(1);

   printf("InpMsh : idx = %lld, version = %d, dimension = %d\n", msh.InpMsh, msh.ver, msh.dim);

   if(msh.dim != 3 || msh.ver < 2)
      exit(1);

   // Read the number of vertices and allocate memory
   msh.NmbVer = GmfStatKwd(msh.InpMsh, GmfVertices);
   printf("InpMsh : nmb vertices = %lld\n", msh.NmbVer);
   msh.VerTab = malloc((msh.NmbVer+1) * 3 * sizeof(double));
   msh.RefTab = malloc((msh.NmbVer+1) * sizeof(int));

   // Read the number of tets and allocate memory
   msh.NmbTet = GmfStatKwd(msh.InpMsh, GmfTetrahedra);
   printf("InpMsh : nmb tets = %lld\n\n", msh.NmbTet);
   msh.TetTab = malloc((msh.NmbTet+1) * 5 * sizeof(int));

   msh.ParIdx = InitParallel(msh.NmbCpu);
   msh.VerTyp = NewType(msh.ParIdx, msh.NmbVer);
   msh.TetTyp = NewType(msh.ParIdx, msh.NmbTet);

   // Close the tet mesh
   GmfCloseMesh(msh.InpMsh);

   timer = GetWallClock();
   LaunchParallel(msh.ParIdx, msh.VerTyp, 0, (void *)ScaVer, (void *)&msh);
   LaunchParallel(msh.ParIdx, msh.TetTyp, 0, (void *)ScaTet, (void *)&msh);
   printf("Time for reading: %g seconds\n\n", GetWallClock() - timer);


   /*-----------------------------------*/
   /* Write the tet mesh                */
   /*-----------------------------------*/

   timer = GetWallClock();

   // Create the mesh file
   if(!(msh.OutMsh = GmfOpenMesh(msh.OutNam, GmfWrite, msh.ver, msh.dim)))
      return(1);

   // Write the vertices
   GmfSetKwd(msh.OutMsh, GmfVertices, msh.NmbVer);
   GmfCloseUnfinishedMesh(msh.OutMsh);
   LaunchParallel(msh.ParIdx, msh.VerTyp, 0, (void *)RecVer, (void *)&msh);

   // Write the Tetrahedra
   if(!(msh.OutMsh = GmfOpenMesh(msh.OutNam, GmfStopParallelWrite, msh.ver, msh.dim)))
      return(1);

   GmfSetKwd(msh.OutMsh, GmfTetrahedra, msh.NmbTet);
   GmfCloseUnfinishedMesh(msh.OutMsh);
   LaunchParallel(msh.ParIdx, msh.TetTyp, 0, (void *)RecTet, (void *)&msh);

   if(!(msh.OutMsh = GmfOpenMesh(msh.OutNam, GmfStopParallelWrite, msh.ver, msh.dim)))
      return(1);

   GmfCloseMesh(msh.OutMsh);

   printf("Time for writing: %g seconds\n\n", GetWallClock() - timer);

   StopParallel(msh.ParIdx);
   free(msh.TetTab);
   free(msh.RefTab);
   free(msh.VerTab);

   return(0);
}
