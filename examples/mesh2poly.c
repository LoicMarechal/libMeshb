#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libmeshb7.h>

int main(int ArgCnt, char **ArgVec)
{
   int      i, j, ver, dim, ref, nod[8], ArgIdx = 1;
   int      NmbVer, NmbTri, NmbQad, NmbTet, NmbPyr, NmbPri, NmbHex;
   int64_t  InpMsh, OutMsh;
   float    xf, yf, zf;
   double   xd, yd, zd;
   char    *InpNam, *OutNam;

   if(ArgCnt != 3)
   {
      puts("\nMESH2POLY 1.0, may 12 2021, Loic MARECHAL / INRIA\n");
      puts(" Usage    : mesh2poly source_name destination_name\n");
      exit(0);
   }

   InpNam = ArgVec[ ArgIdx++ ];
   OutNam = ArgVec[ ArgIdx++ ];

   if(!strlen(InpNam))
   {
      puts("Missing input name.");
      exit(1);
   }

   if(!strlen(OutNam))
   {
      puts("Missing output name.");
      exit(2);
   }

   if(!strcmp(InpNam, OutNam))
   {
      puts("The output mesh cannot overwrite the input mesh.");
      exit(3);
   }

   if(!(InpMsh = GmfOpenMesh(InpNam, GmfRead, &ver, &dim)))
   {
      printf("Cannot open mesh file %s.\n", InpNam);
      return(4);
   }

   if(!(OutMsh = GmfOpenMesh(OutNam, GmfWrite, ver, dim)))
   {
      printf("Cannot open mesh file %s.\n", OutNam);
      return(5);
   }

   NmbVer = GmfStatKwd(InpMsh, GmfVertices);
   NmbTri = GmfStatKwd(InpMsh, GmfTriangles);
   NmbQad = GmfStatKwd(InpMsh, GmfQuadrilaterals);
   NmbTet = GmfStatKwd(InpMsh, GmfTetrahedra);
   NmbPri = GmfStatKwd(InpMsh, GmfPrisms);
   NmbPyr = GmfStatKwd(InpMsh, GmfPyramids);
   NmbHex = GmfStatKwd(InpMsh, GmfHexahedra);

   printf(" InpMsh: idx = %lld, version: %d, dimension: %d\n", InpMsh, ver, dim);

   if(NmbVer)
   {
      printf(" Copying %d vertices\n", NmbVer);

      GmfGotoKwd(InpMsh, GmfVertices);
      GmfSetKwd(OutMsh, GmfVertices, NmbVer);

      for(i=1;i<=NmbVer;i++)
      {
         if(ver <= 1)
         {
            GmfGetLin(InpMsh, GmfVertices, &xf, &yf, &zf, &ref);
            GmfSetLin(OutMsh, GmfVertices,  xf,  yf,  zf,  ref);
         }
         else
         {
            GmfGetLin(InpMsh, GmfVertices, &xd, &yd, &zd, &ref);
            GmfSetLin(OutMsh, GmfVertices,  xd,  yd,  zd,  ref);
         }
      }
   }

   if(NmbTri || NmbQad)
   {
      GmfSetKwd(OutMsh, GmfBoundaryPolygonHeaders, NmbTri + NmbQad);

      if(NmbTri)
      {
         printf(" Adding  %d triangles to the polygons headers\n", NmbTri);
         GmfGotoKwd(InpMsh, GmfTriangles);

         for(i=1;i<=NmbTri;i++)
         {
            GmfGetLin(InpMsh, GmfTriangles, &nod[0], &nod[1], &nod[2], &ref);
            GmfSetLin(OutMsh, GmfBoundaryPolygonHeaders, (i-1) * 3 + 1, ref);
         }
      }

      if(NmbQad)
      {
         printf(" Adding  %d quads to the polygons headers\n", NmbQad);
         GmfGotoKwd(InpMsh, GmfQuadrilaterals);

         for(i=1;i<=NmbQad;i++)
         {
            GmfGetLin(InpMsh, GmfQuadrilaterals, &nod[0], &nod[1], &nod[2], &nod[3], &ref);
            GmfSetLin(OutMsh, GmfBoundaryPolygonHeaders, (i-1) * 4 + NmbTri * 3 + 1, ref);
         }
      }

      GmfSetKwd(OutMsh, GmfBoundaryPolygonVertices, NmbTri * 3 + NmbQad * 4);

      if(NmbTri)
      {
         printf(" Adding  %d triangles to the polygons faces\n", NmbTri);
         GmfGotoKwd(InpMsh, GmfTriangles);

         for(i=1;i<=NmbTri;i++)
         {
            GmfGetLin(InpMsh, GmfTriangles, &nod[0], &nod[1], &nod[2], &ref);

            for(j=0;j<3;j++)
               GmfSetLin(OutMsh, GmfBoundaryPolygonVertices, nod[j]);
         }
      }

      if(NmbQad)
      {
         printf(" Adding  %d quads to the polygons faces\n", NmbQad);
         GmfGotoKwd(InpMsh, GmfQuadrilaterals);

         for(i=1;i<=NmbQad;i++)
         {
            GmfGetLin(InpMsh, GmfQuadrilaterals, &nod[0], &nod[1], &nod[2], &nod[3], &ref);

            for(j=0;j<4;j++)
               GmfSetLin(OutMsh, GmfBoundaryPolygonVertices, nod[j]);
         }
      }
   }

   GmfCloseMesh(InpMsh);
   GmfCloseMesh(OutMsh);

   return(0);
}
