"""Equivalent Python de examples/test_libmeshb_block01.f90.

Acces par blocs avec des tableaux 1D a pas (stride) : les sommets sont stockes
a plat (x1,y1,z1,x2,...) comme dans l'exemple Fortran.  Les tableaux numpy
2D de pymeshb sont des vues de ces tableaux 1D (reshape sans copie).
"""
import os
import sys

import numpy as np

import _common
import pymeshb as pm


def main(outdir="."):
    inp_file = os.path.join(_common.SAMPLES, "quad.mesh")
    out_file = os.path.join(outdir, "tri.meshb")
    sol_file = os.path.join(outdir, "tri.solb")
    print("\ntest_libmeshb_block01_py")

    print("\nInput  Mesh Open         : %s" % inp_file)
    inp = pm.Mesh(inp_file, "r")
    ver, dim = inp.version, inp.dim
    print("Input  Mesh Idx          : %d" % inp.index)
    print("Input  Mesh ver          : %d" % ver)
    print("Input  Mesh dim          : %d" % dim)

    strd = 3
    nmb_ver = inp.count(pm.Vertices)
    print("Input  Mesh strd x NmbVer: %dx%d" % (strd, nmb_ver))
    xyz, ver_ref = inp.read_vertices()          # lecture du bloc 1..NmbVer
    ver_tab = xyz.reshape(-1)                    # vue 1D (stride 3)

    strd = 4
    nmb_qad = inp.count(pm.Quadrilaterals)
    print("Input  Mesh strd x NmbQad: %dx%d" % (strd, nmb_qad))
    q, qad_ref = inp.read_elements(pm.Quadrilaterals)
    qad_tab = q.reshape(-1)                      # vue 1D (stride 4)
    inp.close()
    print("Input  Mesh Close         : %s" % inp_file)

    # decoupage des quads en triangles, tableau plat (stride 3)
    strd = 3
    nmb_tri = 2 * nmb_qad
    tri_tab = np.empty(strd * nmb_tri, dtype=np.int32)
    tri_ref = np.empty(nmb_tri, dtype=np.int32)
    for i in range(nmb_qad):
        qd = qad_tab[4 * i:4 * i + 4]
        tri_tab[strd * (2 * i):strd * (2 * i) + 3] = qd[[0, 1, 2]]
        tri_ref[2 * i] = qad_ref[i]
        tri_tab[strd * (2 * i + 1):strd * (2 * i + 1) + 3] = qd[[0, 2, 3]]
        tri_ref[2 * i + 1] = qad_ref[i]

    print("\nOutput Mesh Open         : %s" % out_file)
    out = pm.Mesh(out_file, "w", ver, dim)
    print("Output Mesh Idx          : %d" % inp.index)
    print("Output Mesh ver          : %d" % ver)
    print("Output Mesh dim          : %d" % dim)
    print("Output Mesh strd x NmbVer: %dx%d" % (3, nmb_ver))
    out.write_vertices(ver_tab.reshape(nmb_ver, 3), ver_ref)
    print("Output Mesh strd x NmbTri: %dx%d" % (strd, nmb_tri))
    out.write_elements(pm.Triangles, tri_tab.reshape(nmb_tri, 3), tri_ref)
    out.close()
    print("Output Mesh Close        : %s" % out_file)

    print("\nOutput Solu Open         : %s" % sol_file)
    sol = pm.Mesh(sol_file, "w", ver, dim)
    print("Output Solu Idx          : %d" % sol.index)
    print("Output Solu ver          : %d" % ver)
    print("Output Solu dim          : %d" % dim)

    strd = 5
    fields = [pm.SCA, pm.VEC, pm.SCA]
    names = ["sca_1", "vec_1", "sca_2"]
    sol_tab = np.empty(strd * nmb_ver)
    print("Output Solu strd x NmbVer: %dx%d" % (strd, nmb_ver))
    print("Output Solu nFields      : %d" % len(fields))
    print("Output Solu fields       : %s " % " ".join(str(f) for f in fields))
    for i in range(nmb_ver):
        x, y = ver_tab[3 * i], ver_tab[3 * i + 1]
        sol_tab[strd * i:strd * i + strd] = [x, x, y, 0.0, y]
    sol.write_solution(pm.SolAtVertices, sol_tab.reshape(nmb_ver, strd), fields,
                       names=names, iteration=10, time=60.0)
    sol.close()
    print("Output Solu Close        : %s" % sol_file)
    print("\nControl\nvizir4 -in %s -sol %s\n" % (out_file, sol_file))


if __name__ == "__main__":
    main(*sys.argv[1:2])
