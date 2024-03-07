#include "2005027SymbolTable.h"

void SymbolTable :: reallocate(int newSize) {
    ScopeTable** newArray = new ScopeTable*[newSize];
    for(int i = 0; i < newSize; i++) {
        newArray[i] = new ScopeTable;
    }
    for(int i = 0; i < size; i++) {
        newArray[i] = array[i];
    }
    // std::cout << "\n deleting " << array << "\n";
    delete[] array;
    array = newArray;

    size = newSize;
}

SymbolTable :: SymbolTable(int scopeTableSize) {
    size = 8;
    elementNum = 0;
    array = new ScopeTable*[size];
    for(int i = 0; i < size; i++) {
        array[i] = new ScopeTable;
        array[i] = nullptr;
    }
    this->scopeTableSize = scopeTableSize;
    this->currentScopeTableId = 1;

    array[0] = new ScopeTable("1", nullptr, scopeTableSize);
    currentScopeTable = array[0];
    elementNum = 1;
}

SymbolTable :: ~SymbolTable() {

    for(int i = size - 1; i > -1; i-- ) {
        // logout << "\ndeleting in symbol table " << i << " " << array[i] ;
        delete array[i];
    }
    // logout << "\n deleting " << array << "\n";
    delete[] array;
}

void SymbolTable :: enterScope() {
    // logout << "entered new scope\n";
    // cout << "size " << size << "\n";
    if(size == elementNum) {
        // cout << "\nsize " << size << "\n";
        reallocate(2 * size);
    }
    // string id = currentScopeTable->getID() + "." + to_string(currentScopeTable->getTotalDeletedChild() + 1);
    // std::cout << "new id " << id << "\n";
    currentScopeTableId = currentScopeTableId + 1;
    string id = to_string(currentScopeTableId);
    array[elementNum++] = new ScopeTable(id, currentScopeTable, scopeTableSize);
    currentScopeTable = array[elementNum - 1];
}

void SymbolTable :: insertScopeTable(ScopeTable * scopeTable) {
    // logout << "inserted new scope table\n";
    if(size == elementNum) {
        // cout << "\nsize " << size << "\n";
        reallocate(2 * size);
    }
    currentScopeTableId = currentScopeTableId + 1;
    string id = to_string(currentScopeTableId);
    array[elementNum++] = scopeTable;
    scopeTable->setId(id);
    scopeTable->setParentScope(currentScopeTable);
    currentScopeTable = scopeTable;
}

void SymbolTable :: exitScope() {
    if(elementNum <= 1) {
        // logout << "\tScopeTable# 1 cannot be deleted\n"; 
    }
    else {
        ScopeTable * temp = array[elementNum - 1];
        currentScopeTable = array[elementNum - 2];
        elementNum--;
        // logout << "\ndeleting " << temp << "\n";
        delete temp;
        array[elementNum] = nullptr;
        // logout << "entry now " << array[elementNum] << "\n";
        currentScopeTable->setTotalDeletedChild(currentScopeTable->getTotalDeletedChild() + 1);
    }
}

bool SymbolTable :: insert(string name, string type) {
    return currentScopeTable->insert(new SymbolInfo(name, type, nullptr));
}

bool SymbolTable :: insert(SymbolInfo * symbol) {
    return currentScopeTable->insert(symbol);
}

bool SymbolTable :: remove(string name) {
    return currentScopeTable->deleteSymbol(name);
}

SymbolInfo* SymbolTable :: lookup(string name) {
    ScopeTable * temp = currentScopeTable;
    while(temp != nullptr) {
        SymbolInfo* result = temp->lookup(name);
        if(result != nullptr) {
            return result;
        }
        temp = temp->getParentScope();
    }
    return nullptr;
}

void SymbolTable :: printCurrentScopeTable() {
    // cout << "#" << currentScopeTable->getID() << "\n";
    currentScopeTable->print();
}

void SymbolTable :: printAllScopeTable() {
    ScopeTable* temp = currentScopeTable;
    while(temp != nullptr) {
        // logout << "#" << temp->getID() << "\n";
        temp->print();

        temp = temp->getParentScope();
    }
}