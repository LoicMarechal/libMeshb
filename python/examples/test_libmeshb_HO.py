"""Equivalent Python de examples/test_libmeshb_HO.f90.

Lit un maillage de quadrilateres Q2 (en imposant l'ordre des noeuds voulu avec
set_ho_nodes_ordering), le decoupe en triangles P2 et ecrit une solution
d'ordre eleve (HOSolAtTrianglesP2, degre 5) echantillonnee aux noeuds de
reference d'un triangle.
"""
import os
import sys

import numpy as np

import _common
import pymeshb as pm


def base_lagrange_triangle_p2(u, v):
    """Fonctions de base P2 en (u, v) : tableau (..., 6)."""
    w = 1.0 - u - v
    return np.stack([w * (2 * w - 1), u * (2 * u - 1), v * (2 * v - 1),
                     4 * u * w, 4 * u * v, 4 * w * v], axis=-1)


def nodes_t3(order):
    """Noeuds de reference du triangle (coordonnees barycentriques), rangement `space`."""
    n = (order + 1) * (order + 2) // 2
    uvw = np.zeros((n, 3))
    if order == 0:
        uvw[0] = 1 / 3
    elif order == 1:
        uvw[:] = [[0, 0, 1], [1, 0, 0], [0, 1, 0]]
    elif order == 2:
        uvw[:] = [[0, 0, 1], [.5, 0, .5], [1, 0, 0], [0, .5, .5], [.5, .5, 0], [0, 1, 0]]
    else:
        for iu in range(order + 1):
            for iv in range(order + 1 - iu):
                iw = order - iu - iv
                ad = iu + iv * (order + 1) - (iv * (iv - 1)) // 2
                uvw[ad] = [iu / order, iv / order, iw / order]
    return uvw


def main(outdir="."):
    inp_file = os.path.join(_common.SAMPLES, "quad_q2.mesh")
    out_file = os.path.join(outdir, "tri_p2.meshb")
    sol_file = os.path.join(outdir, "tri_p2.solb")
    print("\ntest_libmeshb_HO_py")

    print("\nInput  Mesh File     : %s" % inp_file)
    inp = pm.Mesh(inp_file, "r")
    ver, dim = inp.version, inp.dim
    print("Input  Mesh Idx      : %d" % inp.index)
    print("Input  Mesh ver      : %d" % ver)
    print("Input  Mesh dim      : %d" % dim)
    if ver <= 1:
        sys.exit(" version <= 1")
    if dim != 3:
        sys.exit(" dimension <> 3")

    ver_tab, ver_ref = inp.read_vertices()
    nmb_ver = len(ver_tab)
    print("Input  Mesh NmbVer   : %d" % nmb_ver)

    gmf_cell, gmf_ord = pm.QuadrilateralsQ2, pm.QuadrilateralsQ2Ordering
    nmb_qad = inp.count(gmf_cell)
    print("Input  Mesh NmbQad   : %d" % nmb_qad)

    if inp.count(gmf_ord) != 0:
        print("Input  Mesh Reordering HO Nodes")
        # ordre souhaite (indices de Bezier) ...
        bas_tab = np.array([[0, 0], [2, 0], [2, 2], [0, 2],
                            [1, 0], [2, 1], [1, 2], [0, 1], [1, 1]], dtype=np.intc)
        print("Input  Mesh Requested Order")
        for i, uv in enumerate(bas_tab, 1):
            print("   uv(%02d)=%2d %2d " % (i, uv[0], uv[1]))
        # ... et ordre du fichier
        ord_tab = inp.read_table(gmf_ord)
        print("Input  Mesh Order")
        for i, uv in enumerate(ord_tab, 1):
            print("   uv(%02d)=%2d %2d " % (i, uv[0], uv[1]))
        inp.set_ho_nodes_ordering(gmf_cell, bas_tab, ord_tab)

    qad_tab, qad_ref = inp.read_elements(gmf_cell)
    inp.close()
    print("Input  Mesh Close    : %s" % inp_file)

    # decoupage de chaque Q2 en deux triangles P2
    nmb_tri = 2 * nmb_qad
    tri_tab = np.empty((nmb_tri, 6), dtype=np.int32)
    tri_ref = np.empty(nmb_tri, dtype=np.int32)
    tri_tab[0::2] = qad_tab[:, [0, 1, 2, 4, 5, 8]]
    tri_tab[1::2] = qad_tab[:, [0, 2, 3, 8, 6, 7]]
    tri_ref[0::2] = qad_ref
    tri_ref[1::2] = qad_ref

    print("\nOutput Mesh File     : %s" % out_file)
    with pm.Mesh(out_file, "w", ver, dim) as out:
        print("Output Mesh Idx      : %d" % out.index)
        print("Output Mesh ver      : %d" % ver)
        print("Output Mesh dim      : %d" % dim)
        out.write_vertices(ver_tab, ver_ref)
        print("Output Mesh NmbVer   : %d" % nmb_ver)
        out.write_elements(pm.TrianglesP2, tri_tab, tri_ref)
        print("Output Mesh NmbTri   : %d" % nmb_tri)
    print("Output Mesh Close    : %s" % out_file)

    # ---- solution d'ordre eleve ---------------------------------------
    print("\nOutput Solu Open     : %s" % sol_file)
    fields = [pm.SCA, pm.VEC, pm.SCA]
    names = ["sca_1", "vec_1", "sca_2"]
    order = 5                       # degre de la solution (modifiable)
    nnod = (order + 1) * (order + 2) // 2
    print("Output Solu ord      : %d" % order)
    print("Output Solu nNod     : %d" % nnod)

    uvw = nodes_t3(order)
    # coordonnees physiques des noeuds de solution : x = sum_j li(uvw_i) x_j
    li = base_lagrange_triangle_p2(uvw[:, 1], uvw[:, 2])           # (nnod, 6)
    xyz = np.einsum("ij,tjk->tik", li, ver_tab[tri_tab - 1])       # (nmb_tri, nnod, 3)
    sol_tab = np.stack([xyz[..., 0],                               # sca_1
                        xyz[..., 0], xyz[..., 1], np.zeros_like(xyz[..., 0]),  # vec_1
                        xyz[..., 1]], axis=-1)                     # sca_2
    print("Output Solu size(sol): %dx%d" % (sol_tab.shape[1] * sol_tab.shape[2], nmb_tri))

    with pm.Mesh(sol_file, "w", ver, dim) as sol:
        print("Output Solu Idx      : %d" % sol.index)
        print("Output Solu ver      : %d" % ver)
        print("Output Solu dim      : %d" % dim)
        sol.write_iteration(10)
        sol.write_time(60.0)
        sol.write_table(pm.HOSolAtTrianglesP2NodesPositions, uvw)
        sol.write_solution(pm.HOSolAtTrianglesP2, sol_tab, fields, names=names,
                           degree=order, nnodes=nnod)
    print("Output Solu Close    : %s" % sol_file)
    print("\nControl\nvizir4 -in %s -sol %s\n" % (out_file, sol_file))


if __name__ == "__main__":
    main(*sys.argv[1:2])
