
/* Exemple d'utilisation de la libmesh7 : lecture de sol em block et générique */

#include <stdio.h>
#include <stdlib.h>
#include "libmesh7.h"


int main()
{
    int i, j, NmbSol, ver, dim, SolSiz, NmbTyp, TypTab[ GmfMaxTyp ];
    long long InpMsh, OutMsh;
    double *SolTab, *PtrTab1[ GmfMaxTyp ], *PtrTab2[ GmfMaxTyp ];


    /* Ouverture du fichier de solution "out.sol" */

    if(!(InpMsh = GmfOpenMesh("out.sol", GmfRead, &ver, &dim)))
        return(1);

    printf("InpMsh : idx = %d, version = %d, dimension = %d\n", InpMsh, ver, dim);

    if(ver < 2)
        return(1);

    /* Lecture des nombres de noeuds et de champs pour l'allocation de memoire */

    NmbSol = GmfStatKwd(InpMsh, GmfSolAtVertices, &NmbTyp, &SolSiz, TypTab);
    printf("NmbSol = %d, NmbTyp = %d, SolSiz = %d\n", NmbSol, NmbTyp, SolSiz);

    SolTab = malloc( (NmbSol+1) * SolSiz * sizeof(double));

    /* Remplissage de la table de pointeurs sur chaque entité de la première et deuxième lignes */

    for(i=0;i<SolSiz;i++)
    {
        PtrTab1[i] = &SolTab[ 1 * SolSiz + i ];
        PtrTab2[i] = &SolTab[ 2 * SolSiz + i ];
    }

    /* Lecture par block */

    GmfGetBlock( InpMsh, GmfSolAtVertices, NULL, GmfDoubleTable, PtrTab1, PtrTab2 );

    /* Affichage de tous les champs de toutes les lignes */

    for(i=1;i<=NmbSol;i++)
        for(j=0;j<SolSiz;j++)
            printf("%d, %d = %g\n", i, j, SolTab[ i * SolSiz + j ]);

    GmfCloseMesh(InpMsh);

    free(SolTab);

    return(0);
}
