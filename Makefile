CC = g++

CFLAGS	= -O2 -I. -Iinclude

.SUFFIXES: .C .cpp

OBJECTS	= lib/PQP.o \
          lib/BV.o \
          lib/Build.o \
          lib/TriDist.o

CLEAN	= $(OBJECTS) lib/libPQP.a include/*.h

library: $(OBJECTS)
	/bin/rm -f lib/libPQP.a
	ar ruv lib/libPQP.a $(OBJECTS)
	cp src/PQP.h include/
	cp src/PQP_Compile.h include/
	cp src/PQP_Internal.h include/
	cp src/BV.h include/
	cp src/Tri.h include/

include/PQP_Export.h:
	echo "#ifndef PQP_EXPORT_H\n#define PQP_EXPORT_H\n\n#define PQP_EXPORT\n\n#endif" > include/PQP_Export.h

lib/BV.o: src/BV.cpp
	$(CC) $(CFLAGS) -c src/BV.cpp -o lib/BV.o
lib/PQP.o: src/PQP.cpp include/PQP_Export.h
	$(CC) $(CFLAGS) -c src/PQP.cpp -o lib/PQP.o
lib/Build.o: src/Build.cpp include/PQP_Export.h
	$(CC) $(CFLAGS) -c src/Build.cpp -o lib/Build.o
lib/TriDist.o: src/TriDist.cpp
	$(CC) $(CFLAGS) -c src/TriDist.cpp -o lib/TriDist.o

clean:
	/bin/rm -f $(CLEAN)
