# cython: language_level=3, boundscheck=False, wraparound=False, cdivision=True
"""
pymeshb : interface Python (Cython) pour libMeshb 8.

Les tableaux echanges avec la bibliotheque sont des tableaux numpy.  Les
indices de sommets restent ceux du fichier (base 1) sauf demande contraire
(zero_based=True).
"""

import os
from collections import namedtuple

import numpy as np

from libc.stdint cimport int64_t

cdef extern from "libmeshb8.h":
    enum: GmfRead
    enum: GmfWrite
    enum: GmfFloat
    enum: GmfDouble
    enum: GmfInt
    enum: GmfLong
    enum: GmfFloatVec
    enum: GmfDoubleVec
    enum: GmfIntVec
    enum: GmfLongVec
    enum: GmfSca
    enum: GmfVec
    enum: GmfSymMat
    enum: GmfMat

    int64_t GmfOpenMesh(const char *, int, ...)
    int     GmfCloseMesh(int64_t)
    int64_t GmfStatKwd(int64_t, int, ...)
    int     GmfSetKwd(int64_t, int, int64_t, ...)
    int     GmfGotoKwd(int64_t, int)
    int     GmfGetLin(int64_t, int, ...)
    int     GmfSetLin(int64_t, int, ...)
    int     GmfGetBlock(int64_t, int, int64_t, int64_t, int, void *, void *, ...)
    int     GmfSetBlock(int64_t, int, int64_t, int64_t, int, void *, void *, ...)
    int     GmfSetHONodesOrdering(int64_t, int, int *, int *)
    const char *GmfKwdFmt[][3]

# KEYWORDS (nom -> code) et _F77_REF (drapeaux de reference), generes par setup.py
include "_keywords.pxi"

SCA = GmfSca
VEC = GmfVec
SYMMAT = GmfSymMat
MAT = GmfMat
READ = GmfRead
WRITE = GmfWrite

KWD_NAMES = {v: k for k, v in KEYWORDS.items()}

Solution = namedtuple("Solution", "data types names degree nnodes positions")
Solution.__doc__ = """Champ de solution lu par Mesh.read_solution().

data      : (n, taille) float64, ou (n, nnodes, composantes par noeud) pour une
            solution d'ordre eleve
types     : liste de SCA / VEC / SYMMAT / MAT
names     : noms des champs (ReferenceStrings) ou None
degree    : degre de la solution d'ordre eleve (0 sinon)
nnodes    : nombre de noeuds par element (0 sinon)
positions : (nnodes, ncoord) coordonnees des noeuds (HO) ou None
"""


def keyword(name):
    """Code d'un mot-cle a partir de son nom ('Vertices' ou 'GmfVertices')."""
    if name.startswith("Gmf"):
        name = name[3:]
    return KEYWORDS[name]


def keyword_name(int code):
    return KWD_NAMES[code]


def type_width(int kind, int dim):
    """Nombre de reels d'un champ SCA / VEC / SYMMAT / MAT en dimension dim."""
    if kind == GmfSca:
        return 1
    if kind == GmfVec:
        return dim
    if kind == GmfSymMat:
        return dim * (dim + 1) // 2
    if kind == GmfMat:
        return dim * dim
    raise ValueError("type de champ inconnu : %d" % kind)


cdef str _fmt(int kwd):
    cdef bytes b = GmfKwdFmt[kwd][2]
    return b.decode()


cdef class Mesh:
    """Fichier de maillage ou de solution GMF (.mesh/.meshb/.sol/.solb).

    Mesh(nom, "r")                  lecture ; version et dim lues dans le fichier
    Mesh(nom, "w", version, dim)    ecriture (1 : float, 2 : double,
                                    3 et 4 : double + entiers 64 bits)
    """

    cdef int64_t idx
    cdef readonly int64_t index   # indice libMeshb (conserve apres close)
    cdef public int version
    cdef public int dim
    cdef readonly object filename
    cdef readonly str mode

    def __init__(self, filename, mode="r", int version=2, int dim=3):
        cdef int ver = version
        cdef int d = dim
        cdef bytes fn = os.fsencode(filename)
        self.filename = os.fspath(filename)
        self.mode = mode
        self.idx = 0
        if mode == "r":
            self.idx = GmfOpenMesh(fn, GmfRead, &ver, &d)
        elif mode == "w":
            self.idx = GmfOpenMesh(fn, GmfWrite, ver, d)
        else:
            raise ValueError("mode doit valoir 'r' ou 'w'")
        if self.idx == 0:
            raise OSError("libMeshb ne peut pas ouvrir %s" % filename)
        self.index = self.idx
        self.version = ver
        self.dim = d

    def __dealloc__(self):
        if self.idx != 0:
            GmfCloseMesh(self.idx)
            self.idx = 0

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()
        return False

    def __repr__(self):
        return "<Mesh %r mode=%r version=%d dim=%d%s>" % (
            self.filename, self.mode, self.version, self.dim,
            "" if self.idx else " closed")

    def close(self):
        if self.idx != 0:
            GmfCloseMesh(self.idx)
            self.idx = 0

    cdef int _check(self) except -1:
        if self.idx == 0:
            raise ValueError("fichier ferme")
        return 0

    # ------------------------------------------------------------------
    # Informations
    # ------------------------------------------------------------------
    def count(self, int kwd):
        """Nombre de lignes du mot-cle (0 s'il est absent)."""
        cdef int nt = 0, sz = 0, deg = 0, nn = 0
        cdef int typ[1000]
        self._check()
        return GmfStatKwd(self.idx, kwd, &nt, &sz, typ, &deg, &nn)

    def info(self, int kwd):
        """dict(count, ntypes, solsize, types, degree, nnodes) du mot-cle."""
        cdef int nt = 0, sz = 0, deg = 0, nn = 0
        cdef int typ[1000]
        cdef int64_t n
        self._check()
        n = GmfStatKwd(self.idx, kwd, &nt, &sz, typ, &deg, &nn)
        return dict(count=n, ntypes=nt, solsize=sz,
                    types=[typ[i] for i in range(nt)], degree=deg, nnodes=nn)

    def goto(self, int kwd):
        """Positionne le fichier au debut du mot-cle (avant get_line)."""
        self._check()
        if GmfGotoKwd(self.idx, kwd) == 0:
            raise KeyError("mot-cle absent du fichier")

    def _bounds(self, int kwd, first, last):
        cdef int64_t total = self.count(kwd)
        cdef int64_t a = first
        cdef int64_t b = total if last is None else last
        if total == 0:
            return 0, 0, 0
        if a < 1 or b > total or a > b:
            raise IndexError("intervalle %d..%d hors de 1..%d" % (a, b, total))
        return a, b, b - a + 1

    @property
    def iteration(self):
        """Numero d'iteration (mot-cle Iterations) ou None."""
        cdef int it32 = 0
        cdef int64_t it64 = 0
        if self.count(GmfIterations) < 1:
            return None
        GmfGotoKwd(self.idx, GmfIterations)
        if self.version <= 3:
            GmfGetLin(self.idx, GmfIterations, &it32)
            return it32
        GmfGetLin(self.idx, GmfIterations, &it64)
        return it64

    @property
    def time(self):
        """Temps physique (mot-cle Time) ou None."""
        cdef float t32 = 0
        cdef double t64 = 0
        if self.count(GmfTime) < 1:
            return None
        GmfGotoKwd(self.idx, GmfTime)
        if self.version == 1:
            GmfGetLin(self.idx, GmfTime, &t32)
            return float(t32)
        GmfGetLin(self.idx, GmfTime, &t64)
        return t64

    # ------------------------------------------------------------------
    # Lecture par blocs
    # ------------------------------------------------------------------
    def read_vertices(self, first=1, last=None):
        """Renvoie (xyz (n, dim) float64, ref (n,) int32)."""
        cdef int64_t a, b, n
        cdef int dim = self.dim
        cdef double[:, ::1] xyz
        cdef int[::1] ref
        a, b, n = self._bounds(GmfVertices, first, last)
        xyz_a = np.empty((n, dim), dtype=np.float64)
        ref_a = np.empty(n, dtype=np.intc)
        if n == 0:
            return xyz_a, ref_a
        xyz = xyz_a
        ref = ref_a
        if GmfGetBlock(self.idx, GmfVertices, a, b, 0, NULL, NULL,
                       GmfDoubleVec, dim, &xyz[0, 0], &xyz[n - 1, 0],
                       GmfInt, &ref[0], &ref[n - 1]) == 0:
            raise IOError("lecture des sommets impossible")
        return xyz_a, ref_a

    def read_elements(self, int kwd, first=1, last=None, dtype=np.int32,
                      zero_based=False):
        """Renvoie (conn (n, k), ref (n,)) pour un mot-cle d'element
        (Edges, Triangles, ..., TrianglesP2, ...)."""
        cdef int64_t a, b, n
        cdef int k
        cdef int[:, ::1] t32
        cdef int64_t[:, ::1] t64
        fmt = _fmt(kwd)
        if not fmt or set(fmt) != {"i"}:
            raise ValueError("%s n'est pas un mot-cle d'element" % KWD_NAMES.get(kwd, kwd))
        k = len(fmt) - 1
        a, b, n = self._bounds(kwd, first, last)
        dt = np.dtype(dtype)
        if dt not in (np.dtype(np.int32), np.dtype(np.int64)):
            raise ValueError("dtype doit etre int32 ou int64")
        tab = np.empty((n, k + 1), dtype=dt)
        if n > 0:
            if dt == np.dtype(np.int32):
                t32 = tab
                ok = GmfGetBlock(self.idx, kwd, a, b, 0, NULL, NULL,
                                 GmfIntVec, k + 1, &t32[0, 0], &t32[n - 1, 0])
            else:
                t64 = tab
                ok = GmfGetBlock(self.idx, kwd, a, b, 0, NULL, NULL,
                                 GmfLongVec, k + 1, &t64[0, 0], &t64[n - 1, 0])
            if ok == 0:
                raise IOError("lecture de %s impossible" % KWD_NAMES.get(kwd, kwd))
        conn = np.ascontiguousarray(tab[:, :k])
        if zero_based:
            conn -= 1
        return conn, np.ascontiguousarray(tab[:, k])

    def read_table(self, int kwd):
        """Table entiere ou reelle sans reference (tables *Ordering,
        *NodesPositions...).  Renvoie un tableau (n, ncol)."""
        cdef int64_t n
        cdef int ncol
        cdef int[:, ::1] ti
        cdef double[:, ::1] td
        fmt = _fmt(kwd)
        ncol = len(fmt)
        n = self.count(kwd)
        if n == 0:
            return np.empty((0, ncol))
        if set(fmt) == {"i"}:
            tab = np.empty((n, ncol), dtype=np.intc)
            ti = tab
            ok = GmfGetBlock(self.idx, kwd, 1, n, 0, NULL, NULL,
                             GmfIntVec, ncol, &ti[0, 0], &ti[n - 1, 0])
        elif set(fmt) == {"r"}:
            tab = np.empty((n, ncol), dtype=np.float64)
            td = tab
            ok = GmfGetBlock(self.idx, kwd, 1, n, 0, NULL, NULL,
                             GmfDoubleVec, ncol, &td[0, 0], &td[n - 1, 0])
        else:
            raise ValueError("format de %s non gere" % KWD_NAMES.get(kwd, kwd))
        if ok == 0:
            raise IOError("lecture de %s impossible" % KWD_NAMES.get(kwd, kwd))
        return tab

    def read_reference_strings(self):
        """Liste de (mot-cle, numero de champ, nom) du mot-cle ReferenceStrings."""
        cdef int k = 0, num = 0
        cdef char buf[1024]
        cdef bytes s
        cdef int64_t n = self.count(GmfReferenceStrings)
        out = []
        if n < 1:
            return out
        GmfGotoKwd(self.idx, GmfReferenceStrings)
        for i in range(n):
            buf[0] = 0
            GmfGetLin(self.idx, GmfReferenceStrings, &k, &num, buf)
            s = buf
            out.append((k, num, s.decode("latin-1").strip()))
        return out

    def read_solution(self, int kwd, first=1, last=None):
        """Lit un champ SolAt* ou HOSolAt* : renvoie une Solution."""
        cdef int nt = 0, sz = 0, deg = 0, nn = 0
        cdef int typ[1000]
        cdef int64_t n, a, b, total
        cdef double[:, ::1] d
        self._check()
        total = GmfStatKwd(self.idx, kwd, &nt, &sz, typ, &deg, &nn)
        if total == 0:
            raise KeyError("mot-cle %s absent" % KWD_NAMES.get(kwd, kwd))
        a, b, n = self._bounds(kwd, first, last)
        data = np.empty((n, sz), dtype=np.float64)
        d = data
        if GmfGetBlock(self.idx, kwd, a, b, 0, NULL, NULL,
                       GmfDoubleVec, sz, &d[0, 0], &d[n - 1, 0]) == 0:
            raise IOError("lecture de %s impossible" % KWD_NAMES.get(kwd, kwd))
        types = [typ[i] for i in range(nt)]

        names = None
        strings = [s for s in self.read_reference_strings() if s[0] == kwd]
        if strings:
            names = ["sol%d" % (i + 1) for i in range(nt)]
            for _, num, label in strings:
                if 1 <= num <= nt:
                    names[num - 1] = label

        positions = None
        kname = KWD_NAMES.get(kwd, "")
        if kname.startswith("HOSolAt"):
            width = sum(type_width(t, self.dim) for t in types)
            data = data.reshape(n, nn, width)
            pname = kname + "NodesPositions"
            if pname in KEYWORDS and self.count(KEYWORDS[pname]) == nn:
                positions = self.read_table(KEYWORDS[pname])
        return Solution(data, types, names, deg, nn, positions)

    # ------------------------------------------------------------------
    # Lecture / ecriture ligne a ligne (mode "Fortran" de GmfGetLin/SetLin)
    # ------------------------------------------------------------------
    def _columns(self, int kwd):
        fmt = _fmt(kwd)
        cols = []
        i = 0
        while i < len(fmt):
            c = fmt[i]
            i += 1
            if c == "d":
                c = fmt[i]
                i += 1
                cols += [c] * self.dim
            elif c in "sh":
                # champ de solution : solsize reels (apres set_kwd / goto)
                cols += ["r"] * self.info(kwd)["solsize"]
                break
            else:
                cols.append(c)
        return cols

    def get_line(self, int kwd):
        """Lit la ligne suivante (apres goto) : renvoie (valeurs, reference).
        valeurs : reels (sommets...) ou entiers (elements) ; reference : int ou None."""
        cdef int ref = 0
        cdef int[::1] it
        cdef double[::1] db
        self._check()
        cols = self._columns(kwd)
        ncol = len(cols)
        has_ref = bool(_F77_REF[kwd])
        it_a = np.zeros(ncol + 1, dtype=np.intc)
        db_a = np.zeros(ncol + 1, dtype=np.float64)
        it = it_a
        db = db_a
        if GmfGetLin(self.idx, -kwd, &it[0], &db[0], &ref) == 0:
            raise IOError("lecture de ligne impossible")
        nval = ncol - (1 if has_ref else 0)
        if set(cols[:nval]) == {"r"}:
            vals = db_a[:nval].copy()
        elif set(cols[:nval]) == {"i"}:
            vals = it_a[:nval].copy()
        else:
            raise NotImplementedError("colonnes mixtes non gerees")
        return vals, (ref if has_ref else None)

    def set_line(self, int kwd, values, ref=0):
        """Ecrit une ligne (apres set_kwd) : valeurs reelles ou entieres + reference."""
        cdef int r = ref
        cdef int[::1] it
        cdef double[::1] db
        self._check()
        cols = self._columns(kwd)
        ncol = len(cols)
        has_ref = bool(_F77_REF[kwd])
        nval = ncol - (1 if has_ref else 0)
        values = np.asarray(values)
        if values.size != nval:
            raise ValueError("%d valeurs attendues, %d fournies" % (nval, values.size))
        it_a = np.zeros(ncol + 1, dtype=np.intc)
        db_a = np.zeros(ncol + 1, dtype=np.float64)
        if set(cols[:nval]) == {"r"}:
            db_a[:nval] = values
        else:
            it_a[:nval] = values
        it = it_a
        db = db_a
        if GmfSetLin(self.idx, -kwd, &it[0], &db[0], &r) == 0:
            raise IOError("ecriture de ligne impossible")

    def set_kwd(self, int kwd, int64_t n):
        """Declare n lignes pour un mot-cle ordinaire (sommets, elements, tables)."""
        self._check()
        if GmfSetKwd(self.idx, kwd, n) == 0:
            raise IOError("GmfSetKwd a echoue")

    # ------------------------------------------------------------------
    # Ecriture par blocs
    # ------------------------------------------------------------------
    def write_vertices(self, xyz, ref=None):
        cdef int64_t n
        cdef int dim = self.dim
        cdef double[:, ::1] x
        cdef int[::1] r
        self._check()
        xyz_a = np.ascontiguousarray(xyz, dtype=np.float64)
        if xyz_a.ndim != 2 or xyz_a.shape[1] != dim:
            raise ValueError("xyz doit avoir la forme (n, %d)" % dim)
        n = xyz_a.shape[0]
        ref_a = (np.zeros(n, dtype=np.intc) if ref is None
                 else np.ascontiguousarray(ref, dtype=np.intc))
        if ref_a.shape != (n,):
            raise ValueError("ref doit avoir la forme (n,)")
        if GmfSetKwd(self.idx, GmfVertices, n) == 0:
            raise IOError("GmfSetKwd(Vertices) a echoue")
        if n == 0:
            return
        x = xyz_a
        r = ref_a
        if GmfSetBlock(self.idx, GmfVertices, 1, n, 0, NULL, NULL,
                       GmfDoubleVec, dim, &x[0, 0], &x[n - 1, 0],
                       GmfInt, &r[0], &r[n - 1]) == 0:
            raise IOError("ecriture des sommets impossible")

    def write_elements(self, int kwd, conn, ref=None, zero_based=False):
        cdef int64_t n
        cdef int k
        cdef int[:, ::1] t
        self._check()
        fmt = _fmt(kwd)
        if not fmt or set(fmt) != {"i"}:
            raise ValueError("%s n'est pas un mot-cle d'element" % KWD_NAMES.get(kwd, kwd))
        k = len(fmt) - 1
        conn_a = np.asarray(conn)
        if conn_a.ndim != 2 or conn_a.shape[1] != k:
            raise ValueError("conn doit avoir la forme (n, %d)" % k)
        n = conn_a.shape[0]
        tab_a = np.empty((n, k + 1), dtype=np.intc)
        tab_a[:, :k] = conn_a + (1 if zero_based else 0)
        tab_a[:, k] = 0 if ref is None else np.asarray(ref)
        if GmfSetKwd(self.idx, kwd, n) == 0:
            raise IOError("GmfSetKwd a echoue")
        if n == 0:
            return
        t = tab_a
        if GmfSetBlock(self.idx, kwd, 1, n, 0, NULL, NULL,
                       GmfIntVec, k + 1, &t[0, 0], &t[n - 1, 0]) == 0:
            raise IOError("ecriture de %s impossible" % KWD_NAMES.get(kwd, kwd))

    def write_table(self, int kwd, data):
        """Ecrit une table entiere ou reelle (tables *Ordering, *NodesPositions...)."""
        cdef int64_t n
        cdef int ncol
        cdef int[:, ::1] ti
        cdef double[:, ::1] td
        self._check()
        fmt = _fmt(kwd)
        ncol = len(fmt)
        if set(fmt) == {"i"}:
            arr = np.ascontiguousarray(data, dtype=np.intc)
        elif set(fmt) == {"r"}:
            arr = np.ascontiguousarray(data, dtype=np.float64)
        else:
            raise ValueError("format de %s non gere" % KWD_NAMES.get(kwd, kwd))
        if arr.ndim != 2 or arr.shape[1] != ncol:
            raise ValueError("la table doit avoir la forme (n, %d)" % ncol)
        n = arr.shape[0]
        if GmfSetKwd(self.idx, kwd, n) == 0:
            raise IOError("GmfSetKwd a echoue")
        if n == 0:
            return
        if set(fmt) == {"i"}:
            ti = arr
            ok = GmfSetBlock(self.idx, kwd, 1, n, 0, NULL, NULL,
                             GmfIntVec, ncol, &ti[0, 0], &ti[n - 1, 0])
        else:
            td = arr
            ok = GmfSetBlock(self.idx, kwd, 1, n, 0, NULL, NULL,
                             GmfDoubleVec, ncol, &td[0, 0], &td[n - 1, 0])
        if ok == 0:
            raise IOError("ecriture de %s impossible" % KWD_NAMES.get(kwd, kwd))

    def write_iteration(self, int iteration):
        cdef int it32 = iteration
        cdef int64_t it64 = iteration
        self._check()
        GmfSetKwd(self.idx, GmfIterations, 1)
        if self.version <= 3:
            GmfSetLin(self.idx, GmfIterations, it32)
        else:
            GmfSetLin(self.idx, GmfIterations, it64)

    def write_time(self, double time):
        self._check()
        GmfSetKwd(self.idx, GmfTime, 1)
        GmfSetLin(self.idx, GmfTime, time)

    def begin_solution(self, int kwd, int64_t n, types, names=None, iteration=None,
                       time=None, int degree=0, int nnodes=0):
        """Declare un champ SolAt* ou HOSolAt* de n lignes (ecrit avant :
        iteration, temps, noms des champs) ; les lignes sont ensuite ecrites
        avec set_line.  types : liste de SCA / VEC / SYMMAT / MAT ;
        degree, nnodes : obligatoires pour HOSolAt*."""
        cdef int nt
        cdef int[::1] ty
        self._check()
        kname = KWD_NAMES.get(kwd, "")
        ho = kname.startswith("HOSolAt")
        types_a = np.ascontiguousarray(types, dtype=np.intc)
        nt = types_a.shape[0]
        if ho and (degree < 1 or nnodes < 1):
            raise ValueError("degree et nnodes sont obligatoires pour %s" % kname)
        if iteration is not None:
            self.write_iteration(iteration)
        if time is not None:
            self.write_time(time)
        if names is not None:
            self.write_reference_strings([(kwd, i + 1, s) for i, s in enumerate(names)])
        ty = types_a
        if ho:
            ok = GmfSetKwd(self.idx, kwd, n, nt, &ty[0], degree, nnodes)
        else:
            ok = GmfSetKwd(self.idx, kwd, n, nt, &ty[0])
        if ok == 0:
            raise IOError("GmfSetKwd(%s) a echoue" % kname)

    def write_solution(self, int kwd, data, types, names=None, iteration=None,
                       time=None, int degree=0, int nnodes=0):
        """Ecrit un champ SolAt* ou HOSolAt* complet.

        data  : (n, taille) ou, en ordre eleve, (n, nnodes, composantes par noeud)
        types : liste de SCA / VEC / SYMMAT / MAT
        names : noms des champs (ReferenceStrings), facultatif
        iteration, time : ecrits avant le champ si fournis
        degree, nnodes  : obligatoires pour HOSolAt*"""
        cdef int64_t n
        cdef int sz
        cdef double[:, ::1] d
        self._check()
        kname = KWD_NAMES.get(kwd, "")
        ho = kname.startswith("HOSolAt")
        width = sum(type_width(int(t), self.dim) for t in types)
        arr = np.ascontiguousarray(data, dtype=np.float64)
        n = arr.shape[0]
        arr = np.ascontiguousarray(arr.reshape(n, -1))
        if ho:
            width *= nnodes
        if arr.shape[1] != width:
            raise ValueError("%d valeurs par ligne attendues, %d fournies"
                             % (width, arr.shape[1]))
        sz = width
        self.begin_solution(kwd, n, types, names, iteration, time, degree, nnodes)
        if n > 0:
            d = arr
            if GmfSetBlock(self.idx, kwd, 1, n, 0, NULL, NULL,
                           GmfDoubleVec, sz, &d[0, 0], &d[n - 1, 0]) == 0:
                raise IOError("ecriture de %s impossible" % kname)

    def write_reference_strings(self, entries):
        """Ecrit ReferenceStrings : liste de (mot-cle, numero de champ, nom)."""
        cdef int k, num
        cdef bytes b
        self._check()
        entries = list(entries)
        if GmfSetKwd(self.idx, GmfReferenceStrings, len(entries)) == 0:
            raise IOError("GmfSetKwd(ReferenceStrings) a echoue")
        for k, num, label in entries:
            b = str(label).encode("latin-1")
            GmfSetLin(self.idx, GmfReferenceStrings, k, num, <const char *>b)

    # ------------------------------------------------------------------
    # Ordre des noeuds d'ordre eleve
    # ------------------------------------------------------------------
    def set_ho_nodes_ordering(self, int kwd, user_ordering, file_ordering):
        """GmfSetHONodesOrdering : fait lire/ecrire les elements d'ordre eleve
        dans l'ordre user_ordering (indices de Bezier, forme (nnoeuds, ncoord))
        quel que soit l'ordre du fichier (file_ordering)."""
        cdef int[:, ::1] u
        cdef int[:, ::1] f
        self._check()
        ua = np.ascontiguousarray(user_ordering, dtype=np.intc)
        fa = np.ascontiguousarray(file_ordering, dtype=np.intc)
        if ua.shape != fa.shape or ua.ndim != 2:
            raise ValueError("les deux tables doivent avoir la meme forme")
        u = ua
        f = fa
        if GmfSetHONodesOrdering(self.idx, kwd, &u[0, 0], &f[0, 0]) == 0:
            raise ValueError("GmfSetHONodesOrdering a echoue (tables incoherentes ?)")


def open(filename, mode="r", version=2, dim=3):
    """Raccourci pour Mesh(filename, mode, version, dim)."""
    return Mesh(filename, mode, version, dim)
