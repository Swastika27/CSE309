#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include<string>
#include<fstream>
#include<vector>

#include "2005027ScopeTable.h"


class SymbolTable {
private:
    ScopeTable** array;
    ScopeTable* currentScopeTable;
    int size;
    int elementNum;
    int scopeTableSize;

    int currentScopeTableId;

    void reallocate(int newSize);
public:
    SymbolTable(int scopeTableSize);
    ~SymbolTable();
    void enterScope();
    void exitScope();
    bool insert(string name, string type);
    bool insert(SymbolInfo * symbol);
    bool remove(string name);
    SymbolInfo* lookup(string name);
    void printCurrentScopeTable();
    void printAllScopeTable();
    void insertScopeTable(ScopeTable * scopeTable);
};

#endif