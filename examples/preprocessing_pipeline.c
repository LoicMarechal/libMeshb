

/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                               LIBMESHB V7.84                               */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Description:         block reading and pipilined preprocessing of data     */
/* Author:              Loic MARECHAL                                         */
/* Creation date:       oct 16 2023                                           */
/* Last modification:   jun 03 2025                                           */
/*                                                                            */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
/* Includes                                                                   */
/*----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include <strings.h>
#include <math.h>
#include <float.h>
#include <libmeshb7.h>


/*----------------------------------------------------------------------------*/
/* Global variables                                                           */
/*----------------------------------------------------------------------------*/

#ifdef INT64
#define itg int64_t
#define FILINT GmfLong
#define FILVEC GmfLongVec
#else
#define itg int32_t
#define FILINT GmfInt
#define FILVEC GmfIntVec
#endif


/*----------------------------------------------------------------------------*/
/* Mesh data structure of arrays                                              */
/*----------------------------------------------------------------------------*/

typedef struct PtrBuc
{
   itg   tet, nex;
   char  idx[3], voy;
}BucSct;

typedef struct
{
   int64_t  NmbVer, NmbTet, NanErr, IdxErr, HshSiz, NmbHit, NmbCol, NmbLnk;
   itg      (*TetVer)[4], *TetRef, *VerRef, *VerTet, (*TetNgb)[4];
   char     (*TetVoy)[4];
   double   (*VerCrd)[3], BoxMin[3], BoxMax[3], MinEdgLen;
   BucSct   *HshTab;
}MshSct;


/*----------------------------------------------------------------------------*/
/* Prototypes of preprocessing procedures                                     */
/*----------------------------------------------------------------------------*/

static void PreprocessVertices(itg, itg, MshSct *);
static void PreprocessTets    (itg, itg, MshSct *);
static void GetSrtFac         (MshSct *, itg, int, char *);


/*----------------------------------------------------------------------------*/
/* Open and read a tet mesh and preprocess the data while reading the blocks  */
/*----------------------------------------------------------------------------*/

int main(int ArgCnt, char **ArgVec)
{
   char     *PtrArg, *TmpStr, InpNam[1000];
   int      ver, dim, PipFlg = 1;
   int64_t  i, InpMsh;
   MshSct   msh = {0};

   msh.MinEdgLen = DBL_MAX;

   /*----------------------*/
   /* Command line parsing */
   /*----------------------*/

   if(ArgCnt == 1)
   {
      puts("\npipelined_read v1.00 october 16 2023   Loic MARECHAL / INRIA");
      puts(" Usage        : pipelined_read -in input_mesh");
      puts(" -np          : disable the pipelined process and do it sequentially");
      puts("");
      exit(0);
   }

   for(i=2;i<=ArgCnt;i++)
   {
      PtrArg = *++ArgVec;

      if(!strcmp(PtrArg,"-in"))
      {
         TmpStr = *++ArgVec;
         ArgCnt--;
         strcpy(InpNam, TmpStr);

         if(!strstr(InpNam, ".mesh"))
            strcat(InpNam, ".meshb");

         continue;
      }

      if(!strcmp(PtrArg,"-np"))
      {
         PipFlg = 0;
         continue;
      }
   }

   if(!strlen(InpNam))
   {
      puts("No input mesh provided");
      exit(1);
   }



   /*-------------------------*/
   /* Open the input tet mesh */
   /*-------------------------*/

   if(!(InpMsh = GmfOpenMesh(InpNam, GmfRead, &ver, &dim)))
      return(1);

   printf("InpMsh: idx = %lld, version = %d, dimension = %d\n", InpMsh, ver, dim);

   if(dim != 3)
   {
      puts("Can only process dimension 3 meshes");
      exit(1);
   }

   // Read the number of vertices and allocate memory
   msh.NmbVer = (int)GmfStatKwd(InpMsh, GmfVertices);

   if(!msh.NmbVer)
   {
      puts("This mesh does not contain vertices");
      exit(1);
   }

   printf("InpMsh: nmb vertices = %lld\n", (int64_t)msh.NmbVer);
   msh.VerCrd = malloc((msh.NmbVer+1) * 3 * sizeof(double));
   msh.VerRef = malloc((msh.NmbVer+1) * sizeof(itg));

   // Read the number of tets and allocate memory
   msh.NmbTet = (int)GmfStatKwd(InpMsh, GmfTetrahedra);

   if(!msh.NmbTet)
   {
      puts("This mesh does not contain tets");
      exit(1);
   }

   printf("InpMsh: nmb tets = %lld\n", (int64_t)msh.NmbTet);
   msh.TetVer = malloc( (msh.NmbTet+1) * 4 * sizeof(itg) );
   msh.TetRef = malloc( (msh.NmbTet+1) * sizeof(itg) );
   msh.HshSiz = 3 * msh.NmbVer;
   msh.HshTab = malloc( (msh.HshSiz + 4 * msh.NmbTet ) * sizeof(BucSct) );
   memset(msh.HshTab, 0, msh.HshSiz * sizeof(BucSct));
   msh.TetNgb = calloc( msh.NmbTet + 1, 4 * sizeof(itg) );
   msh.TetVoy = calloc( msh.NmbTet + 1, 4 * sizeof(char) );

   printf("HshSiz = %lld\n", (int64_t)msh.HshSiz);

   if(   !msh.VerCrd || !msh.VerRef || !msh.TetVer || !msh.TetRef || !msh.HshTab
      || !msh.TetNgb || !msh.TetVoy )
   {
      puts("Failled to allocate memory");
      exit(1);
   }
   else
      printf("Allocated %lld bytes\n", (3 * sizeof(double) + sizeof(itg)) * (int64_t)msh.NmbVer
         + (9 * sizeof(itg) + 4 * sizeof(char) + sizeof(BucSct)) * (int64_t)msh.NmbTet
         + (int64_t)msh.HshSiz * 3 * sizeof(BucSct) );

   if(PipFlg)
   {
      // Read the vertices: choose one of the four available methods
      GmfGetBlock(InpMsh, GmfVertices, 1, msh.NmbVer, 0, NULL, PreprocessVertices, &msh,
                  FILVEC, 3, &msh.VerCrd[1][0], &msh.VerCrd[ msh.NmbVer ][0],
                  FILINT,    &msh.VerRef[1],    &msh.VerRef[ msh.NmbVer ] );

      // Read the tets
      GmfGetBlock(InpMsh, GmfTetrahedra, 1, msh.NmbTet, 0, NULL, PreprocessTets, &msh,
                  FILVEC, 4, &msh.TetVer[1][0], &msh.TetVer[ msh.NmbTet ][0],
                  FILINT,    &msh.TetRef[1],    &msh.TetRef[ msh.NmbTet ]);
   }
   else
   {
      // Read the vertices: choose one of the four available methods
      GmfGetBlock(InpMsh, GmfVertices, 1, msh.NmbVer, 0, NULL, NULL,
                  GmfDoubleVec, 3, &msh.VerCrd[1][0], &msh.VerCrd[ msh.NmbVer ][0],
                  FILINT,          &msh.VerRef[1],    &msh.VerRef[ msh.NmbVer ] );

      PreprocessVertices(1, msh.NmbVer, &msh);

      // Read the tets
      GmfGetBlock(InpMsh, GmfTetrahedra, 1, msh.NmbTet, 0, NULL, NULL,
                  FILVEC, 4, &msh.TetVer[1][0], &msh.TetVer[ msh.NmbTet ][0],
                  FILINT,    &msh.TetRef[1],    &msh.TetRef[ msh.NmbTet ]);

      PreprocessTets(1, msh.NmbTet, &msh);
   }


   // Close the quad mesh
   GmfCloseMesh(InpMsh);


   printf(  "Vertices parsing: number of NaN = %lld, bounding box = [ %g %g %g ] <-> [ %g %g %g ]\n",
            (int64_t)msh.NanErr, msh.BoxMin[0], msh.BoxMin[1], msh.BoxMin[2],
            msh.BoxMax[0], msh.BoxMax[1], msh.BoxMax[2] );

   //printf(  "Tets parsing: invalid vertex ID = %lld, shortest edge = %g\n", (int64_t)msh.IdxErr, msh.MinEdgLen);

   printf(  "Hash stats: faces = %lld, base table = %lld, collision table = %lld, link followed = %lld\n",
            4 * (int64_t)msh.NmbTet, (int64_t)msh.NmbHit, (int64_t)msh.NmbCol, (int64_t)msh.NmbLnk );

   free(msh.VerCrd);
   free(msh.VerRef);
   free(msh.TetVer);
   free(msh.TetRef);
   free(msh.HshTab);
   free(msh.TetNgb);
   free(msh.TetVoy);

   return(0);
}


/*----------------------------------------------------------------------------*/
/* Vertex pipelined preprocessing: check for NaN and get the bounding box     */
/*----------------------------------------------------------------------------*/

static void PreprocessVertices(itg BegIdx, itg EndIdx, MshSct *msh)
{
   itg i;
   int j;

   for(i=BegIdx; i<=EndIdx; i++)
   {
      for(j=0;j<3;j++)
      {
         if(isnan(msh->VerCrd[i][j]))
            msh->NanErr++;

         if(msh->VerCrd[i][j] < msh->BoxMin[j])
            msh->BoxMin[j] = msh->VerCrd[i][j];

         if(msh->VerCrd[i][j] > msh->BoxMax[j])
            msh->BoxMax[j] = msh->VerCrd[i][j];
      }
   }
}


/*----------------------------------------------------------------------------*/
/* Tets pipelined preprocessing: invalid Vid, shortest edge and neighbours    */
/*----------------------------------------------------------------------------*/

static void PreprocessTets(itg BegIdx, itg EndIdx, MshSct *msh)
{
   int64_t  key;
   itg      i;
   int      j, k;
   char     idx[3];
   int      TetEdg[6][2] = { {0,1}, {1,2}, {2,0}, {0,3}, {1,3}, {2,3} };
   double   *PtrV0, *PtrV1, len;
   BucSct   *buc;

   for(i=BegIdx; i<=EndIdx; i++)
   {
      /*for(j=0;j<4;j++)
      {
         if( (msh->TetVer[i][j] < 1) || (msh->TetVer[i][j] > msh->NmbVer) )
            msh->IdxErr++;
      }

      if(msh->IdxErr)
         continue;

      for(j=0;j<6;j++)
      {
         PtrV0 = msh->VerCrd[ msh->TetVer[i][ TetEdg[j][0] ] ];
         PtrV1 = msh->VerCrd[ msh->TetVer[i][ TetEdg[j][1] ] ];
         len   = (PtrV1[0] - PtrV0[0]) * (PtrV1[0] - PtrV0[0])
               + (PtrV1[1] - PtrV0[1]) * (PtrV1[1] - PtrV0[1])
               + (PtrV1[2] - PtrV0[2]) * (PtrV1[2] - PtrV0[2]);

         if(len < msh->MinEdgLen)
            msh->MinEdgLen = len;
      }*/

      for(j=0;j<4;j++)
      {
         GetSrtFac(msh, i, j, idx);

         key = ((int64_t)msh->TetVer[i][ idx[0] ]
             +  (int64_t)msh->TetVer[i][ idx[1] ]
             +  (int64_t)msh->TetVer[i][ idx[2] ]);

         buc = &msh->HshTab[ key ];

         if(!buc->tet)
         {
            for(k=0;k<3;k++)
               buc->idx[k] = idx[k];

            buc->tet = i;
            buc->voy = j;
            msh->NmbHit++;
         }
         else
         {
            do
            {
               if((msh->TetVer[i][ idx[0] ] == msh->TetVer[ buc->tet ][ buc->idx[0] ])
               && (msh->TetVer[i][ idx[1] ] == msh->TetVer[ buc->tet ][ buc->idx[1] ])
               && (msh->TetVer[i][ idx[2] ] == msh->TetVer[ buc->tet ][ buc->idx[2] ]))
               {
                  msh->TetNgb[i][j] = buc->tet;
                  msh->TetVoy[i][j] = buc->voy;
                  msh->TetNgb[ buc->tet ][ buc->voy ] = i;
                  msh->TetVoy[ buc->tet ][ buc->voy ] = j;
                  break;
               }

               if(buc->nex)
               {
                  msh->NmbLnk++;
                  buc = &msh->HshTab[ buc->nex ];
               }
               else
               {
                  buc->nex = msh->HshSiz + msh->NmbCol++;
                  buc = &msh->HshTab[ buc->nex ];
                  buc->tet = i;
                  buc->voy = j;

                  for(k=0;k<3;k++)
                     buc->idx[k] = idx[k];

                  break;
               }
            }while(1);
         }
      }
   }
}


/*----------------------------------------------------------------------------*/
/* Fill idx table with sorted face vertices                                   */
/*----------------------------------------------------------------------------*/

static void GetSrtFac(MshSct *msh, itg TetIdx, int FacIdx, char idx[3])
{
   char     a, b, c;
   itg  A, B, C;
   static const int tvpf[4][3] = { {1,2,3}, {2,0,3}, {3,0,1}, {0,2,1} };

   a = tvpf[ FacIdx ][0];
   b = tvpf[ FacIdx ][1];
   c = tvpf[ FacIdx ][2];

   A = msh->TetVer[ TetIdx ][ a ];
   B = msh->TetVer[ TetIdx ][ b ];
   C = msh->TetVer[ TetIdx ][ c ];

   if(A < B)
      if(B < C)
      {
         idx[0] = a;
         idx[1] = b;
         idx[2] = c;
      }
      else
         if(A < C)
         {
            idx[0] = a;
            idx[1] = c;
            idx[2] = b;
         }
         else
         {
            idx[0] = c;
            idx[1] = a;
            idx[2] = b;
         }
   else
      if(A < C)
      {
         idx[0] = b;
         idx[1] = a;
         idx[2] = c;
      }
      else
         if(B < C)
         {
            idx[0] = b;
            idx[1] = c;
            idx[2] = a;
         }
         else
         {
            idx[0] = c;
            idx[1] = b;
            idx[2] = a;
         }
      }
