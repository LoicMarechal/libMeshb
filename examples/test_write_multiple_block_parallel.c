
/* libMeshb 8.0 basic example: read a quad mesh, split it into triangles
   and write the result back */

#include <stdio.h>
#include <stdlib.h>
#include <libmeshb8.h>

int main()
{
  double ver[12] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
  int ref[6] = {1, 2, 3, 4, 5, 6};

  int64_t fid1 = GmfOpenMesh("write_multiple_block_parallel.mesh", GmfWrite, 3, 2);
  GmfSetKwd(fid1, GmfVertices, 6);
  GmfCloseMesh(fid1);

  int64_t fid2 = GmfOpenMesh("write_multiple_block_parallel.mesh", GmfParallelWrite, 3, 2);
  GmfSetBlock(fid2, GmfVertices, 1, 3, 0, NULL, NULL, GmfDoubleVec, 2,
        &(ver[0]), &(ver[4]), GmfInt, &ref[0], &ref[2]);
  GmfCloseMesh(fid2);

   return 0;
}
