"""pymeshb : interface Python pour libMeshb (formats Inria GMF)."""
from ._meshb import (Mesh, Solution, KEYWORDS, SCA, VEC, SYMMAT, MAT, READ, WRITE,
                     keyword, keyword_name, type_width, open)

# Constantes de mots-cles : pymeshb.Vertices, pymeshb.Triangles, pymeshb.SolAtVertices...
globals().update(KEYWORDS)
GmfSca, GmfVec, GmfSymMat, GmfMat = SCA, VEC, SYMMAT, MAT

__all__ = ["Mesh", "Solution", "KEYWORDS", "SCA", "VEC", "SYMMAT", "MAT", "READ",
           "WRITE", "keyword", "keyword_name", "type_width", "open"] + sorted(KEYWORDS)
__version__ = "0.1.0"
