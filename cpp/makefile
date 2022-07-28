targets := output/main.o

all: main

output/main.o: src/main.cpp
	g++ -g -c src/main.cpp -o output/main.o

main: $(targets)
	g++ -o main $(targets)
