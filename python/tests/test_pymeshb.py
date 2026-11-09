"""Tests de pymeshb : python -m unittest discover tests"""
import os
import tempfile
import unittest

import numpy as np

import pymeshb as pm

SAMPLES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "sample_meshes")


class RoundTrip(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        with pm.Mesh(os.path.join(SAMPLES, "quad.mesh")) as m:
            self.x, self.r = m.read_vertices()
            self.q, self.qr = m.read_elements(pm.Quadrilaterals)

    def tearDown(self):
        self.tmp.cleanup()

    def test_mesh_all_versions(self):
        for ver in (1, 2, 3, 4):
            for ext in (".mesh", ".meshb"):
                fn = os.path.join(self.tmp.name, "m%d%s" % (ver, ext))
                with pm.Mesh(fn, "w", ver, 3) as w:
                    w.write_vertices(self.x, self.r)
                    w.write_elements(pm.Quadrilaterals, self.q, self.qr)
                with pm.Mesh(fn) as rd:
                    self.assertEqual((rd.version, rd.dim), (ver, 3))
                    x, r = rd.read_vertices()
                    q, qr = rd.read_elements(pm.Quadrilaterals)
                np.testing.assert_allclose(x, self.x, atol=1e-5 if ver == 1 else 1e-12)
                np.testing.assert_array_equal(q, self.q)
                np.testing.assert_array_equal(qr, self.qr)

    def test_partial_block_and_zero_based(self):
        with pm.Mesh(os.path.join(SAMPLES, "quad.mesh")) as m:
            q, _ = m.read_elements(pm.Quadrilaterals, 10, 19, zero_based=True)
        np.testing.assert_array_equal(q, self.q[9:19] - 1)

    def test_line_access_matches_block(self):
        with pm.Mesh(os.path.join(SAMPLES, "quad.mesh")) as m:
            m.goto(pm.Vertices)
            v, ref = m.get_line(pm.Vertices)
        np.testing.assert_array_equal(v, self.x[0])
        self.assertEqual(ref, self.r[0])

    def test_solution(self):
        d = np.random.rand(len(self.x), 5)
        for ext in (".sol", ".solb"):
            fn = os.path.join(self.tmp.name, "s" + ext)
            with pm.Mesh(fn, "w", 2, 3) as w:
                w.write_solution(pm.SolAtVertices, d, [pm.SCA, pm.VEC, pm.SCA],
                                 names=["a", "b", "c"], iteration=3, time=2.5)
            with pm.Mesh(fn) as rd:
                s = rd.read_solution(pm.SolAtVertices)
                self.assertEqual((rd.iteration, rd.time), (3, 2.5))
            self.assertEqual(s.names, ["a", "b", "c"])
            self.assertEqual(s.types, [pm.SCA, pm.VEC, pm.SCA])
            np.testing.assert_allclose(s.data, d, atol=1e-12)

    def test_ho_solution(self):
        n, nn, w = 7, 6, 5
        d = np.random.rand(n, nn, w)
        pos = np.random.rand(nn, 3)
        fn = os.path.join(self.tmp.name, "ho.solb")
        with pm.Mesh(fn, "w", 2, 3) as o:
            o.write_table(pm.HOSolAtTrianglesP2NodesPositions, pos)
            o.write_solution(pm.HOSolAtTrianglesP2, d, [pm.SCA, pm.VEC, pm.SCA],
                             degree=2, nnodes=nn)
        with pm.Mesh(fn) as rd:
            s = rd.read_solution(pm.HOSolAtTrianglesP2)
        self.assertEqual((s.degree, s.nnodes), (2, nn))
        np.testing.assert_allclose(s.data, d, atol=1e-12)
        np.testing.assert_allclose(s.positions, pos, atol=1e-12)

    def test_errors(self):
        with self.assertRaises(OSError):
            pm.Mesh("/nonexistent/x.mesh")
        m = pm.Mesh(os.path.join(SAMPLES, "quad.mesh"))
        m.close()
        with self.assertRaises(ValueError):
            m.read_vertices()


if __name__ == "__main__":
    unittest.main()
