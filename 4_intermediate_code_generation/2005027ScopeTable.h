#ifndef SCOPETABLE_H
#define SCOPETABLE_H

#include<string>
#include "2005027SymbolInfo.h"

using namespace std;

extern ofstream logout;

class ScopeTable {
private:
    string id;
    ScopeTable* parentScope;
    int total_buckets;
    SymbolInfo** array;
    int totalDeletedChild;

    static unsigned long long sdbm(const char* str);
public:
    ScopeTable();
    ScopeTable(int n);
    ScopeTable(string id, ScopeTable* parent, int n);
    ~ScopeTable();
    void setId(string s);
    string getID();
    ScopeTable* getParentScope();
    void setParentScope(ScopeTable* parent);
    int getTotalDeletedChild();
    void setTotalDeletedChild(int n);
    bool insert(SymbolInfo* info);
    SymbolInfo* lookup(string name);
    bool deleteSymbol(string name);
    void print();
};

#endif