CC = /usr/local/bin/gcc
FC = /usr/local/bin/gfortran
INCDIR = ../sources

examples: test_libmeshb test_libmeshb_f77 test_libmeshb_sol test_libmeshb_block_f77 test_libmeshb_block test_libmeshb_block_f77

test_libmeshb_sol: test_libmeshb_sol.c libmeshb7.c libmeshb7.h
	$(CC) -O -I $(INCDIR) test_libmeshb_sol.c libmeshb7.c -lm -o $@

test_libmeshb: test_libmeshb.c libmeshb7.c libmeshb7.h
	$(CC) -O -I $(INCDIR) test_libmeshb.c libmeshb7.c -lm -o $@

test_libmeshb_block: test_libmeshb_block.c libmeshb7.c libmeshb7.h
	$(CC) -O -I $(INCDIR) test_libmeshb_block.c libmeshb7.c -lm -o $@

test_libmeshb_f77: test_libmeshb.f libmeshb7.c libmeshb7.h libmeshb7.ins
	$(CC) -O -I $(INCDIR) -c libmeshb7.c -DF77API
	$(FC) -O -I $(INCDIR) -fimplicit-none -c test_libmeshb.f
	$(FC) test_libmeshb.o libmeshb7.o -lm -o $@
	rm test_libmeshb.o

test_libmeshb_block_f77: test_libmeshb_block.f libmeshb7.c libmeshb7.h libmeshb7.ins
	$(CC) -O -I $(INCDIR) -c libmeshb7.c -DF77API
	$(FC) -O -I $(INCDIR) -fimplicit-none -c test_libmeshb_block.f
	$(FC) test_libmeshb_block.o libmeshb7.o -lm -o $@
	rm test_libmeshb_block.o

test_libmeshb_block_pipeline_f77: test_libmeshb_block_pipeline.f libmeshb7.c libmeshb7.h libmeshb7.ins
	$(CC) -O -I $(INCDIR) -c libmeshb7.c -DF77API
	$(FC) -O -I $(INCDIR) -fimplicit-none -c test_libmeshb_block.f
	$(FC) test_libmeshb_block_pipeline.o libmeshb7.o -lm -o $@

clean:
	rm *.o test_libmeshb test_libmeshb_f77 test_libmeshb_sol test_libmeshb_block_f77 test_libmeshb_block test_libmeshb_block_f77
