# pymeshb — interface Python (Cython) pour libMeshb 8

Lecture et écriture des formats Inria `.mesh`, `.meshb`, `.sol`, `.solb`
(versions 1 à 4) avec des tableaux numpy. Le module compile `sources/libmeshb8.c`
directement (aucune bibliothèque externe à installer).

## Installation

    cd libMeshb/python
    pip install .            # ou : python setup.py build_ext --inplace

Avec CMake (depuis la racine de libMeshb) :

    cmake .. -DENABLE_PYTHON=ON -DPYTHON_EXECUTABLE=$PYTHON3 [-DWITH_GMF_CTEST=ON]
    make && make install

Le package est installé dans `<prefix>/lib/pythonX.Y/site-packages` (à ajouter à
`PYTHONPATH` si besoin) ; `ctest -R pymeshb` lance les tests.

Prérequis : un compilateur C, `Cython >= 3`, `numpy`, `setuptools`.

> `libmeshb8.c` est compilé avec `PipBufSiz = 32768` : avec la valeur d'origine
> (10 000 000 lignes), `GmfGetBlock`/`GmfSetBlock` échouent (malloc) sur les
> lignes larges, typiquement les solutions d'ordre élevé.

## Utilisation

    import pymeshb as pm

    with pm.Mesh("quad.mesh") as m:                 # lecture
        print(m.version, m.dim, m.count(pm.Quadrilaterals))
        xyz, ref = m.read_vertices()                # (n, dim) float64, (n,) int32
        quad, qref = m.read_elements(pm.Quadrilaterals)   # indices en base 1

    with pm.Mesh("out.meshb", "w", 2, 3) as o:      # écriture : version 2, dim 3
        o.write_vertices(xyz, ref)
        o.write_elements(pm.Quadrilaterals, quad, qref)

    with pm.Mesh("out.solb", "w", 2, 3) as o:       # solution aux sommets
        o.write_solution(pm.SolAtVertices, data, [pm.SCA, pm.VEC],
                         names=["p", "u"], iteration=10, time=60.0)
    with pm.Mesh("out.solb") as s:
        sol = s.read_solution(pm.SolAtVertices)     # sol.data, .types, .names

| Méthode | Rôle |
|---|---|
| `Mesh(nom, "r")` / `Mesh(nom, "w", version, dim)` | ouverture (`pm.open` en raccourci) |
| `count(kwd)`, `info(kwd)`, `iteration`, `time` | informations |
| `read_vertices`, `read_elements`, `read_table`, `read_solution` | lecture par blocs |
| `write_vertices`, `write_elements`, `write_table`, `write_solution` | écriture par blocs |
| `goto`, `get_line` / `set_kwd`, `set_line` | accès ligne à ligne (y compris solutions) |
| `begin_solution` | déclare un champ de solution avant `set_line` |
| `set_ho_nodes_ordering` | ordre des nœuds d'ordre élevé (`GmfSetHONodesOrdering`) |

Les mots-clés sont des constantes du module : `pm.Vertices`, `pm.Triangles`,
`pm.TrianglesP2`, `pm.SolAtVertices`, `pm.HOSolAtTrianglesP2`,
`pm.HOSolAtTrianglesP2NodesPositions`... (liste dans `pm.KEYWORDS`).
Types de champs : `pm.SCA`, `pm.VEC`, `pm.SYMMAT`, `pm.MAT`.
Une solution d'ordre élevé est lue sous la forme `(n, nnodes, composantes)`.

## Exemples (équivalents des exemples Fortran)

| Python | Fortran |
|---|---|
| `examples/test_libmeshb.py` | `test_libmeshb.f90` (ligne à ligne) |
| `examples/test_libmeshb_block01.py` | `test_libmeshb_block01.f90` (blocs, tableaux 1D à pas) |
| `examples/test_libmeshb_block02.py` | `test_libmeshb_block02.f90` (blocs, tableaux 2D) |
| `examples/test_libmeshb_HO.py` | `test_libmeshb_HO.f90` (Q2 → triangles P2, solution d'ordre 5) |

    cd python/examples && python test_libmeshb.py [dossier_de_sortie]

Les exemples parallèles (MPI/OpenMP) et l'exemple `bindC` ne sont pas portés.
Tests : `python -m unittest discover tests`.
