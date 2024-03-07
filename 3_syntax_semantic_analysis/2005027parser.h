#ifndef PARSER_H
#define PARSER_H

#include<iostream>
#include<fstream>
#include<vector>
#include "2005027SymbolTable.h"
using namespace std;

// files
extern ofstream logout;
extern ofstream parsetreeout;
extern ofstream errorout;

extern int yylineno;

// parse tree ds
class ParseTree {
private:
    SymbolInfo* value;
    vector<ParseTree*> children;
public:
    ParseTree(SymbolInfo* info) {
        this->value = info;
        // cout << "parsetree " << this << " value " << value << "\n";
    }
    void addChild(ParseTree* info) {
        children.push_back(info);
    }
    SymbolInfo * getValue() {
        return value;
    }
    void print() {
        for(int i = 0; i < value->getTabsNeeded(); i++) {
            parsetreeout << " ";
        }
        parsetreeout << value->getType() << " : " << value->getName() << " \t<Line: " << value->getStartLine();
        if(children.size() != 0) {
            parsetreeout << "-" << value->getEndLine();
        } 
        parsetreeout << ">\n";
        
        for(auto child : children) {
            child->getValue()->setTabsNeeded(value->getTabsNeeded() + 1);
            child->print();
        }
    }
    void printIds(string s) {
        if(value->getType() == "ID") {
            s = s + "\'" + value->getName() + "\'";
            // errorout << "\'" << value->getName() << "\' "; 
        }
        for(auto child : children) {
            child->printIds(s);
        }
    }
    void freeTree() {
        // cout << "free tree called on ";
        // cout << value->getName() << " " << value->getType() << "\n";

        if(children.size() == 0) {
            // cout << "deleting " << value->getType() << " child del " << value << "\n";
            // delete value;
        }
        else {
            for(auto child : children) {
                if(child->getChildren().size() != 0) {
                    child->freeTree();
                }
                delete child;
            }
            for(auto child : children) {                
                // cout << "deleting child " << child << " ";
                // cout << child->getValue()->getType() << " of " << this << "\n";
                
                // cout << "deleted child\n";
            }

            // cout << "clearing children of " << this << " ";
            // cout << value->getType() << "\n";
            children.clear();
            // cout << "cleared children of " << this << " ";
            // cout << value->getType() << "\n";
        }
    }
    vector<ParseTree *> getChildren() {
        return children;
    }

    ~ParseTree() {
        // cout << "destructing tree ptr " << this << "\n";
        // cout << "deleting corresponding symbol " << value << "\n";
        delete value;
        // cout << "deleted symbol\n";
    }
};

#endif
