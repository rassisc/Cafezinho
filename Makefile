cafezinho: sintatico.o lexico.o
	g++ -std=c++11 sintatico.o lexico.o -o cafezinho
sintatico.o: sintatico.cpp
	g++ -std=c++11 -c sintatico.cpp -osintatico.o
sintatico.cpp: cafezinho.y
	bison -d -osintatico.cpp cafezinho.y
lexico.o: lexico.cpp
	g++ -std=c++11 -c lexico.cpp -olexico.o
lexico.cpp: cafezinho.l
	flex -olexico.cpp cafezinho.l
clean:
	rm *.o cafezinho *.cpp
