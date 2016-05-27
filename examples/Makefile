CC = /usr/local/bin/gcc
FC = /usr/local/bin/gfortran

examples: test_libmesh7 test_libmesh7_f77 test_sol test_libmesh7_block_f77

test_sol: test_sol.c libmesh7.c libmesh7.h
	$(CC) -O test_sol.c libmesh7.c -lm -o $@

test_libmesh7: test_libmesh7.c libmesh7.c libmesh7.h
	$(CC) -O test_libmesh7.c libmesh7.c -lm -o $@

test_libmesh7_f77: test_libmesh7.f libmesh7.c libmesh7.h libmesh7.ins
	$(CC) -O -c libmesh7.c -DF77API
	$(FC) -O -fimplicit-none -c test_libmesh7.f
	$(FC) test_libmesh7.o libmesh7.o -lm -o $@
	rm test_libmesh7.o libmesh7.o

test_libmesh7_block_f77: test_libmesh7_block.f libmesh7.c libmesh7.h libmesh7.ins
	$(CC) -O -c libmesh7.c -DF77API
	$(FC) -O -fimplicit-none -c test_libmesh7_block.f
	$(FC) test_libmesh7_block.o libmesh7.o -lm -o $@
	rm test_libmesh7_block.o libmesh7.o

clean:
	rm *.o test_libmesh7 test_libmesh7_f77 test_sol test_libmesh7_block_f77
