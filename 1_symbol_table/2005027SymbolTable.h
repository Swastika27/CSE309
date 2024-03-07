#ifndef SCOPETABLE_H
#define SCOPETABLE_H

#include<string>
#include<fstream>
using namespace std;

ofstream outputFile("output.txt");

class SymbolInfo {
private: 
    string name;
    string type;
    SymbolInfo* next;
public:
    SymbolInfo() { next = nullptr; }
    SymbolInfo(string name, string type);
    SymbolInfo(string name, string type, SymbolInfo* nextptr);
    ~SymbolInfo();
    string getName();
    string getType();
    SymbolInfo* getNext();
    void setNext(SymbolInfo* ptr);
};


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
    string getID();
    ScopeTable* getParentScope();
    int getTotalDeletedChild();
    void setTotalDeletedChild(int n);
    bool insert(SymbolInfo* info);
    SymbolInfo* lookup(string name);
    bool deleteSymbol(string name);
    void print();
};

class SymbolTable {
private:
    ScopeTable** array;
    ScopeTable* currentScopeTable;
    int size;
    int elementNum;
    int scopeTableSize;

    void reallocate(int newSize);
public:
    SymbolTable(int scopeTableSize);
    ~SymbolTable();
    void enterScope();
    void exitScope();
    bool insert(string name, string type);
    bool remove(string name);
    SymbolInfo* lookup(string name);
    void printCurrentScopeTable();
    void printAllScopeTable();
};

SymbolInfo :: SymbolInfo (string name, string type) {
    this-> name = name;
    this-> type = type;
    this-> next = nullptr;
}
SymbolInfo :: SymbolInfo(string name, string type, SymbolInfo* nextptr) {
    this-> name = name;
    this-> type = type;
    this-> next = nextptr;
}
SymbolInfo :: ~SymbolInfo() {
    // std :: cout << "\ndeleting next pointer " << next << "\n";
    // delete next;
}
string SymbolInfo :: getName() {
    return name;
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

unsigned long long ScopeTable :: sdbm(const char* str) {
    unsigned long long hash = 0;
    int c = 0;

    while (c = *str++)
        hash = c + (hash << 6) + (hash << 16) - hash;

    return hash;

}

ScopeTable :: ScopeTable() {

}

ScopeTable :: ScopeTable(int n) {
    this->id = "undefined";
    this->parentScope = nullptr;
    this->total_buckets = n;
    this->totalDeletedChild = 0;

    array = new SymbolInfo*[n];
    for(int i = 0; i < n; i++) {
        array[i] = new SymbolInfo;
        array[i] = nullptr;
    }

    outputFile << "\tScopeTable# " << id << " created\n";

}

ScopeTable :: ScopeTable(string id, ScopeTable* parent, int n) {
    this->id = id;
    this->parentScope = parent;
    this->total_buckets = n;
    this->totalDeletedChild = 0;

    array = new SymbolInfo*[n];
    for(int i = 0; i < n; i++) {
        array[i] = new SymbolInfo;
        array[i] = nullptr;
    }

    outputFile << "\tScopeTable# " << id << " created\n";
}

ScopeTable :: ~ScopeTable() {
    // outputFile << "\ntrying to delete scope table " << this << "\n"; 
    for (int i = 0; i < total_buckets; i++) {
        SymbolInfo* current = array[i];
        while (current != nullptr) {
            SymbolInfo* temp = current;
            current = current->getNext();
            // outputFile << "\ndeleting in scope table " << id << "\n";
            delete temp;
        }
    }
    // cout << "\n deleting array in scope table" << id << "\n";
    delete[] array;
    outputFile << "\tScopeTable# " << id << " deleted\n";
}

string ScopeTable :: getID() {
    return id;
}

ScopeTable* ScopeTable :: getParentScope() {
    return parentScope;
}

int ScopeTable :: getTotalDeletedChild() {
    return totalDeletedChild;
}

void ScopeTable :: setTotalDeletedChild(int n) {
    totalDeletedChild = n;
}

bool ScopeTable :: insert(SymbolInfo* info) {
    int index = sdbm(info->getName().c_str()) % total_buckets;
    // cout << "inside insert " << info->getName() << "\n";

    // insertAtBack() in ll
    if (array[index] == nullptr) {
        // cout << "this slot is empty\n";
        array[index] = info;
        // cout<< "\ninserted " << info->getName() << " " << info->getNext() << " at " << info << "\n";
        outputFile << "\tInserted  at position <" << (index + 1) << ", " << 1 << "> of ScopeTable# " << id << "\n"; 

        return true;
    }
    else {
        int counter = 1;

        SymbolInfo* temp = array[index];
        while(temp != nullptr) {
            // cout << "checking " << temp->getName() << " " << temp->getNext() << "\n";
            if(temp->getName() == info->getName()) {
                // cout << "this is already there\n";
                outputFile << "\t'" << info->getName() << "' already exists in the current ScopeTable# " << id << "\n";
                delete info;
                return false;
            }
            if(temp->getNext() == nullptr) {
                temp->setNext(info);
                // cout<< "\ninserted " << info->getName() << " after " << temp->getNext() << " at " << info << "\n";
                outputFile << "\tInserted  at position <" << (index + 1) << ", " << (counter + 1) << "> of ScopeTable# " << id << "\n"; 
                return true;
            }
            temp = temp->getNext();
            counter++;
        }
        
    }
    
}

SymbolInfo* ScopeTable :: lookup(string name) {
    // cout << "looking for string " << name;
    int index = sdbm(name.c_str()) % total_buckets;
    // cout << "hashed to " << index;

    SymbolInfo* temp = array[index];
    int count = 1;
    while(temp != nullptr) {
            if (temp->getName() == name) {
            // cout << "\n found it!";
            outputFile << "\t'" << name << "' found at position <" << (index + 1) << ", " << count << "> of ScopeTable# " << id << "\n";
            return temp;
        }
        temp = temp->getNext();
        count++;
    }
    
    return nullptr;
}

bool ScopeTable :: deleteSymbol(string name) {
    int index = sdbm(name.c_str()) % total_buckets;

    SymbolInfo* temp = array[index];
    SymbolInfo* prev = nullptr;
    int counter = 1;

    while(temp != nullptr) {
        // cout << "checking for deletion " << temp->getName() << "\n";
        // cout << prev << " " << temp << " " << temp->getNext() << "\n";

        if(temp->getName() == name) {
            
            if(prev != nullptr) {
                prev->setNext(temp->getNext());
                // cout << "set next of " << prev << " to " << temp->getNext() << "\n";
            }
            else{
                array[index] = temp->getNext();
                // cout << "array index " << index << " to " << temp->getNext() << "\n";
            }
            // cout << "deleting " << temp << " " <<  temp->getName() << " now \n";
            outputFile << "\tDeleted '" << name << "' from position <" << (index + 1) << ", " << counter << "> of ScopeTable# " << id << "\n";
            delete temp;
            return true;
        }
        
        prev = temp;
        temp = temp->getNext();
        counter++;
    }
    outputFile << "\tNot found in the current ScopeTable# " << id << "\n";
    return false;
}

void ScopeTable :: print() {    
        outputFile << "\tScopeTable# " << id << "\n";
        for(int i = 0; i < total_buckets; i++) {
        outputFile << "\t" << (i + 1) ;

        if(array[i] != nullptr) {
            SymbolInfo* temp = array[i];
            while(temp != nullptr) {
                // outputFile << " " << temp << " ";
                outputFile << " --> (" << temp->getName() << "," << temp->getType() << ")";
                temp = temp->getNext();
                // cout << "current pointer is " << temp << " " << (temp != nullptr);
            }
            // cout << "chain finished " << i;
        }
        
        outputFile << "\n";
    }
};


void SymbolTable :: reallocate(int newSize) {
    ScopeTable** newArray = new ScopeTable*[newSize];
    for(int i = 0; i < newSize; i++) {
        newArray[i] = new ScopeTable;
    }
    for(int i = 0; i < size; i++) {
        newArray[i] = array[i];
    }
    std::cout << "\n deleting " << array << "\n";
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

    array[0] = new ScopeTable("1", nullptr, scopeTableSize);
    currentScopeTable = array[0];
    elementNum = 1;
}

SymbolTable :: ~SymbolTable() {

    for(int i = size - 1; i > -1; i-- ) {
        // outputFile << "\ndeleting in symbol table " << i << " " << array[i] ;
        delete array[i];
    }
    // outputFile << "\n deleting " << array << "\n";
    delete[] array;
}

void SymbolTable :: enterScope() {
    // cout << "size " << size << "\n";
    if(size == elementNum) {
        cout << "\nsize " << size << "\n";
        reallocate(2 * size);
    }
    string id = currentScopeTable->getID() + "." + to_string(currentScopeTable->getTotalDeletedChild() + 1);
    std::cout << "new id " << id << "\n";
    array[elementNum++] = new ScopeTable(id, currentScopeTable, scopeTableSize);
    currentScopeTable = array[elementNum - 1];
}

void SymbolTable :: exitScope() {
    if(elementNum <= 1) {
        outputFile << "\tScopeTable# 1 cannot be deleted\n"; 
    }
    else {
        ScopeTable * temp = array[elementNum - 1];
        currentScopeTable = array[elementNum - 2];
        elementNum--;
        // outputFile << "\ndeleting " << temp << "\n";
        delete temp;
        array[elementNum] = nullptr;
        // outputFile << "entry now " << array[elementNum] << "\n";
        currentScopeTable->setTotalDeletedChild(currentScopeTable->getTotalDeletedChild() + 1);
    }
}

bool SymbolTable :: insert(string name, string type) {
    return currentScopeTable->insert(new SymbolInfo(name, type, nullptr));
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
        // outputFile << "#" << temp->getID() << "\n";
        temp->print();

        temp = temp->getParentScope();
    }
}

#endif