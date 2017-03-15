

/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                               LIBMESH V 7.26                               */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/*    Description:        handle .meshb file format I/O                       */
/*    Author:             Loic MARECHAL                                       */
/*    Creation date:      dec 09 1999                                         */
/*    Last modification:  mar 08 2017                                         */
/*                                                                            */
/*----------------------------------------------------------------------------*/

// [Bruno] get PRINTF_INT64_MODIFIER
// #include <geogram/third_party/pstdint.h>

#include <stdint.h>

#ifndef LIBMESHB7_H
#define LIBMESHB7_H

/*----------------------------------------------------------------------------*/
/* Defines                                                                    */
/*----------------------------------------------------------------------------*/

#define GmfStrSiz 1024
#define GmfMaxTyp 1000
#define GmfMaxKwd GmfLastKeyword - 1
#define GmfMshVer 1
#define GmfRead 1
#define GmfWrite 2
#define GmfSca 1
#define GmfVec 2
#define GmfSymMat 3
#define GmfMat 4
#define GmfFloat 1
#define GmfDouble 2
#define GmfInt 3
#define GmfLong 4
#define GmfDoubleTable 5
#define GmfFloatTable 6

enum GmfKwdCod
{
   GmfReserved1, \
   GmfVersionFormatted, \
   GmfReserved2, \
   GmfDimension, \
   GmfVertices, \
   GmfEdges, \
   GmfTriangles, \
   GmfQuadrilaterals, \
   GmfTetrahedra, \
   GmfPrisms, \
   GmfHexahedra, \
   GmfReserved3, \
   GmfReserved4, \
   GmfCorners, \
   GmfRidges, \
   GmfRequiredVertices, \
   GmfRequiredEdges, \
   GmfRequiredTriangles, \
   GmfRequiredQuadrilaterals, \
   GmfTangentAtEdgeVertices, \
   GmfNormalAtVertices, \
   GmfNormalAtTriangleVertices, \
   GmfNormalAtQuadrilateralVertices, \
   GmfAngleOfCornerBound, \
   GmfTrianglesP2, \
   GmfEdgesP2, \
   GmfSolAtPyramids, \
   GmfQuadrilateralsQ2, \
   GmfISolAtPyramids, \
   GmfSubDomainFromGeom, \
   GmfTetrahedraP2, \
   GmfFault_NearTri, \
   GmfFault_Inter, \
   GmfHexahedraQ2, \
   GmfExtraVerticesAtEdges, \
   GmfExtraVerticesAtTriangles, \
   GmfExtraVerticesAtQuadrilaterals, \
   GmfExtraVerticesAtTetrahedra, \
   GmfExtraVerticesAtPrisms, \
   GmfExtraVerticesAtHexahedra, \
   GmfVerticesOnGeometricVertices, \
   GmfVerticesOnGeometricEdges, \
   GmfVerticesOnGeometricTriangles, \
   GmfVerticesOnGeometricQuadrilaterals, \
   GmfEdgesOnGeometricEdges, \
   GmfFault_FreeEdge, \
   GmfPolyhedra, \
   GmfPolygons, \
   GmfFault_Overlap, \
   GmfPyramids, \
   GmfBoundingBox, \
   GmfReserved5, \
   GmfPrivateTable, \
   GmfFault_BadShape, \
   GmfEnd, \
   GmfTrianglesOnGeometricTriangles, \
   GmfTrianglesOnGeometricQuadrilaterals, \
   GmfQuadrilateralsOnGeometricTriangles, \
   GmfQuadrilateralsOnGeometricQuadrilaterals, \
   GmfTangents, \
   GmfNormals, \
   GmfTangentAtVertices, \
   GmfSolAtVertices, \
   GmfSolAtEdges, \
   GmfSolAtTriangles, \
   GmfSolAtQuadrilaterals, \
   GmfSolAtTetrahedra, \
   GmfSolAtPrisms, \
   GmfSolAtHexahedra, \
   GmfDSolAtVertices, \
   GmfISolAtVertices, \
   GmfISolAtEdges, \
   GmfISolAtTriangles, \
   GmfISolAtQuadrilaterals, \
   GmfISolAtTetrahedra, \
   GmfISolAtPrisms, \
   GmfISolAtHexahedra, \
   GmfIterations, \
   GmfTime, \
   GmfFault_SmallTri, \
   GmfCoarseHexahedra, \
   GmfComments, \
   GmfPeriodicVertices, \
   GmfPeriodicEdges, \
   GmfPeriodicTriangles, \
   GmfPeriodicQuadrilaterals, \
   GmfPrismsP2, \
   GmfPyramidsP2, \
   GmfQuadrilateralsQ3, \
   GmfQuadrilateralsQ4, \
   GmfTrianglesP3, \
   GmfTrianglesP4, \
   GmfEdgesP3, \
   GmfEdgesP4, \
   GmfIRefGroups, \
   GmfDRefGroups, \
   GmfTetrahedraP3, \
   GmfTetrahedraP4, \
   GmfHexahedraQ3, \
   GmfHexahedraQ4, \
   GmfPyramidsP3, \
   GmfPyramidsP4, \
   GmfPrismsP3, \
   GmfPrismsP4, \
   GmfLastKeyword
};


#ifdef __cplusplus
extern "C" {
#endif

/*----------------------------------------------------------------------------*/
/* Public procedures                                                          */
/*----------------------------------------------------------------------------*/

extern int64_t GmfOpenMesh(const char *, int, ...);
extern int     GmfCloseMesh(int64_t);
extern int64_t GmfStatKwd(int64_t, int, ...);
extern int     GmfSetKwd(int64_t, int, ...);
extern int     GmfGotoKwd(int64_t, int);
extern int     GmfGetLin(int64_t, int, ...);
extern int     GmfSetLin(int64_t, int, ...);
extern int     GmfGetBlock(int64_t, int, int64_t, int64_t, void *, ...);
extern int     GmfSetBlock(int64_t, int, int64_t, int64_t, int, void *, void *, ...);


/*----------------------------------------------------------------------------*/
/* Transmesh private API                                                      */
/*----------------------------------------------------------------------------*/

#ifdef TRANSMESH
extern int GmfMaxRefTab[ GmfMaxKwd + 1 ];
extern const char *GmfKwdFmt[ GmfMaxKwd + 1 ][4];
extern int GmfCpyLin(int64_t, int64_t, int);
#endif

#ifdef __cplusplus
} // end extern "C"
#endif

#endif