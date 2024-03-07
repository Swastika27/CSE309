#include<iostream>
#include<fstream>
#include<sstream>

#include "2005027SymbolTable.h"

using namespace std;


int main() {
    ifstream inputFile("input.txt");
    if (!inputFile.is_open()) {
        cout << "Error opening the input file!\n";
        return 1; // Exit the program with an error code
    }

    if (!outputFile.is_open()) {
        cout << "Error opening the output file!\n";
        return 1; // Exit the program with an error code
    }

    int commandCounter = 0;
    string line;
    getline(inputFile, line);
    cout << "\nScopetable size " << atoi(line.c_str()) << "\n";
    SymbolTable* symbolTable = new SymbolTable(atoi(line.c_str()));

    while (getline(inputFile, line)) {
        istringstream iss(line);
        string word;
        string command;
        string args[2];

        iss >> command;
        for(int i = 0; i < 2; i ++) {
            // cout << (args[i] == "") << "balalala\n";
            iss >> args[i];
        }

        commandCounter++;
        outputFile << "Cmd " << commandCounter << ": " << line << "\n";
        if(iss >> word) {
            outputFile << "\tWrong number of arugments for the command " << command << "\n";
        }
        else {
            // execute command
            if (command == "I") {
                if(args[0] != "" && args[1] != "") {
                    symbolTable->insert(args[0], args[1]);
                }
                else {
                    outputFile << "\tWrong number of arugments for the command " << command << "\n";
                }
            }
            else if (command == "L") {
                if(args[1] != "") {
                    outputFile << "\tWrong number of arugments for the command " << command << "\n";
                }
                else {
                    if(symbolTable->lookup(args[0]) == nullptr) {
                        outputFile << "\t'" << args[0] << "' not found in any of the ScopeTables\n";
                    }
                }
            }
            else if (command == "D") {
                if((args[0] == "") || (args[1] != "")) {
                    outputFile << "\tWrong number of arugments for the command " << command << "\n";
                }
                else {
                    symbolTable->remove(args[0]);
                }
            } 
            else if (command == "P") {
                if(args[1] != "") {
                    outputFile << "\tWrong number of arugments for the command " << command << "\n";
                }
                else {
                    if(args[0] == "C") {
                        symbolTable->printCurrentScopeTable();
                    }
                    else if(args[0] == "A") {
                        symbolTable->printAllScopeTable();
                    }
                    else {
                        outputFile<< "\tInvalid argument for the command P\n";
                    }
                }
            }
            else if (command == "S") {
                if(args[0] == "" && args[1] == "") {
                    symbolTable->enterScope();
                }
                else {
                    outputFile<< "\tInvalid argument for the command S\n";
                }
            } 
            else if (command == "E") {
                if(args[0] == "" && args[1] == "") {
                    symbolTable->exitScope();
                }
                else {
                    outputFile<< "\tInvalid argument for the command E\n";
                }
            }
            else if (command == "Q") {
                break;
            }
            else {
                outputFile << "Unknown command" << "\n";
            }
            // outputFile << "printing after command " << line << "\n";
            // symbolTable->printAllScopeTable();
        }
    }

        
    delete symbolTable;
    inputFile.close();
    outputFile.close();
    cout << "files closed \n";
    return 0;
}