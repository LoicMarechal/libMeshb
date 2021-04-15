## Release 7.60

1. Arbitrary polyhedra and polygons storage is now possible with these six new keywords:
  - GmfBoundaryPolygonHeaders: stores the number and the list nodes of each boundary polygon
  - GmfBoundaryPolygonVertices: stores the concatenated list of boundary polygons' nodes
  - GmfInnerPolygonHeaders: stores the number and the list nodes of each inner polygon (polyhedra's faces)
  - GmfInnerPolygonVertices: stores the concatenated list of inner polygons' nodes
  - GmfPolyhedraHeaders: stores the number and the list of faces of each polyhedron
  - GmfPolyhedraFaces: stores the concatenated list of polyhedra's faces

2. New helpers functions system to easily add specific features related to the libMeshb:
  - See the helper's [readme](utilities/libmeshb7_helpers.md) for more information about the new functions to handle polyhedral meshes.
