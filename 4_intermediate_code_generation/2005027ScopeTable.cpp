#include "2005027ScopeTable.h"

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

    // logout << "\tScopeTable# " << id << " created\n";

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

    // logout << "\tScopeTable# " << id << " created\n";
}

ScopeTable :: ~ScopeTable() {
    // logout << "\ntrying to delete scope table " << this << "\n"; 

    // following loop deletes individual symbols
    // for (int i = 0; i < total_buckets; i++) {
    //     SymbolInfo* current = array[i];
    //     while (current != nullptr) {
    //         SymbolInfo* temp = current;
    //         current = current->getNext();
    //         // logout << "\ndeleting in scope table " << id << "\n";
    //         delete temp;
    //     }
    // }
    // cout << "\n deleting array in scope table" << id << "\n";
    delete[] array;
    // logout << "\tScopeTable# " << id << " deleted\n";
}

void ScopeTable :: setId(string s) {
    id = s;
}

string ScopeTable :: getID() {
    return id;
}

ScopeTable *ScopeTable :: getParentScope() {
    return parentScope;
}

void ScopeTable :: setParentScope(ScopeTable* parent) {
    this->parentScope = parent;
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
        // logout << "\tInserted  at position <" << (index + 1) << ", " << 1 << "> of ScopeTable# " << id << "\n"; 

        return true;
    }
    else {
        int counter = 1;

        SymbolInfo* temp = array[index];
        while(temp != nullptr) {
            // cout << "checking " << temp->getName() << " " << temp->getNext() << "\n";
            if(temp->getName() == info->getName()) {
                // cout << "this is already there\n";
                // logout << "\t" << info->getName() << " already exists in the current ScopeTable\n";
                // delete info;
                return false;
            }
            if(temp->getNext() == nullptr) {
                temp->setNext(info);
                // cout<< "\ninserted " << info->getName() << " after " << temp->getNext() << " at " << info << "\n";
                // logout << "\tInserted  at position <" << (index + 1) << ", " << (counter + 1) << "> of ScopeTable# " << id << "\n"; 
                return true;
            }
            temp = temp->getNext();
            counter++;
        }
        return false;
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
            // logout << "\t'" << name << "' found at position <" << (index + 1) << ", " << count << "> of ScopeTable# " << id << "\n";
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
            // logout << "\tDeleted '" << name << "' from position <" << (index + 1) << ", " << counter << "> of ScopeTable# " << id << "\n";
            delete temp;
            return true;
        }
        
        prev = temp;
        temp = temp->getNext();
        counter++;
    }
    // logout << "\tNot found in the current ScopeTable# " << id << "\n";
    return false;
}

void ScopeTable :: print() {    
     logout << "\tScopeTable# " << id << "\n";
        for(int i = 0; i < total_buckets; i++) {   
            if(array[i] != nullptr) {
                logout << "\t" << (i + 1) << "-->" ;
                SymbolInfo* temp = array[i];
                while(temp != nullptr) {
                    // logout << " " << temp << " ";
                    logout << " <" << temp->getName() << ",";
                    if(temp->getType() == "ID" && temp->getArray()) {
                        logout << "ARRAY";
                    }
                    else if(temp->getType() == "ID" && (temp->getIsFunctionDeclaration() || temp->getIsFunctionDefinition())) {
                        logout << "FUNCTION," << temp->getDataType();
                    } 
                    else {
                        logout << temp->getDataType();
                    }
                    logout << "> ";
                    temp = temp->getNext();
                    // cout << "current pointer is " << temp << " " << (temp != nullptr);
                }
                // cout << "chain finished " << i;        
                logout << "\n";
            }
    }
}