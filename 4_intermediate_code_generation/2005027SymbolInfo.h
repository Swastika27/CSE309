#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

#include<iostream>
#include<string>
#include<fstream>
#include<vector>
using namespace std;

extern ofstream logout;

class SymbolInfo {
private: 
    string name;
    string type;
    SymbolInfo* next;
    int startline;
    int endline;
    string data_type;

    bool isArray;
    bool isFunctionDeclaration;
    bool isFunctionDefinition;
    bool isZero;
    vector<string> parameter_list;

    int tabsNeeded;
    int stackOffset;
    int length;
public:
    SymbolInfo() { next = nullptr; }
    SymbolInfo(string name, string type);
    SymbolInfo(string name, string type, int startline);
    SymbolInfo(string name, string type, int startline, int endline);
    SymbolInfo(string name, string type, SymbolInfo* nextptr);
    ~SymbolInfo();
    string getName();
    void setType(string type);
    string getType();
    SymbolInfo* getNext();
    void setNext(SymbolInfo* ptr);
    int getStartLine();
    int getEndLine();
    string getDataType();
    void setDataType(string d_type);
    void setArray(bool b);
    bool getArray();
    void addParam(string param);
    vector<string> getParameterList();
    void setTabsNeeded(int n);
    int getTabsNeeded();
    void setIsFunctionDeclaration(bool b);
    bool getIsFunctionDeclaration();
    bool getIsFunctionDefinition();
    void setIsFunctionDefinition(bool b);
    void setIsZero(bool b);
    bool getIsZero();
    void setOffset(int n);
    int getOffset();
    void setLength(int n);
    int getLength();
};

#endif