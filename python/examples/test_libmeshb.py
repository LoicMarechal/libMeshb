"""Equivalent Python de examples/test_libmeshb.f90 (acces ligne a ligne).

Lit un maillage de quadrilateres, le decoupe en triangles, ecrit le resultat
puis un fichier .solb factice (iteration, temps, 3 champs).
"""
import os
import sys

import numpy as np

import _common
import pymeshb as pm

SAMPLES = _common.SAMPLES


def main(outdir="."):
    inp_file = os.path.join(SAMPLES, "quad.mesh")
    out_file = os.path.join(outdir, "tri.meshb")
    sol_file = os.path.join(outdir, "tri.solb")
    print("\ntest_libmeshb_py")

    # ---- lecture du maillage de quadrilateres --------------------------
    print("\nInput  Mesh Open    : %s" % inp_file)
    inp = pm.Mesh(inp_file, "r")
    ver, dim = inp.version, inp.dim
    print("Input  Mesh Idx     : %d" % inp.index)
    print("Input  Mesh ver     : %d" % ver)
    print("Input  Mesh dim     : %d" % dim)
    if ver <= 1:
        sys.exit(" version <= 1")
    if dim != 3:
        sys.exit(" dimension <> 3")

    nmb_ver = inp.count(pm.Vertices)
    print("Input  Mesh NmbVer  : %d" % nmb_ver)
    ver_tab = np.empty((nmb_ver, 3))
    ver_ref = np.empty(nmb_ver, dtype=np.int32)
    inp.goto(pm.Vertices)
    for i in range(nmb_ver):
        ver_tab[i], ver_ref[i] = inp.get_line(pm.Vertices)

    nmb_qad = inp.count(pm.Quadrilaterals)
    print("Input  Mesh NmbQad  : %d" % nmb_qad)
    qad_tab = np.empty((nmb_qad, 4), dtype=np.int32)
    qad_ref = np.empty(nmb_qad, dtype=np.int32)
    inp.goto(pm.Quadrilaterals)
    for i in range(nmb_qad):
        qad_tab[i], qad_ref[i] = inp.get_line(pm.Quadrilaterals)

    inp.close()
    print("Input  Mesh Close   : %s" % inp_file)

    # ---- maillage triangulaire -----------------------------------------
    nmb_tri = 2 * nmb_qad
    print("\nOutput Mesh Open    : %s" % out_file)
    out = pm.Mesh(out_file, "w", ver, dim)
    print("Output Mesh Idx     : %d" % inp.index)
    print("Output Mesh ver     : %d" % ver)
    print("Output Mesh dim     : %d" % dim)

    out.set_kwd(pm.Vertices, nmb_ver)
    print("Output Mesh NmbVer  : %d" % nmb_ver)
    for i in range(nmb_ver):
        out.set_line(pm.Vertices, ver_tab[i], ver_ref[i])

    out.set_kwd(pm.Triangles, nmb_tri)
    print("Output Mesh NmbTri  : %d" % nmb_tri)
    for i in range(nmb_qad):
        out.set_line(pm.Triangles, qad_tab[i, 0:3], qad_ref[i])
        # on modifie le quad pour construire l'autre triangle de la diagonale
        qad_tab[i, 1] = qad_tab[i, 2]
        qad_tab[i, 2] = qad_tab[i, 3]
        out.set_line(pm.Triangles, qad_tab[i, 0:3], qad_ref[i])
    out.close()
    print("Output Mesh Close   : %s" % out_file)

    # ---- fichier solution ----------------------------------------------
    print("\nOutput Solu Open    : %s" % sol_file)
    sol = pm.Mesh(sol_file, "w", ver, dim)
    print("Output Solu Idx     : %d" % sol.index)
    print("Output Solu ver     : %d" % ver)
    print("Output Solu dim     : %d" % dim)

    sol.set_kwd(pm.Iterations, 1)
    sol.set_line(pm.Iterations, [10])
    sol.set_kwd(pm.Time, 1)
    sol.set_line(pm.Time, [60.0])

    fields = [pm.SCA, pm.VEC, pm.SCA]
    names = ["sca_1", "vec_1", "sca_2"]
    print("Output Solu NmbVer  : %d" % nmb_ver)
    print("Output Solu nFields : %d" % len(fields))
    print("Output Solu fields  : %s" % " ".join(str(f) for f in fields) + " ")

    # ecrit le mot-cle SolAtVertices (+ noms) ; les lignes suivent
    sol.begin_solution(pm.SolAtVertices, nmb_ver, fields, names=names)
    for i in range(nmb_ver):
        x, y = ver_tab[i, 0], ver_tab[i, 1]
        sol.set_line(pm.SolAtVertices, [x, x, y, 0.0, y])
    sol.close()
    print("Output Solu Close   : %s" % sol_file)

    print("\nControl:\nvizir4 -in %s -sol %s\n" % (out_file, sol_file))


if __name__ == "__main__":
    main(*sys.argv[1:2])
