#include "2005027SymbolInfo.h"

SymbolInfo :: SymbolInfo (string name, string type) {
    this-> name = name;
    this-> type = type;
    this-> next = nullptr;

    isArray = false;
    isFunctionDeclaration = false;
    isFunctionDefinition = false;
    isZero = false;

    tabsNeeded = 0;

    // cout << "allocating symbol " << this << "\n";
}
SymbolInfo :: SymbolInfo(string name, string type, int startline) {
    this-> name = name;
    this-> type = type;
    this-> next = nullptr;

    this-> startline = startline;
    this-> endline = startline;
    
    isArray = false;
    isFunctionDeclaration = false;
    isFunctionDefinition = false;
    isZero = false;

    tabsNeeded = 0;
    // cout << "allocating symbol " << this << "\n";
}
SymbolInfo :: SymbolInfo(string name, string type, int startline, int endline) {
    this-> name = name;
    this-> type = type;
    this-> next = nullptr;

    this-> startline = startline;
    this-> endline = endline;
    
    isArray = false;
    isFunctionDeclaration = false;
    isFunctionDefinition = false;
    isZero = false;

    tabsNeeded = 0;
    // cout << "allocating symbol " << this << "\n";
}
SymbolInfo :: SymbolInfo(string name, string type, SymbolInfo* nextptr) {
    this-> name = name;
    this-> type = type;
    this-> next = nextptr;
    
    isArray = false;
    isFunctionDeclaration = false;
    isFunctionDefinition = false;
    isZero = false;

    tabsNeeded = 0;
    // cout << "allocating symbol " << this << "\n";
}
SymbolInfo :: ~SymbolInfo() {
    cout << "deleting symbol " << type << " " << this << " " << getStartLine() << "\n";
    // std :: cout << "\ndeleting next pointer " << next << "\n";
    // delete next;
}
string SymbolInfo :: getName() {
    return name;
}
void SymbolInfo :: setType(string type) {
    this->type = type;
}
string SymbolInfo :: getType() {
    return type;
}
SymbolInfo* SymbolInfo :: getNext() {
    return next;
}
void SymbolInfo :: setNext(SymbolInfo* ptr) {
    next = ptr;
}
int SymbolInfo:: getStartLine() {
    return this->startline;
}
int SymbolInfo :: getEndLine() {
    return endline;
}
string SymbolInfo :: getDataType() {
    return data_type;
}
void SymbolInfo :: setDataType(string d_type) {
    data_type = d_type;
}
void SymbolInfo :: setArray(bool b) {
    isArray = b;
}
bool SymbolInfo :: getArray() {
    return isArray;
} 
void SymbolInfo :: addParam(string param) {
    parameter_list.push_back(param);
}
vector<string> SymbolInfo :: getParameterList() {
    return parameter_list;
}
void SymbolInfo :: setTabsNeeded(int n) {
    tabsNeeded = n;
}
int SymbolInfo :: getTabsNeeded() {
    return tabsNeeded;
}
void SymbolInfo :: setIsFunctionDeclaration(bool b) {
    isFunctionDeclaration = b;
}
bool SymbolInfo :: getIsFunctionDeclaration() {
    return isFunctionDeclaration;
}
bool SymbolInfo :: getIsFunctionDefinition() {
    return isFunctionDefinition;
}
void SymbolInfo :: setIsFunctionDefinition(bool b) {
    isFunctionDefinition = b;
}
void SymbolInfo :: setIsZero(bool b) {
    isZero = b;
} 
bool SymbolInfo :: getIsZero() {
    return isZero;
} 