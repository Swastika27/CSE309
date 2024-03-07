%{
#include<iostream>
#include<fstream>
#include<vector>

#include<typeinfo>
#include "2005027SymbolTable.h"
#include "2005027parser.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

ofstream logout;
ofstream errorout;
ofstream parsetreeout;

extern int yylineno;
int total_line;

SymbolTable *table = new SymbolTable(11);
ParseTree *parsetree;

int parser_error_count;
// vector<SymbolInfo *> symbolsWithoutScope;

// ScopeTable * unnamedScope;

bool func_def_started = false;

vector<SymbolInfo *> arg_type_list;

void yyerror(string s) {

}

void log_rule(string rule) {
     logout << rule << "\n";
}

void print_error(int line, string error) {
     errorout << "Line# " << line << ": " << error << "\n";
     parser_error_count++;
}

void set_type_var(string type_specifier, ParseTree* declaration_list) {
     if(declaration_list->getValue()->getType() == "ID") {
          declaration_list->getValue()->setDataType(type_specifier);          
          // errorout << "got id " << declaration_list->getValue()->getName() << " type " << declaration_list->getValue()->getDataType() << "\n";

          if(type_specifier == "VOID") {
               print_error(declaration_list->getValue()->getStartLine(), "Variable or field \'" + declaration_list->getValue()->getName() + "\' declared void");
          }
          else {
               bool inserted = table->insert(declaration_list->getValue());
               if(!inserted) {
                    print_error(declaration_list->getValue()->getStartLine(), "Conflicting types for \'" + declaration_list->getValue()->getName() + "\'");
               }
               // if(func_def_started) {
               //      // symbolsWithoutScope.push_back(declaration_list->getValue());
               //      // cout << "inserting local variable to unnamed scope\n";
               //      bool inserted = unnamedScope->insert(declaration_list->getValue());
               //      if(!inserted) {
               //           print_error(declaration_list->getValue()->getStartLine(), "Conflicting types for \'" + declaration_list->getValue()->getName() + "\'");
               //      }
               //      // else 
               //           // cout << "inserted id " << declaration_list->getValue()->getName() << " type " << declaration_list->getValue()->getDataType() << " " << declaration_list->getValue()->getArray() << " to unnamed scope\n";
               // }
               // else {
               //      bool inserted = table->insert(declaration_list->getValue());
               //      if(!inserted) {
               //           print_error(declaration_list->getValue()->getStartLine(), "Conflicting types for \'" + declaration_list->getValue()->getName() + "\'");
               //      }
               //      else
               //           cout << "inserted id " << declaration_list->getValue()->getName() << " type " << declaration_list->getValue()->getDataType() << " " << declaration_list->getValue()->getArray() << " to symbol table\n";
               // } 
          }         
          return;
     }
     else if(declaration_list->getValue()->getType() == "declaration_list"){
          for(auto child : declaration_list->getChildren()) {
               if(child->getValue()->getType() == "ID" || child->getValue()->getType() == "declaration_list")
                    set_type_var(type_specifier, child);
          }
     }
     return;
}

void set_func_param_type(SymbolInfo * func, ParseTree * param_list) {
     if(param_list->getValue()->getType() == "type_specifier") {
          // cout << "found type specifier " << param_list->getValue()->getName() << "\n";
          func->addParam(param_list->getValue()->getName());
          return;
     }
     for(auto child : param_list->getChildren()) {
          if(child->getValue()->getType() == "type_specifier" || child->getValue()->getType() == "parameter_list") {
               set_func_param_type(func, child);
          }
     }
     
}

void insert_params_to_scope(ParseTree * param_list) {
     if(param_list->getValue()->getType() == "ID") {
          // symbolsWithoutScope.push_back(param_list->getValue());
          // cout << "inside inserting params to unnamed scope\n";
          // bool inserted = unnamedScope->insert(param_list->getValue()); 
          bool inserted = table->insert(param_list->getValue()); 

          if(!inserted) {
               print_error(param_list->getValue()->getStartLine(), "Redefinition of parameter \'" + param_list->getValue()->getName() + "\'") ;
               // errorout << "Line #" << param_list->getValue()->getStartLine() << ": redefinition of parameter \'" << param_list->getValue()->getName() << "\'\n"; 
               // parser_error_count++;
          }
          return;
     }
     else if(param_list->getValue()->getType() == "parameter_list") {
          for(auto child : param_list->getChildren()) {
               insert_params_to_scope(child);
          }
     }
     return;
}

%}

%locations

%union{
     ParseTree* info;
}

%token<info> IF FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE CONST_CHAR ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON CONST_INT CONST_FLOAT ID STRING PRINTLN
%type<info> start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments func_marker initialization_list

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program{
     log_rule("start : program");
     $$ = new ParseTree(new SymbolInfo("program", "start", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
     $$->addChild($1);

     parsetree = $$;
    }
    ;

program : program unit {
               log_rule("program : program unit");

               $$ = new ParseTree(new SymbolInfo("program unit", "program", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
          }
        | unit {
          log_rule("program : unit");
          
          $$ = new ParseTree(new SymbolInfo("unit", "program", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);
        }
        ;

unit : var_declaration {
          log_rule("unit : var_declaration");

          $$ = new ParseTree(new SymbolInfo("var_declaration", "unit", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);
     }
     | func_declaration {
          log_rule("unit : func_declaration");

          $$ = new ParseTree(new SymbolInfo("func_declaration", "unit", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);
     }
     | func_definition {
          log_rule("unit : func_definition");

          $$ = new ParseTree(new SymbolInfo("func_definition", "unit", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);
     }
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
                    log_rule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
                    $$ = new ParseTree(new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", "func_declaration", $1->getValue()->getStartLine(), $6->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $2->getValue()->setIsFunctionDeclaration(true);
                    $2->getValue()->setDataType($1->getValue()->getName());
                    $$->addChild($3);
                    $$->addChild($4);
                    $$->addChild($5);
                    $$->addChild($6);

                    set_func_param_type($2->getValue(), $4);

                    $2->getValue()->setDataType($1->getValue()->getName());
                    bool inserted = table->insert($2->getValue());
                    if(!inserted) {
                         SymbolInfo * prev_occurrence = table->lookup($2->getValue()->getName());
                         if(prev_occurrence->getIsFunctionDeclaration() || prev_occurrence->getIsFunctionDefinition()) {
                              // match ret_type and param_list
                              vector<string> prev = prev_occurrence->getParameterList();
                              vector<string> curr = $2->getValue()->getParameterList();
                              if(prev_occurrence->getDataType() != $2->getValue()->getDataType() || prev.size() != curr.size()) {
                                   print_error($2->getValue()->getStartLine(), "Conflicting types for \'" + $2->getValue()->getName() + "\'");
                              }
                              else {
                                   for(int i = 0; i < prev.size(); i++) {
                                        if(prev[i] != curr[i]) {
                                             if(prev[i] == "FLOAT" && curr[i] == "INT") {
                                                  continue;
                                             }
                                             print_error($2->getValue()->getStartLine(), "Type mismatch for argument " + to_string(i + 1) + "of function " + $2->getValue()->getName()+ " " + prev[i] + " " + curr[i]);
                                        }
                                   }
                              }
                         }                         
                         else {
                              print_error($2->getValue()->getStartLine(), "\'" + $2->getValue()->getName() + "\' redeclared as different kind of symbol");
                         }
                    }
               }
                 | type_specifier ID LPAREN RPAREN SEMICOLON{
                    log_rule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");

                    $$ = new ParseTree(new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON", "func_declaration", $1->getValue()->getStartLine(), $5->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $2->getValue()->setIsFunctionDeclaration(true);
                    $2->getValue()->setDataType($1->getValue()->getName());
                    $$->addChild($3);
                    $$->addChild($4);
                    $$->addChild($5);

                    $2->getValue()->setDataType($1->getValue()->getName());
                    set_func_param_type($2->getValue(), $4);

                    bool inserted = table->insert($2->getValue());
                    if(!inserted) {
                         SymbolInfo * prev_occurrence = table->lookup($2->getValue()->getName());
                         if(prev_occurrence->getIsFunctionDeclaration() || prev_occurrence->getIsFunctionDefinition()) {
                              // match ret_type and param_list
                              vector<string> prev = prev_occurrence->getParameterList();
                              vector<string> curr = $2->getValue()->getParameterList();
                              if(prev_occurrence->getDataType() != $2->getValue()->getDataType() || prev.size() != curr.size()) {
                                   print_error($2->getValue()->getStartLine(), "Conflicting types for \'" + $2->getValue()->getName() + "\'");
                              }
                              else {
                                   for(int i = 0; i < prev.size(); i++) {
                                        if(prev[i] != curr[i]) {
                                             if(prev[i] == "FLOAT" && curr[i] == "INT") {
                                                  continue;
                                             }
                                             print_error($2->getValue()->getStartLine(), "Type mismatch for argument " + to_string(i + 1) + "of function " + $2->getValue()->getName()+ " " + prev[i] + " " + curr[i]);
                                        }
                                   }
                              }
                         }                         
                         else {
                              print_error($2->getValue()->getStartLine(), "\'" + $2->getValue()->getName() + "\' redeclared as different kind of symbol");
                         }
                    }
               }
               
               ;
func_definition : type_specifier ID func_marker compound_statement {
                    string rule = "type_specifier ID ";
                    if($3->getChildren().size() == 2) {
                         rule = rule + "LPAREN RPAREN ";
                    }
                    else if ($3->getChildren().size() == 3) {
                         rule = rule + "LPAREN parameter_list RPAREN ";
                    }
                    rule = rule + "compound_statement";

                    $$ = new ParseTree(new SymbolInfo(rule, "func_definition", $1->getValue()->getStartLine(), $4->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $2->getValue()->setIsFunctionDefinition(true);
                    $2->getValue()->setDataType($1->getValue()->getName());
                    for(auto child : $3->getChildren()) {
                         if(child->getValue()->getType() == "parameter_list") {
                              set_func_param_type($2->getValue(), child);
                         }
                         $$->addChild(child);
                    }
                    delete $3;
                    $$->addChild($4);

                    // table->insertScopeTable(unnamedScope);

                    // table->printAllScopeTable();
                    // table->exitScope();
                    // unnamedScope = nullptr;

                    $2->getValue()->setDataType($1->getValue()->getName());
                    $2->getValue()->setIsFunctionDefinition(true);
                    bool inserted = table->insert($2->getValue());
                     if(!inserted) {
                         SymbolInfo * prev_occurrence = table->lookup($2->getValue()->getName());
                         if(prev_occurrence->getIsFunctionDefinition()) {
                              print_error($2->getValue()->getStartLine(), "Redefinition of function \'" + $2->getValue()->getName() + "\'");
                         }
                         else if(prev_occurrence->getIsFunctionDeclaration()) {
                              // match ret_type and param_list
                              vector<string> prev = prev_occurrence->getParameterList();
                              vector<string> curr = $2->getValue()->getParameterList();
                              if(prev_occurrence->getDataType() != $2->getValue()->getDataType() || prev.size() != curr.size()) {
                                   print_error($2->getValue()->getStartLine(), "Conflicting types for \'" + $2->getValue()->getName() + "\'");
                              }
                              else {
                                   for(int i = 0; i < prev.size(); i++) {
                                        if(prev[i] != curr[i]) {
                                             if(prev[i] == "FLOAT" && curr[i] == "INT") {
                                                  continue;
                                             }
                                             print_error($2->getValue()->getStartLine(), "Type mismatch for argument " + to_string(i + 1) + "of function " + $2->getValue()->getName()+ " " + prev[i] + " " + curr[i]);
                                        }
                                   }
                              }
                         }
                         else {
                              print_error($2->getValue()->getStartLine(), "\'" + $2->getValue()->getName() + "\' redeclared as different kind of symbol");
                         }
                    }

                    log_rule("func_definition : " + rule);
                }
                ;

func_marker : LPAREN parameter_list RPAREN {
               $$ = new ParseTree(new SymbolInfo("LPAREN parameter_list RPAREN", "func_marker", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);

               // cout << "allocating unnamed scope\n";
               // unnamedScope = new ScopeTable(11);
               // cout << "allocated unnamed scope\n";
               // table->enterScope();
               insert_params_to_scope($2);
               // cout << "inserted params to unnamed scope\n";
               func_def_started = true;
          }
            | LPAREN RPAREN {
               $$ = new ParseTree(new SymbolInfo("LPAREN RPAREN", "func_marker", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);

               // unnamedScope = new ScopeTable(11);
               // table->enterScope();
               func_def_started = true;
            }   

parameter_list : parameter_list COMMA type_specifier ID {
                    log_rule("parameter_list : parameter_list COMMA type_specifier ID");

                    $$ = new ParseTree(new SymbolInfo("parameter_list COMMA type_specifier ID", "parameter_list", $1->getValue()->getStartLine(), $4->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3);
                    $$->addChild($4);

                    $4->getValue()->setDataType($3->getValue()->getName());
               }
               | parameter_list COMMA type_specifier {
                    log_rule("parameter_list : parameter_list COMMA type_specifier");

                    $$ = new ParseTree(new SymbolInfo("parameter_list COMMA type_specifier", "parameter_list", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3); 
               }
               | type_specifier ID {
                    log_rule("parameter_list : type_specifier ID");

                    $$ = new ParseTree(new SymbolInfo("type_specifier ID", "parameter_list", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);

                    $2->getValue()->setDataType($1->getValue()->getName());
               }
               | type_specifier {
                    log_rule("parameter_list : type_specifier");

                    $$ = new ParseTree(new SymbolInfo("type_specifier", "parameter_list", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);
               }
               /* | error {
                    log_rule("Error at line " + to_string(@1.first_line) + " : syntax error");

                    $$ = new ParseTree(new SymbolInfo("type_specifier", "parameter_list", @1.first_line, @1.last_line));
                    print_error(@1.first_line, "Syntax error at parameter list of function definition");
               } */
               ;

compound_statement : LCURL statements RCURL {
                         log_rule("compound_statement : LCURL statements RCURL");

                         $$ = new ParseTree(new SymbolInfo("LCURL statements RCURL", "compound_statement", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                         $$->addChild($1);
                         $$->addChild($2);
                         $$->addChild($3);

                         table->printAllScopeTable();
                         // logout << "exiting scopetable " << $3->getValue()->getEndLine() << "\n";
                         table->exitScope();
                         func_def_started = false;
                    }
                   | LCURL RCURL {
                         log_rule("compound_statement : LCURL RCURL");

                         $$ = new ParseTree(new SymbolInfo("LCURL statements RCURL", "compound_statement", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
                         $$->addChild($1);
                         $$->addChild($2);

                         table->printAllScopeTable();
                         // logout << "exiting scopetable " << $2->getValue()->getEndLine() << "\n";
                         table->exitScope();
                         func_def_started = false;
                   }
                   ;

var_declaration : type_specifier declaration_list SEMICOLON {
                    log_rule("var_declaration : type_specifier declaration_list SEMICOLON");

                    $$ = new ParseTree(new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3);

                    set_type_var($1->getValue()->getName(), $2);
               }
                ;

type_specifier : INT {
                    log_rule("type_specifier : INT");

                    $$ = new ParseTree(new SymbolInfo("INT", "type_specifier", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);
               }
               | FLOAT {
                    log_rule("type_specifier : FLOAT");

                    $$ = new ParseTree(new SymbolInfo("FLOAT", "type_specifier", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);
               }
               | VOID {
                    log_rule("type_specifier : VOID");

                    $$ = new ParseTree(new SymbolInfo("VOID", "type_specifier", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);
               }
               ;

declaration_list : declaration_list COMMA ID {
                    log_rule("declaration_list : declaration_list COMMA ID");

                    $$ = new ParseTree(new SymbolInfo("declaration_list COMMA ID", "declaration_list", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3);
               }
                 | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {
                    log_rule("declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");

                    $$ = new ParseTree(new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE", "declaration_list", $1->getValue()->getStartLine(), $6->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3);
                    $3->getValue()->setArray(true);
                    $3->getValue()->setDataType("ARRAY");
                    $$->addChild($4);
                    $$->addChild($5);
                    $$->addChild($6);
                 }
                 | ID {
                    log_rule("declaration_list : ID");

                    $$ = new ParseTree(new SymbolInfo("ID", "declaration_list", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);
                 }
                 | ID LSQUARE CONST_INT RSQUARE {
                    log_rule("declaration_list : ID LSQUARE CONST_INT RSQUARE");

                    $$ = new ParseTree(new SymbolInfo("ID LSQUARE CONST_INT RSQUARE", "declaration_list", $1->getValue()->getStartLine(), $4->getValue()->getEndLine()));
                    $$->addChild($1);
                    $1->getValue()->setArray(true);
                    $1->getValue()->setDataType("ARRAY");
                    $$->addChild($2);
                    $$->addChild($3);
                    $$->addChild($4);
                 }
                 | ID LSQUARE RSQUARE ASSIGNOP RCURL initialization_list LCURL {
                    log_rule("declaration_list : ID LSQUARE RSQUARE ASSIGNOP RCURL initialization_list LCURL");
                    $$ = new ParseTree(new SymbolInfo("ID LSQUARE RSQUARE ASSIGNOP RCURL initialization_list LCURL", "declaration_list", $1->getValue()->getStartLine(), $7->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3);
                    $$->addChild($4);
                    $$->addChild($5);
                    $$->addChild($6);
                    $$->addChild($7);

                    $1->getValue()->setArray(true);
                    $1->getValue()->setDataType("ARRAY");
                 }
                 /* | error {
                    log_rule("Error at line " + to_string(@1.first_line) + " : syntax error");
                    $$ = new ParseTree(new SymbolInfo("error", "declaration_list", @1.first_line, @1.last_line));
                    print_error(@1.first_line, "Syntax error at declaration list of variable declaration");
                 } */
                 ;

statements : statement {
               log_rule("statements : statement");

               $$ = new ParseTree(new SymbolInfo("statement", "statements", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
               $$->addChild($1);
          }
           | statements statement {
               log_rule("statements : statements statement");

               $$ = new ParseTree(new SymbolInfo("statements statement", "statements", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
           }
           ;

statement : var_declaration {
               log_rule("statement : var_declaration");

               $$ = new ParseTree(new SymbolInfo("var_declaration", "statement", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
               $$->addChild($1);
          }
          | expression_statement {
               log_rule("statement : expression_statement");

               $$ = new ParseTree(new SymbolInfo("expression_statement", "statement", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
               $$->addChild($1);
          }
          | compound_statement {
               log_rule("statement : expression_statement");

               $$ = new ParseTree(new SymbolInfo("expression_statement", "statement", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
               $$->addChild($1);
          }
          | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
               log_rule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");

               $$ = new ParseTree(new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement", $1->getValue()->getStartLine(), $7->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);
               $$->addChild($4);
               $$->addChild($5);
               $$->addChild($6);
               $$->addChild($7);
          }
          | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
               log_rule("statement : IF LPAREN expression RPAREN statement");

               $$ = new ParseTree(new SymbolInfo("IF LPAREN expression RPAREN statement", "statement", $1->getValue()->getStartLine(), $5->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);
               $$->addChild($4);
               $$->addChild($5);
          }
          | IF LPAREN expression RPAREN statement ELSE statement{
               log_rule("statement : IF LPAREN expression RPAREN statement ELSE statement");
               $$ = new ParseTree(new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement", "statement", $1->getValue()->getStartLine(), $7->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);
               $$->addChild($4);
               $$->addChild($5);
               $$->addChild($6);
               $$->addChild($7);
          }
          | WHILE LPAREN expression RPAREN statement {
               log_rule("statement : WHILE LPAREN expression RPAREN statement");

               $$ = new ParseTree(new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement", $1->getValue()->getStartLine(), $5->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);
               $$->addChild($4);
               $$->addChild($5);
          }
          | PRINTLN LPAREN ID RPAREN SEMICOLON {
               log_rule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");

               $$ = new ParseTree(new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON", "statement", $1->getValue()->getStartLine(), $4->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);
               $$->addChild($4);
          }
          | RETURN expression SEMICOLON {
               log_rule("statement : RETURN expression SEMICOLON");

               $$ = new ParseTree(new SymbolInfo("RETURN expression SEMICOLON", "statement", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);
          }
          ;

expression_statement : SEMICOLON {
                         log_rule("expression_statement : SEMICOLON");

                         $$ = new ParseTree(new SymbolInfo("SEMICOLON", "expression_statement", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                         $$->addChild($1);
                    }
                     | expression SEMICOLON {
                         log_rule("expression_statement : expression SEMICOLON");

                         $$ = new ParseTree(new SymbolInfo("expression SEMICOLON", "expression_statement", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
                         $$->addChild($1);
                         $$->addChild($2);
                     }
                     ;

variable : ID {
               log_rule("variable : ID");
               
               $$ = new ParseTree(new SymbolInfo("ID", "variable", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
               $$->addChild($1);

               SymbolInfo* prev = nullptr;
               // if(unnamedScope != nullptr) {
               //      prev = unnamedScope->lookup($1->getValue()->getName());
               //      // isPresent |= (unnamedScope->lookup($1->getValue()->getName()) != nullptr);
               // }
               if(prev == nullptr) {
                    prev = table->lookup($1->getValue()->getName());
               }
               if(prev != nullptr) {
                    $$->getValue()->setDataType(prev->getDataType());
                    $$->getValue()->setArray(prev->getArray());
                    // errorout << "ID " << $1->getValue()->getName() << " type " << $$->getValue()->getDataType() << " going variable\n";
               }
               else {
                    print_error($1->getValue()->getStartLine(), "Undeclared variable \'" + $1->getValue()->getName() + "\'");
               }
          }
         | ID LSQUARE expression RSQUARE {
               log_rule("variable : ID LSQUARE expression RSQUARE");

               $$ = new ParseTree(new SymbolInfo("ID LSQUARE expression RSQUARE", "variable", $1->getValue()->getStartLine(), $4->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);
               $$->addChild($4);

               SymbolInfo* prev = nullptr;
               // if(unnamedScope != nullptr) {
               //      prev = unnamedScope->lookup($1->getValue()->getName());
               //      // isPresent |= (unnamedScope->lookup($1->getValue()->getName()) != nullptr);
               // }
               if(prev == nullptr) {
                    prev = table->lookup($1->getValue()->getName());
               }
               if(prev != nullptr) {
                    $$->getValue()->setDataType(prev->getDataType());
                    if(!prev->getArray()) {
                         print_error($1->getValue()->getStartLine(), "\'" + $1->getValue()->getName() + "\' is not an array");
                    }
                    else if($3->getValue()->getDataType() != "INT") {
                         print_error($1->getValue()->getStartLine(), "Array subscript is not an integer");
                    }
                    // errorout << "ID " << $1->getValue()->getName() << " type " << $$->getValue()->getDataType() << " going variable\n";
               }
               else {
                    print_error($1->getValue()->getStartLine(), "Undeclared variable \'" + $1->getValue()->getName() + "\'");
               }
         }
         ;

initialization_list : initialization_list COMMA logic_expression {
     log_rule("initialization_list : initialization_list COMMA logic_expression");

     $$ = new ParseTree(new SymbolInfo("initialization_list COMMA logic_expression", "initialization_list", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
     $$->addChild($1);
     $$->addChild($2);
     $$->addChild($3);

}
| logic_expression {
     log_rule("initialization_list : logic_expression");
     $$ = new ParseTree(new SymbolInfo("logic_expression", "initialization_list", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
     $$->addChild($1);

     $$->getValue()->setDataType($1->getValue()->getDataType());
     $$->getValue()->setArray($1->getValue()->getArray());
     $$->getValue()->setIsZero($1->getValue()->getIsZero());
}

expression : logic_expression  {
               log_rule("expression : logic_expression");
               
               $$ = new ParseTree(new SymbolInfo("logic_expression", "expression", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
               $$->addChild($1);

               $$->getValue()->setDataType($1->getValue()->getDataType());
               $$->getValue()->setArray($1->getValue()->getArray());
               $$->getValue()->setIsZero($1->getValue()->getIsZero());
          }
           | variable ASSIGNOP logic_expression {
               log_rule("expression : variable ASSIGNOP logic_expression");

               $$ = new ParseTree(new SymbolInfo("variable ASSIGNOP logic_expression", "expression", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
               $$->addChild($1);
               $$->addChild($2);
               $$->addChild($3);

               if($1->getValue()->getDataType() != $3->getValue()->getDataType()) {
                    if($1->getValue()->getDataType() == "INT" && $3->getValue()->getDataType() == "FLOAT") {
                         print_error($1->getValue()->getStartLine(), "Warning: possible loss of data in assignment of FLOAT to INT");
                    }
                    else if($3->getValue()->getDataType() == "VOID") {
                         print_error($1->getValue()->getStartLine(), "Void cannot be used in expression");
                    }
                    else if($1->getValue()->getDataType() == "FLOAT" && $3->getValue()->getDataType() == "INT") {
                         // type cast from int to float
                    }
                    else if($1->getValue()->getDataType() != "" && $3->getValue()->getDataType() != ""){
                         print_error($1->getValue()->getStartLine(), "Operands of assignment operator not consistent " + $1->getValue()->getDataType() + " " + $3->getValue()->getDataType());
                    }
               }
               else if($1->getValue()->getArray() != $3->getValue()->getArray()) {
                    print_error($1->getValue()->getStartLine(), "assignment to expression with array type");
               }
               $$->getValue()->setDataType($1->getValue()->getDataType());
           }
           /* | error {
               log_rule("Error at line " + to_string(@1.first_line) + " : syntax error");
               $$ = new ParseTree(new SymbolInfo("error", "expression", @1.first_line, @1.last_line));
               print_error(@1.first_line, "Syntax error at expression of expression statement");
           } */
           ;

logic_expression : rel_expression {
                    log_rule("logic_expression : rel_expression");
                    
                    $$ = new ParseTree(new SymbolInfo("rel_expression", "logic_expression", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);

                    $$->getValue()->setDataType($1->getValue()->getDataType());
                    $$->getValue()->setArray($1->getValue()->getArray());
                    $$->getValue()->setIsZero($1->getValue()->getIsZero());
               }
                 | rel_expression LOGICOP rel_expression {
                    log_rule("logic_expression : rel_expression LOGICOP rel_expression");

                    $$ = new ParseTree(new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3);

                    $$->getValue()->setDataType("INT");
                 }
                 ;

rel_expression : simple_expression {
                    log_rule("rel_expression : simple_expression");

                    $$ = new ParseTree(new SymbolInfo("simple_expression", "rel_expression", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);

                    $$->getValue()->setDataType($1->getValue()->getDataType());
                    $$->getValue()->setArray($1->getValue()->getArray());
                    $$->getValue()->setIsZero($1->getValue()->getIsZero());
               }
               | simple_expression RELOP simple_expression {
                    log_rule("rel_expression : simple_expression RELOP simple_expression");

                    $$ = new ParseTree(new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);
                    $$->addChild($3);
                    
                    $$->getValue()->setDataType("INT");
               }
               ;

simple_expression : term {
                         log_rule("simple_expression : term");
                         
                         $$ = new ParseTree(new SymbolInfo("term", "simple_expression", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                         $$->addChild($1);
                         
                         $$->getValue()->setDataType($1->getValue()->getDataType());
                         $$->getValue()->setArray($1->getValue()->getArray());
                         $$->getValue()->setIsZero($1->getValue()->getIsZero());
                    }
                  | simple_expression ADDOP term {
                         log_rule("simple_expression : simple_expression ADDOP term");

                         $$ = new ParseTree(new SymbolInfo("simple_expression ADDOP term", "simple_expression", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                         $$->addChild($1);
                         $$->addChild($2);
                         $$->addChild($3);

                         if($1->getValue()->getDataType() == "VOID" || $3->getValue()->getDataType() == "VOID") {
                              print_error($1->getValue()->getStartLine(), "Void cannot be used in expression");
                              string dataType = $1->getValue()->getDataType() == "VOID" ? $2->getValue()->getDataType() : $1->getValue()->getDataType();
                         }
                         else if($1->getValue()->getDataType() == "FLOAT" || $3->getValue()->getDataType() == "FLOAT") {                              
                              $$->getValue()->setDataType("FLOAT");
                         }
                         else {
                              $$->getValue()->setDataType("INT");
                         }
                  }
                  ;

term : unary_expression {
          log_rule("term : unary_expression");

          $$ = new ParseTree(new SymbolInfo("unary_expression", "term", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);

          $$->getValue()->setDataType($1->getValue()->getDataType());
          $$->getValue()->setArray($1->getValue()->getArray());
          $$->getValue()->setIsZero($1->getValue()->getIsZero());
     }
     | term MULOP unary_expression {
          log_rule("term : term MULOP unary_expression");

          $$ = new ParseTree(new SymbolInfo("term MULOP unary_expression", "term", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);

          if($1->getValue()->getDataType() == "VOID" || $3->getValue()->getDataType() == "VOID") {
               print_error($1->getValue()->getStartLine(), "Void cannot be used in expression");
               string dataType = $1->getValue()->getDataType() == "VOID" ? $2->getValue()->getDataType() : $1->getValue()->getDataType();
          }
          else if(($1->getValue()->getDataType() == "FLOAT" || $3->getValue()->getDataType() == "FLOAT") && ($3->getValue()->getName() == "%" || $3->getValue()->getName() == "*")) {                              
               $$->getValue()->setDataType("FLOAT");//type cast
          }
          else {
               $$->getValue()->setDataType("INT");
          }

          if(($2->getValue()->getName() == "%") && ($1->getValue()->getDataType() == "FLOAT" || $3->getValue()->getDataType() == "FLOAT")) {
               print_error($1->getValue()->getStartLine(), "Operands of modulus must be integers");
          }

          if(($2->getValue()->getName() == "/" || $2->getValue()->getName() == "%") && $3->getValue()->getIsZero()) {
               print_error($1->getValue()->getStartLine(), "Warning: division by zero");
          }
     }
     ;

unary_expression : ADDOP unary_expression {
                    log_rule("unary_expression : ADDOP unary_expression");

                    $$ = new ParseTree(new SymbolInfo("ADDOP unary_expression", "unary_expression", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);

                    $$->getValue()->setDataType($2->getValue()->getDataType());
               }
                 | NOT unary_expression {
                    log_rule("unary_expression : NOT unary_expression");

                    $$ = new ParseTree(new SymbolInfo("NOT unary_expression", "unary_expression", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
                    $$->addChild($1);
                    $$->addChild($2);

                    $$->getValue()->setDataType("INT");
                 }
                 | factor {
                    log_rule("unary_expression : factor");

                    $$ = new ParseTree(new SymbolInfo("factor", "unary_expression", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);

                    $$->getValue()->setDataType($1->getValue()->getDataType());
                    $$->getValue()->setArray($1->getValue()->getArray());
                    $$->getValue()->setIsZero($1->getValue()->getIsZero());
                 }
                 ;

factor : variable {
          log_rule("factor : variable");

          $$ = new ParseTree(new SymbolInfo("variable", "factor", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);

          $$->getValue()->setDataType($1->getValue()->getDataType());
          $$->getValue()->setArray($1->getValue()->getArray());
        }
       | ID LPAREN argument_list RPAREN {
          log_rule("factor : ID LPAREN argument_list RPAREN");

          $$ = new ParseTree(new SymbolInfo("ID LPAREN argument_list RPAREN", "factor", $1->getValue()->getStartLine(), $4->getValue()->getEndLine()));
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
          $$->addChild($4);

          SymbolInfo* prev = nullptr;
          // if(unnamedScope != nullptr) {
          //      prev = unnamedScope->lookup($1->getValue()->getName());
          //      // isPresent |= (unnamedScope->lookup($1->getValue()->getName()) != nullptr);
          // }
          if(prev == nullptr) {
               prev = table->lookup($1->getValue()->getName());
          }
          if(prev == nullptr) {
               print_error($1->getValue()->getStartLine(), "Undeclared function \'" + $1->getValue()->getName() + "\'");
          }
          else {
               $$->getValue()->setDataType(prev->getDataType());

               SymbolInfo * prev_occurrence = table->lookup($1->getValue()->getName());
               if(prev_occurrence->getIsFunctionDeclaration() || prev_occurrence->getIsFunctionDefinition()) {
                    vector<string> prev = prev_occurrence->getParameterList();
                    vector<SymbolInfo *> curr = arg_type_list;
                    if(prev.size() > curr.size()) {
                         print_error($1->getValue()->getStartLine(), "Too few arguments to function \'" + $1->getValue()->getName() + "\'");
                    }
                    else if(prev.size() < curr.size()) {
                         print_error($1->getValue()->getStartLine(), "Too many arguments to function \'" + $1->getValue()->getName() + "\'");
                    }
                    else {
                         for(int i = 0; i < prev.size(); i++) {
                              if(prev[i] != curr[i]->getDataType()) {
                                   if(prev[i] == "FLOAT" && curr[i]->getDataType() == "INT") {
                                        // type cast
                                   }
                                   else {
                                        print_error($1->getValue()->getStartLine(), "Type mismatch for argument " + to_string(i + 1) + " of \'" + $1->getValue()->getName() + "\'");
                                   }
                              }
                              if(curr[i]->getArray()) {
                                   print_error($1->getValue()->getStartLine(), "Type mismatch for argument " + to_string(i + 1) + " of \'" + $1->getValue()->getName() + "\'");
                              }
                         }
                    }
               }                         
               else {
                    print_error($2->getValue()->getStartLine(), "\'" + $2->getValue()->getName() + "\' redeclared as different kind of symbol");
               }
          }
          arg_type_list.clear();
       }
       | LPAREN expression RPAREN {
          log_rule("factor : LPAREN expression RPAREN");

          $$ = new ParseTree(new SymbolInfo("LPAREN expression RPAREN", "factor", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);

          $$->getValue()->setDataType($2->getValue()->getDataType());
       }
       | CONST_INT {
          log_rule("factor : CONST_INT");
          $$ = new ParseTree(new SymbolInfo("CONST_INT", "factor", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);

          $$->getValue()->setDataType("INT");
          if($1->getValue()->getName() == "0") {
               $$->getValue()->setIsZero(true);
          }
       }
       | CONST_FLOAT {
          log_rule("factor : CONST_FLOAT");

          $$ = new ParseTree(new SymbolInfo("CONST_FLOAT", "factor", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
          $$->addChild($1);

          $$->getValue()->setDataType("FLOAT");
       }
       | variable INCOP {
          log_rule("factor : variable INCOP");

          $$ = new ParseTree(new SymbolInfo("variable INCOP", "factor", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
          $$->addChild($1);
          $$->addChild($2);

          $$->getValue()->setDataType($1->getValue()->getDataType());
       }
       | variable DECOP {
          log_rule("factor : variable DECOP");
          
          $$ = new ParseTree(new SymbolInfo("variable DECOP", "factor", $1->getValue()->getStartLine(), $2->getValue()->getEndLine()));
          $$->addChild($1);
          $$->addChild($2);

          $$->getValue()->setDataType($1->getValue()->getDataType());
       }
       ;

argument_list : arguments {
                    log_rule("argument_list : arguments");

                    $$ = new ParseTree(new SymbolInfo("arguments", "argument_list", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                    $$->addChild($1);
                }
              |   {
                    log_rule("argument_list : ");

                    $$ = new ParseTree(new SymbolInfo("", "argument_list"));
              } // what to do with empty? 
              
              ;

arguments : arguments COMMA logic_expression {
                log_rule("arguments : arguments COMMA logic_expression");

                $$ = new ParseTree(new SymbolInfo("arguments COMMA logic_expression", "arguments", $1->getValue()->getStartLine(), $3->getValue()->getEndLine()));
                $$->addChild($1);
                $$->addChild($2);
                $$->addChild($3);

                arg_type_list.push_back($3->getValue());
            }
          | logic_expression {
                log_rule("arguments : logic_expression");

                $$ = new ParseTree(new SymbolInfo("logic_expression", "arguments", $1->getValue()->getStartLine(), $1->getValue()->getEndLine()));
                $$->addChild($1);

               $$->getValue()->setDataType($1->getValue()->getDataType());

               arg_type_list.push_back($1->getValue());
          }
          ;

%%

int main(int argc, char* argv[]) {
    FILE *fp = fopen(argv[1], "r");

    if(fp == NULL) {
        cout << "Cannot open input file\n";
        exit(1);
    }

    // open other files
    logout.open("log.txt");
    errorout.open("error.txt");
    parsetreeout.open("parsetree.txt");

    yyin = fp;
    yyparse();

    fclose(yyin);

    logout << "Total Lines: " << yylineno << "\n";
    logout << "Total Errors: " << parser_error_count << "\n";

    parsetree->getValue()->setTabsNeeded(0);
    parsetree->print();

    cout << "before freeing parsetree\n"; 
    parsetree->freeTree();
    cout << "freed parsetree successfully\n";
    delete parsetree;
    cout << "deleted parsetree successfully\n";
    delete table;
    cout << "deleted symbol table successfully\n";    
    
    // close other files
    logout.close();
    errorout.close();
    parsetreeout.close();
    return 0;
}