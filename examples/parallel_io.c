

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
/*   Last modification: feb 25 2025                                           */
/*                                                                            */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
/* Includes                                                                   */
/*----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb7.h>
#include <lplib3.h>


/*----------------------------------------------------------------------------*/
/* Defines                                                                    */
/*----------------------------------------------------------------------------*/

#define NMBCPU 10
#define MSHINP "../sample_meshes/tets.meshb"
#define MSHOUT "/tmp/tets.meshb"


/*----------------------------------------------------------------------------*/
/* Structure's prototype                                                      */
/*----------------------------------------------------------------------------*/

typedef struct
{
   int      ver, dim, TetTyp, VerTyp, (*TetTab)[5], *RefTab;
   int64_t  NmbVer, NmbTet;
   double   (*VerTab)[3];
   int64_t  InpMsh, OutMsh, ParIdx;
}MshSct;


/*----------------------------------------------------------------------------*/
/* Read the vertices                                                          */
/*----------------------------------------------------------------------------*/

void ScaVer(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int ver, dim;
   int64_t InpMsh;

   if(!(InpMsh = GmfOpenMesh(MSHINP, GmfRead, &ver, &dim)))
      return;

   printf("THREAD %3d: read vertices %8d -> %8d\n", PthIdx, BegIdx, EndIdx);
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

   if(!(InpMsh = GmfOpenMesh(MSHINP, GmfRead, &ver, &dim)))
      return;

   printf("THREAD %3d: read tets %8d -> %8d\n", PthIdx, BegIdx, EndIdx);
   GmfGetBlock(InpMsh, GmfTetrahedra, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 5, msh->TetTab[ BegIdx ], msh->TetTab[ EndIdx ]);

   GmfCloseMesh(InpMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the vertices                                                         */
/*----------------------------------------------------------------------------*/

void RecVer(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int64_t OutMsh;

   if(!(OutMsh = GmfOpenMesh(MSHOUT, GmfWrite, msh->ver, msh->dim)))
      return;

   GmfSetBlock(OutMsh, GmfVertices, BegIdx, EndIdx, 0, NULL, NULL,
               GmfDoubleVec, 3, msh->VerTab[ BegIdx ],  msh->VerTab[ EndIdx ],
               GmfInt,         &msh->RefTab[ BegIdx ], &msh->RefTab[ EndIdx ]);

   GmfCloseMesh(OutMsh);
}


/*----------------------------------------------------------------------------*/
/* Write the tets                                                             */
/*----------------------------------------------------------------------------*/

void RecTet(int BegIdx, int EndIdx, int PthIdx, MshSct *msh)
{
   int64_t OutMsh;

   if(!(OutMsh = GmfOpenMesh(MSHOUT, GmfWrite, msh->ver, msh->dim)))
      return;

   GmfSetBlock(OutMsh, GmfTetrahedra, BegIdx, EndIdx, 0, NULL, NULL,
               GmfIntVec, 5, msh->TetTab[ BegIdx ], msh->TetTab[ EndIdx ]);

   GmfCloseMesh(OutMsh);
}


/*----------------------------------------------------------------------------*/
/* Open and allocate a mesh in serial, then read and write it in parallel     */
/*----------------------------------------------------------------------------*/

int main()
{
   int i, BegIdx, EndIdx;
   MshSct msh;


   /*-----------------------------------*/
   /* Open mesh file "tets.meshb"       */
   /*-----------------------------------*/

   if(!(msh.InpMsh = GmfOpenMesh(MSHINP, GmfRead, &msh.ver, &msh.dim)))
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
   printf("InpMsh : nmb tets = %lld\n", msh.NmbTet);
   msh.TetTab = malloc((msh.NmbTet+1) * 5 * sizeof(int));

   msh.ParIdx = InitParallel(NMBCPU);
   msh.VerTyp = NewType(msh.ParIdx, msh.NmbVer);
   msh.TetTyp = NewType(msh.ParIdx, msh.NmbTet);

   // Close the tet mesh
   GmfCloseMesh(msh.InpMsh);

   LaunchParallel(msh.ParIdx, msh.VerTyp, 0, (void *)ScaVer, (void *)&msh);
   LaunchParallel(msh.ParIdx, msh.TetTyp, 0, (void *)ScaTet, (void *)&msh);


   /*-----------------------------------*/
   /* Write the tet mesh                */
   /*-----------------------------------*/

   if(!(msh.OutMsh = GmfOpenMesh(MSHOUT, GmfWrite, msh.ver, msh.dim)))
      return(1);

   // Write the vertices
   GmfSetKwd(msh.OutMsh, GmfVertices, msh.NmbVer);

   for(i=0;i<NMBCPU;i++)
   {
      GetBigBlkNfo(msh.ParIdx, msh.VerTyp, i, &BegIdx, &EndIdx);
      printf("MASTER: write vertices %8d -> %8d\n", BegIdx, EndIdx);
      GmfSetBlock(msh.OutMsh, GmfVertices, BegIdx, EndIdx, 0, NULL, NULL,
                  GmfDoubleVec, 3, msh.VerTab[ BegIdx ],  msh.VerTab[ EndIdx ],
                  GmfInt,         &msh.RefTab[ BegIdx ], &msh.RefTab[ EndIdx ]);
   }

   //LaunchParallel(msh.ParIdx, msh.VerTyp, 0, (void *)RecVer, (void *)&msh);

   // Write the Tetrahedra
   GmfSetKwd(msh.OutMsh, GmfTetrahedra, msh.NmbTet);

   for(i=0;i<NMBCPU;i++)
   {
      GetBigBlkNfo(msh.ParIdx, msh.TetTyp, i, &BegIdx, &EndIdx);
      printf("MASTER: write tets %8d -> %8d\n", BegIdx, EndIdx);
      GmfSetBlock(msh.OutMsh, GmfTetrahedra, BegIdx, EndIdx, 0, NULL, NULL,
                  GmfIntVec, 5, msh.TetTab[ BegIdx ], msh.TetTab[ EndIdx ]);
   }

   //LaunchParallel(msh.ParIdx, msh.TetTyp, 0, (void *)RecTet, (void *)&msh);

   GmfCloseMesh(msh.OutMsh);
   printf("OutMsh : nmb Tetrahedra = %lld\n", msh.NmbTet);

   free(msh.TetTab);
   free(msh.RefTab);
   free(msh.VerTab);

   return(0);
}
