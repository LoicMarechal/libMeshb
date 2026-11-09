"""Ouvre un maillage Inria (.mesh/.meshb) et affiche son contenu.

Usage : python lire_maillage.py [toto.meshb]
"""
import sys

import numpy as np

import pymeshb as pm

nom = sys.argv[1] if len(sys.argv) > 1 else "toto.meshb"

with pm.Mesh(nom, "r") as m:
    # --- géométrie et dimensions --------------------------------------
    nb_vertices = m.count(pm.Vertices)
    nb_tetra = m.count(pm.Tetrahedra)
    nb_triangles = m.count(pm.Triangles)

    print("Maillage              :", nom)
    print("Version du format     :", m.version)
    print("Dimension (géométrie) : %dD" % m.dim)
    print("Nombre de vertices    :", nb_vertices)
    print("Nombre de tétraèdres  :", nb_tetra)
    print("Nombre de triangles   :", nb_triangles)

    # --- lecture (indices des sommets en base 1, comme dans le fichier) --
    xyz, ref_vertices = m.read_vertices()                      # (nv, dim), (nv,)
    tetra, ref_tetra = m.read_elements(pm.Tetrahedra)          # (nt, 4),   (nt,)
    triangles, ref_triangles = m.read_elements(pm.Triangles)   # (ntri, 3), (ntri,)

print("\nVertices   :", xyz.shape, "marqueurs :", np.unique(ref_vertices))
print("Tétraèdres :", tetra.shape, "marqueurs :", np.unique(ref_tetra))
print("Triangles  :", triangles.shape, "marqueurs :", np.unique(ref_triangles))

# aperçu des premières entités
print("\nPremiers vertices (x y z | marqueur) :")
for p, r in zip(xyz[:3], ref_vertices[:3]):
    print("  ", p, "|", r)
print("Premiers tétraèdres :", tetra[:3].tolist())
print("Premiers triangles (sommets | marqueur) :")
for t, r in zip(triangles[:3], ref_triangles[:3]):
    print("  ", t, "|", r)
