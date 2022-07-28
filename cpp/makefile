# tool: tool.o support.o
#     g++ -g -o tool tool.o support.o -L/sw/lib/root -lCore -lCint -lRIO -lNet -lHist -lGraf -lGraf3d -lGpad -lTree -lRint \
#         -lPostscript -lMatrix -lPhysics -lMathCore -lThread -lz -L/sw/lib -lfreetype -lz -Wl,-framework,CoreServices \
#         -Wl,-framework,ApplicationServices -pthread -Wl,-rpath,/sw/lib/root -lm -ldl


targets := $(wildcard output/*.o)


all: main



output/main.o: src/main.cpp
	g++ -g -c src/main.cpp -o output/main.o

main: $(targets)
	g++ -o main $(targets) 
