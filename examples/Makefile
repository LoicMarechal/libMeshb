CC = gcc
FC = gfortran
INCDIR = ../sources
CFLAGS = -O -I $(INCDIR) -Wuninitialized -Wunused -Wall
FFLAGS = -O -I $(INCDIR) -fimplicit-none
LDFLAGS = -lm

examples: test_libmeshb test_libmeshb_f77 test_libmeshb_sol test_libmeshb_block_f77 test_libmeshb_block 

test_libmeshb_sol: test_libmeshb_sol.c libmeshb7.c libmeshb7.h
	$(CC) $(CFLAGS) test_libmeshb_sol.c libmeshb7.c $(LDFLAGS) -o $@

test_libmeshb: test_libmeshb.c libmeshb7.c libmeshb7.h
	$(CC) $(CFLAGS) test_libmeshb.c libmeshb7.c $(LDFLAGS) -o $@

test_libmeshb_block: test_libmeshb_block.c libmeshb7.c libmeshb7.h
	$(CC) $(CFLAGS) test_libmeshb_block.c libmeshb7.c $(LDFLAGS) -o $@

test_libmeshb_f77: test_libmeshb.f libmeshb7.c libmeshb7.h libmeshb7.ins
	$(CC) $(CFLAGS) -c libmeshb7.c -DF77API
	$(FC) $(CFLAGS) -fimplicit-none -c test_libmeshb.f
	$(FC) test_libmeshb.o libmeshb7.o $(LDFLAGS) -o $@
	rm test_libmeshb.o

test_libmeshb_block_f77: test_libmeshb_block.f libmeshb7.c libmeshb7.h libmeshb7.ins
	$(CC) $(CFLAGS) -c libmeshb7.c -DF77API
	$(FC) $(FFLAGS) -fimplicit-none -c test_libmeshb_block.f
	$(FC) $(FFLAGS) test_libmeshb_block.o libmeshb7.o $(LDFLAGS) -o $@
	rm test_libmeshb_block.o

test_libmeshb_block_pipeline_f77: test_libmeshb_block_pipeline.f libmeshb7.c libmeshb7.h libmeshb7.ins
	$(CC) $(CFLAGS) -c libmeshb7.c -DF77API
	$(FC) $(FFLAGS)  -c test_libmeshb_block_pipeline.f
	$(FC) $(FFLAGS) test_libmeshb_block_pipeline.o libmeshb7.o $(LDFLAGS) -o $@

clean:
	rm *.o test_libmeshb test_libmeshb_f77 test_libmeshb_sol test_libmeshb_block_f77 test_libmeshb_block 
