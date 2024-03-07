#! /bin/sh
rm y.tab.cpp parser y.o log.txt lex.yy.cpp l.o error.txt parsetree.txt code.asm
echo "deleted previous files"
yacc -d -y 2005027.y
echo "yacc"
cp y.tab.c y.tab.cpp && rm y.tab.c
echo "cp"
g++ -g -w -c -o y.o y.tab.cpp
echo "g++"
flex -o lex.yy.cpp 2005027.l
echo "flex"
g++ -g -w -c -o l.o lex.yy.cpp
echo "g++"
g++ -g 2005027SymbolInfo.cpp 2005027ScopeTable.cpp 2005027SymbolTable.cpp -c
echo "g++"
g++ -g 2005027SymbolInfo.o 2005027ScopeTable.o 2005027SymbolTable.o y.o l.o -lfl -o parser
echo "g++"
./parser $1
