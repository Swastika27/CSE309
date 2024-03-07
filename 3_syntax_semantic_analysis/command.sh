#! /bin/sh
rm y.tab.cpp parser y.o log.txt lex.yy.cpp l.o error.txt parsetree.txt
yacc -d -y 2005027.y
cp y.tab.c y.tab.cpp && rm y.tab.c
g++ -g -w -c -o y.o y.tab.cpp
flex -o lex.yy.cpp 2005027.l
g++ -g -w -c -o l.o lex.yy.cpp
g++ -g 2005027SymbolInfo.cpp 2005027ScopeTable.cpp 2005027SymbolTable.cpp -c
g++ -g 2005027SymbolInfo.o 2005027ScopeTable.o 2005027SymbolTable.o y.o l.o -lfl -o parser
./parser $1
