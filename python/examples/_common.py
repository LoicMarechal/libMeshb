"""Chemins communs aux exemples ; permet de lancer les exemples sans installer pymeshb."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SAMPLES = os.path.join(HERE, "..", "..", "sample_meshes")
try:
    import pymeshb  # noqa: F401
except ImportError:
    sys.path.insert(0, os.path.join(HERE, ".."))
