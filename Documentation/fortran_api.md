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

### gmfgetlinef77(lib, kwd, IntTab, RealTab, Ref)

Reads a full line of a giver keyword's data.
Right now, the default data kinds are integer*4 and real*8.

Integer fields are stored in IntTab(), floating point values are stored in DblTab() and if the keyword includes a reference (GmfVertices and all elements), it is stored in Ref.

Note that even though some keywords don't need all the parameters, you need to provide them all to the function call, use dummy parameters if needed.

### gmfsetlinef77(lib, kwd, IntTab, RealTab, Ref)

Writes a full line of a giver keyword's data.
Right now, the default data kinds are integer*4 and real*8.

Integer fields are stored in IntTab(), floating point values are stored in DblTab() and if the keyword includes a reference (GmfVertices and all elements), it is stored in Ref.

Note that even though some keywords don't need all the parameters, you need to provide them all to the function call, use dummy parameters if needed.


### gmfget blockf77(lib, kwd, BegIdx, EndIdx, MapTyp, MapTab, BegInt, EndInt, BegReal, EndReal, BegRef, EndRef)

Reads multiple data lines in a row.

You need to provide tables big enough to store all the data in one huge memory area.

BegIdx and EndIdx are the first and last line number to be read (1 .. NbElements reads the whole mesh).

BegInt points to the first entity integer's data.

EndInt points to the last entity integer's data.

BegReal points to the first entity REAL*8's data.

EndReal points to the last entity REAL*8's data.

BegRef points to the first entity's reference

EndRef points to the last entity's reference

Like with gmgetlinef77(), some arguments may be useless depending on the keyword but you need to provide some dummy argument instead.


### gmfset blockf77(lib, kwd, BegIdx, EndIdx, MapTyp, MapTab, BegInt, EndInt, BegReal, EndReal, BegRef, EndRef)

Writes multiple data lines in a row.

You need to provide tables big enough to store all the data in one huge memory area.

BegIdx and EndIdx are the first and last line number to be read (1 .. NbElements reads the whole mesh).

BegInt points to the first entity integer's data.

EndInt points to the last entity integer's data.

BegReal points to the first entity REAL*8's data.

EndReal points to the last entity REAL*8's data.

BegRef points to the first entity's reference

EndRef points to the last entity's reference

Like with gmsetlinef77(), some arguments may be useless depending on the keyword but you need to provide some dummy argument instead.
