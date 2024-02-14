## GENERAL COMMENTS

Default datatypes throughout the API are 4-byte integers and 8-byte reals except for the library's index, which is an 8-byte integer.

All procedures' arguments are fixed and no more variable arguments are used.

The API is provided to access vertices and some elements. Adding new elements if straightforward but other arbitrary keywords need a dedicated API.

See corresponding C procedures in the main documentation for further information about what these procedures are doing. This readme file is only intended for argument’s description.


## GENERAL PURPOSE PROCEDURES

### gmfopenmeshf77( "filename", mode, version, dimension)

Calls C GmfOpenMesh() with the same arguments.

### gmfclosemeshf77(lib)

Calls C GmfCloseMesh() with the same arguments.


### gmfgotokwdf77(lib, kwd)

Calls C GmfGotoKwd() with the same arguments.

### gmfstatkwdf77(lib, kwd, NmbTyp, SolSiz, TypTab, HOdeg, HOsiz)

Calls C GmfStatKwd with the right arguments depending on whether the keyword is regular, HO or a solution.

From Fortran you need to provide all arguments even if they are not needed.

### gmfsetkwdf77(lib, kwd, NmbTyp, SolSiz, TypTab, HOdeg, HOsiz)

Calls C GmfSetKwd with the right arguments depending on whether the keyword is regular, HO or a solution.

From Fortran you need to provide all arguments even if they are not needed.

### gmfsethonodesorderingf77(lib, kwd, source-ordering, destination-ordering)

Calls C GmfSetHONodesOrdering() with the same arguments.

## VERTICES

Vertices data is split in two fields: a pointer to consecutive REAL8 to store coordinates and a pointer on an INT4 that stores the reference.


### gmfgetvertex(lib, coordinates, ref)

Reads a single vertex.
Calls C GmfGetLin() with keyword GmfVertices, a pointer on a vector of 2 or 3 consecutive REAL8 and a pointer on an integer ref.

### gmfsetvertex(lib, coordinates, ref)

Writes a single vertex.
Calls C GmfSetLin() with keyword GmfVertices, a pointer on a vector of 2 or 3 consecutive REAL8 and the value of the integer ref.

### gmfgetvertices(lib, start-index, end-index, map-type, map, start-coordinates, end-coordinate, start-ref, end-ref)

Reads a block of vertices.
Calls C GmfGetBlock with GmfVertices and pointers to the first vertex coordinates, last vertex coordinates, first vertex reference and last vertex reference.

### gmfsetvertices(lib, start-index, end-index, map-type, map, start-coordinates, end-coordinate, start-ref, end-ref)

Writes a block of vertices.
Calls C GmfSetBlock with GmfVertices and pointers to the first vertex coordinates, last vertex coordinates, first vertex reference and last vertex reference.


## ELEMENTS

Elements data is split in two fields: a pointer to consecutive INT4 to store nodes indices and a pointer on an INT4 that stores the reference.

### gmfgetelement(lib, element-kind, nodes, ref)

Reads a single element.
Calls C GmfGetLin() with the provided element keyword, a pointer on a vector of several consecutive INT4 to store nodes indices and a pointer on an integer ref.

### gmfsetelement(lib, element-kind, nodes, ref)

Writes a single element.
Calls C GmfSetLin() with the provided element keyword, a pointer on a vector of several consecutive INT4 to store nodes indices and a pointer on an integer ref.

### gmfgetelements(lib, element-kind, start-index, end-index, map-type, map, start-nodes, end-nodes, start-ref, end-ref)

Reads a block of elements.
Calls C GmfGetBlock() with the provided element keyword, a pointer on the first element's nodes, a pointer on the last element's nodes, a pointer on the first element's reference and a pointer on the last element's reference.

### gmfsetelements(lib, element-kind, start-index, end-index, map-type, map, start-nodes, end-nodes, start-ref, end-ref)

Writes a block of elements.
Calls C GmfSetBlock() with the provided element keyword, a pointer on the first element's nodes, a pointer on the last element's nodes, a pointer on the first element's reference and a pointer on the last element's reference.
