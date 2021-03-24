## HIGH PRIORITY

### Handle arbitrary degree high-order elements
- Setup a keyword to store Pk elements.
- Give along a routine to convert to and from well-known high-order numberings.

### Distributed parallel write
- Open a mesh file in write mode but only create the skeleton of the mesh structure to eneable further concurent write access.
- Open an existing mesh file in write mode and enable concurent block write thanks to the existing structure.

## STANDARD PRIORITY

### Handle arbitrary degree polygons and polyhedra
- Setup a polygon keyword thats provides an arbitrary degree and number of nodes.
- Setup a polyhedra keyword thats provides an arbitrary degree and number of oriented polygons.
- Setup a boundary polygons keyword that lists the boundary faces among the enemble of volume polygons.
- Create a separate helpers file to be optionaly compiled along the libMeshb.
- Add a helper to allocate and read the boundary polygons.
- Add a helper to allocate and read the polyhedra and inner polygons.
- Add a helper that returns a polygon's degree and nodes list.
- Add a helper that returns a polyhedron's degree and face indices list.
- Add a helper that tesselate a polygon int a list of triangles made of vertex nodes and edge visibility flags.
- Add a helper that cuts a polyhedron through a plane and generates the intersetion's triangulated mesh in a STL-like format.


### Solution fields comments
- Add a procedure that would search for a string among comments.
- Input:  keyword name, physical property, free comment, wildcards.
- Output: list of solutions keywords and particuliar field number.

### Arbitrary reference element
- Add a set of keywords for each kind of elements that stores the number of vertices and their barycentric coordinates.

### Convert HO examples to Fortran
- test_libmeshb_HO.c
- test_libmeshb_p2_sol.c

### Add F77 API to GmfSetHONodesOrdering
An easy one.

### Add IHOSol* + DHOSol* for each element kinds
for example :
"IHOSolAtVertices",                           "i", "ii" // ii = degree + index in DSol
"DHOSolAtVertices",                           "i", "hr" // High Order solution

## DONE

- Indirect storage through a renumbering table for parallel reading.
- Keyword documentation updated.
- High-Order multiple solutions per element for DG.
- Added ByteFlow keyword to store an arbitrary sized byte array
- Added two examples to read and write EGADS CAD models stores as byte flows
- Give a way to describe the node numbering.
