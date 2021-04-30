

/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                            LIBMESHB-HELPERS V0.9                           */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Description:         libmeshb's helper functions' headers                  */
/* Author:              Loic MARECHAL                                         */
/* Creation date:       mar 24 2021                                           */
/* Last modification:   mar 24 2021                                           */
/*                                                                            */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/* Defines                                                                    */
/*----------------------------------------------------------------------------*/

#include <stdint.h>

#ifdef INT64
#define itg int64_t
#else
#define itg int32_t
#endif

#ifdef REAL32
#define fpn float
#else
#define fpn double
#endif

/*----------------------------------------------------------------------------*/
/* Prototypes of public structures                                            */
/*----------------------------------------------------------------------------*/

typedef struct
{
   int64_t MshIdx;
   itg NmbBndHdr, (*BndHdrTab)[2], NmbBndVer, *BndVerTab;
   itg NmbInrHdr, (*InrHdrTab)[2], NmbInrVer, *InrVerTab;
   itg NmbVolHdr, (*VolHdrTab)[2], NmbVolFac, *VolFacTab;
} PolMshSct;

/*----------------------------------------------------------------------------*/
/* Prototypes of public procedures                                            */
/*----------------------------------------------------------------------------*/

PolMshSct *GmfAllocatePolyghedralStructure(int64_t);
void GmfFreePolyghedralStructure(PolMshSct *);
int GmfReadBoundaryPolygons(PolMshSct *);
int GmfReadPolyhedra(PolMshSct *);
itg GmfGetBoundaryPolygon(PolMshSct *, itg, itg *);
itg GmfGetInnerPolygon(PolMshSct *, itg, itg *);
itg GmfGetPolyhedron(PolMshSct *, itg, itg *);
itg GmfTesselatePolygon(PolMshSct *, itg, itg (*)[3], itg (*)[3]);