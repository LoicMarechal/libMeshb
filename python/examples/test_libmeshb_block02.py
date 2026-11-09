"""Equivalent Python de examples/test_libmeshb_block02.f90.

Acces par blocs avec des tableaux 2D (n, k) : tableaux numpy natifs, sans
boucle Python pour le decoupage des quadrilateres.
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
    print("\ntest_libmeshb_block02_py")

    print("\nInput  Mesh Open    : %s" % inp_file)
    with pm.Mesh(inp_file, "r") as inp:
        ver, dim = inp.version, inp.dim
        print("Input  Mesh Idx     : %d" % inp.index)
        print("Input  Mesh ver     : %d" % ver)
        print("Input  Mesh dim     : %d" % dim)
        ver_tab, ver_ref = inp.read_vertices()
        print("Input  Mesh NmbVer  : %d" % len(ver_tab))
        qad_tab, qad_ref = inp.read_elements(pm.Quadrilaterals)
        print("Input  Mesh NmbQad  : %d" % len(qad_tab))
    print("Input  Mesh Close   : %s" % inp_file)

    nmb_ver, nmb_qad = len(ver_tab), len(qad_tab)
    nmb_tri = 2 * nmb_qad
    tri_tab = np.empty((nmb_tri, 3), dtype=np.int32)
    tri_ref = np.empty(nmb_tri, dtype=np.int32)
    tri_tab[0::2] = qad_tab[:, [0, 1, 2]]
    tri_tab[1::2] = qad_tab[:, [0, 2, 3]]
    tri_ref[0::2] = qad_ref
    tri_ref[1::2] = qad_ref

    print("\nOutput Mesh Open    : %s" % out_file)
    with pm.Mesh(out_file, "w", ver, dim) as out:
        print("Output Mesh Idx     : %d" % out.index)
        print("Output Mesh ver     : %d" % ver)
        print("Output Mesh dim     : %d" % dim)
        out.write_vertices(ver_tab, ver_ref)
        print("Output Mesh NmbVer  : %d" % nmb_ver)
        out.write_elements(pm.Triangles, tri_tab, tri_ref)
        print("Output Mesh NmbTri  : %d" % nmb_tri)
    print("Output Mesh Close   : %s" % out_file)

    print("\nOutput Solu Open    : %s" % sol_file)
    fields = [pm.SCA, pm.VEC, pm.SCA]
    names = ["sca_1", "vec_1", "sca_2"]
    x, y = ver_tab[:, 0], ver_tab[:, 1]
    sol_tab = np.column_stack([x, x, y, np.zeros_like(x), y])   # (NmbVer, 1+3+1)
    with pm.Mesh(sol_file, "w", ver, dim) as sol:
        print("Output Solu Idx     : %d" % sol.index)
        print("Output Solu ver     : %d" % ver)
        print("Output Solu dim     : %d" % dim)
        print("Output Solu NmbVer  : %d" % nmb_ver)
        print("Output Solu nFields : %d" % len(fields))
        print("Output Solu fields  : %s " % " ".join(str(f) for f in fields))
        sol.write_solution(pm.SolAtVertices, sol_tab, fields, names=names,
                           iteration=10, time=60.0)
    print("Output Solu Close   : %s" % sol_file)
    print("\nControl\nvizir4 -in %s -sol %s\n" % (out_file, sol_file))


if __name__ == "__main__":
    main(*sys.argv[1:2])
