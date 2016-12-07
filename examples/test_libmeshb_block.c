
/* libMeshb 7.2 basic example: read a quad mesh, split it into triangles
    and write the result back using fast block transfer */

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb7.h>


int main()
{
    int i, NmbVer, NmbQad, ver, dim, *RefTab, (*QadTab)[5], (*TriTab)[4];
    long long InpMsh, OutMsh;
    float (*VerTab)[3];


    /*-----------------------------------*/
	/* Open mesh file "quad.meshb"       */
    /*-----------------------------------*/

    if(!(InpMsh = GmfOpenMesh("quad.meshb", GmfRead, &ver, &dim)))
        return(1);

    printf("InpMsh : idx = %lld, version = %d, dimension = %d\n", InpMsh, ver, dim);

    if(dim != 3)
        exit(1);

	/* Read the number of vertices and allocate memory */
    NmbVer = GmfStatKwd(InpMsh, GmfVertices);
    printf("InpMsh : nmb vertices = %d\n", NmbVer);
    VerTab = malloc((NmbVer+1) * 3 * sizeof(float));
    RefTab = malloc((NmbVer+1) * sizeof(int));

	/* Read the number of quads and allocate memory */
    NmbQad = GmfStatKwd(InpMsh, GmfQuadrilaterals);
    printf("InpMsh : nmb quads = %d\n", NmbQad);
    QadTab = malloc((NmbQad+1) * 5 * sizeof(int));
    TriTab = malloc((NmbQad+1) * 2 * 4 * sizeof(int));

	/* Read the vertices */
    GmfGetBlock(InpMsh, GmfVertices, 1, NmbVer, NULL, \
                GmfFloat, &VerTab[1][0], &VerTab[ NmbVer ][0], \
                GmfFloat, &VerTab[1][1], &VerTab[ NmbVer ][1], \
                GmfFloat, &VerTab[1][2], &VerTab[ NmbVer ][2], \
                GmfInt,   &RefTab[1],    &RefTab[ NmbVer ] );

	/* Read the quads */
    GmfGetBlock(InpMsh, GmfQuadrilaterals, 1, NmbQad, NULL, \
                GmfInt, &QadTab[1][0], &QadTab[ NmbQad ][0], \
                GmfInt, &QadTab[1][1], &QadTab[ NmbQad ][1], \
                GmfInt, &QadTab[1][2], &QadTab[ NmbQad ][2], \
                GmfInt, &QadTab[1][3], &QadTab[ NmbQad ][3], \
                GmfInt, &QadTab[1][4], &QadTab[ NmbQad ][4] );

	/* Close the quad mesh */
    GmfCloseMesh(InpMsh);


    /*-----------------------------------*/
    /* Create the triangluated mesh      */
    /*-----------------------------------*/

    for(i=1;i<=NmbQad;i++)
    {
        TriTab[i*2-1][0] = QadTab[i][0];
        TriTab[i*2-1][1] = QadTab[i][1];
        TriTab[i*2-1][2] = QadTab[i][2];
        TriTab[i*2-1][3] = QadTab[i][4];

        TriTab[i*2][0] = QadTab[i][0];
        TriTab[i*2][1] = QadTab[i][2];
        TriTab[i*2][2] = QadTab[i][3];
        TriTab[i*2][3] = QadTab[i][4];
    }


	/*-----------------------------------*/
	/* Write the triangle mesh           */
	/*-----------------------------------*/

    if(!(OutMsh = GmfOpenMesh("tri.meshb", GmfWrite, ver, dim)))
        return(1);

	/* Write the vertices */
    GmfSetKwd(OutMsh, GmfVertices, NmbVer);
    GmfSetBlock(OutMsh, GmfVertices, NULL, \
                GmfFloat, &VerTab[1][0], &VerTab[ NmbVer ][0], \
                GmfFloat, &VerTab[1][1], &VerTab[ NmbVer ][1], \
                GmfFloat, &VerTab[1][2], &VerTab[ NmbVer ][2], \
                GmfInt,   &RefTab[1],    &RefTab[ NmbVer ] );

	/* Write the triangles */
    GmfSetKwd(OutMsh, GmfTriangles, 2*NmbQad);
    GmfSetBlock(OutMsh, GmfTriangles, NULL, \
                GmfInt, &TriTab[1][0], &TriTab[ 2*NmbQad ][0], \
                GmfInt, &TriTab[1][1], &TriTab[ 2*NmbQad ][1], \
                GmfInt, &TriTab[1][2], &TriTab[ 2*NmbQad ][2], \
                GmfInt, &TriTab[1][3], &TriTab[ 2*NmbQad ][3] );

	/* Do not forget to close the mesh file */
    GmfCloseMesh(OutMsh);
    printf("OutMsh : nmb triangles = %d\n", 2*NmbQad);

    free(QadTab);
    free(TriTab);
    free(RefTab);
    free(VerTab);

    return(0);
}
