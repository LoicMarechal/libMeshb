

#-----------------------------------------------------------#
#															#
#					libMeshb utilities						#
#															#
#-----------------------------------------------------------#
#															#
#	Description:		makefile libMeshb's utilities      	#
#	Author:				Loic MARECHAL						#
#	Creation date:		dec 02 1999							#
#	Last modification:	jun 08 2016							#
#															#
#-----------------------------------------------------------#


# Compiler and flags
CC      = gcc
CFLAGS  = -O3 -DTRANSMESH
LDFLAGS = -lm

# Exe directories
EXEDIR  = $(HOME)/bin/$(ARCHI)

# Build hilbert
$(EXEDIR)/transmesh: transmesh.c libmeshb7.c libmeshb7.h
	$(CC) transmesh.c libmeshb7.c $(CFLAGS) $(LDFLAGS) -o $@
