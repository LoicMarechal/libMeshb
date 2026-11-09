"""Compilation de pymeshb : python setup.py build_ext --inplace  (ou pip install .)"""
import os
import re
import shutil

import numpy
from Cython.Build import cythonize
from setuptools import Extension, setup

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "sources")
if not os.path.isdir(SRC):                 # sdist : sources copiees ici
    SRC = os.path.join(HERE, "csrc")
BUILD = os.environ.get("PYMESHB_BUILD_DIR", os.path.join(HERE, "build"))
GEN = os.path.join(BUILD, "gen")
os.makedirs(GEN, exist_ok=True)

header = open(os.path.join(SRC, "libmeshb8.h")).read()
csrc = open(os.path.join(SRC, "libmeshb8.c")).read()

# --- mots-cles : enum GmfKwdCod ------------------------------------------
body = re.search(r"enum\s+GmfKwdCod\s*\{(.*?)\}", header, re.S).group(1)
body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
body = re.sub(r"//[^\n]*", "", body)
names = [t.strip() for t in body.split(",") if t.strip()]
kwds = [n for n in names if not n.startswith("GmfReserved") and n != "GmfLastKeyword"]

# --- drapeaux de reference (F77RefFlg) -----------------------------------
flg = re.search(r"F77RefFlg\[[^\]]*\]\s*=\s*\{(.*?)\}", csrc, re.S).group(1)
flags = [int(x) for x in re.findall(r"\d+", flg)]

with open(os.path.join(GEN, "_keywords.pxi"), "w") as f:
    f.write("# genere par setup.py\ncdef extern from \"libmeshb8.h\":\n")
    for n in kwds:
        f.write("    enum: %s\n" % n)
    f.write("\nKEYWORDS = {\n")
    for n in kwds:
        f.write("    %r: %s,\n" % (n[3:], n))
    f.write("}\n_F77_REF = %r\n" % (flags,))

# --- libmeshb8.c avec tampons de pipeline reduits ------------------------
# PipBufSiz = 10 000 000 lignes fait echouer GmfGetBlock/SetBlock sur les
# lignes larges (solutions d'ordre eleve) : malloc de 2*PipBufSiz*LinSiz.
patched = os.path.join(GEN, "libmeshb8_patched.c")
with open(patched, "w") as f:
    f.write(re.sub(r"(?m)^#define PipBufSiz .*$", "#define PipBufSiz 32768L", csrc))

pyx = os.path.join(GEN, "_meshb.pyx")
shutil.copy(os.path.join(HERE, "pymeshb", "_meshb.pyx"), pyx)

ext = Extension(
    "pymeshb._meshb",
    sources=[pyx, patched],
    include_dirs=[SRC, GEN, numpy.get_include()],
    define_macros=[("TRANSMESH", None)],
    extra_compile_args=["-O2"],
)

setup(
    name="pymeshb",
    version="0.1.0",
    description="Interface Python (Cython) pour libMeshb 8 (formats Inria .mesh/.meshb/.sol/.solb)",
    packages=["pymeshb"],
    ext_modules=cythonize([ext], language_level=3, build_dir=os.path.join(BUILD, "cython")),
    install_requires=["numpy"],
)
