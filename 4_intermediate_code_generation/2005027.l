%option noyywrap
%option yylineno

%x CHAR_LITERAL
%x STRING_LITERAL
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT
%s COUNT_INDENTATION

%{
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
using namespace std;

#include "2005027SymbolTable.h"
#include "2005027parser.h"

#include "y.tab.h"

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;

int error_count = 0;
int warning_count = 0;

bool char_found = 0;

string log_str = "";
string token_str = "";
bool multi_char_char = false;
bool multi_line_string = false;

string log_single_line_comment = "";
string log_multi_line_comment = "";

int start_line;

int tab_needed = 0;
int tab_found = 0;
int space_found = 0;
bool indent_ended = false;

// SymbolTable* symbol_table = new SymbolTable(10);

extern ofstream logout;
extern int total_line;
extern bool func_def_started;
extern SymbolTable * table;

void end_indentation() {
    if(!indent_ended) {
            indent_ended = true;
            // logout << "Line#" << yylineno << "tab found " << tab_found << ", space found " << space_found << ", tab expected " << tab_needed << "\n";

            if(tab_found != tab_needed) {
                logout << "Line# " << yylineno << ": warning, " << tab_needed << " of tabs needed but got " << tab_found << " tabs.\n";
                warning_count++;
            }
            else if(space_found > 0) {
                logout << "Line# " << yylineno << ": Warning, tab requrired but got space.\n";
                warning_count++;
            }
            BEGIN 0;
        }
}
void reset_indentation() {
    tab_found = 0;
    space_found = 0;
    indent_ended = false;
}

void print_summary() {
    logout << "Total lines: " << yylineno << "\n";
    logout << "Total errors: " << error_count << "\n";
    logout << "Total warnings: " << warning_count << "\n";
}

%}

digit [0-9]

%%


"if" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <IF> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("if", "IF", yylineno));

    return IF;
}
"for" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <FOR> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("for", "FOR", yylineno));

    return FOR;
}
"do" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <DO> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("DO", "KEYWORD", yylineno));

    return DO;
}
"int" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <INT> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("int", "INT", yylineno));

    return INT;
}
"float" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <FLOAT> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("float", "FLOAT", yylineno));

    return FLOAT;
}
"void" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <VOID> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("void", "VOID", yylineno));

    return VOID;
}
"switch" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <SWITCH> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("SWITCH", "KEYWORD", yylineno));

    return SWITCH;
}
"default" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <DEFAULT> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("DEFAULT", "KEYWORD", yylineno));

    return DEFAULT;
}
"else" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <ELSE> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("else", "ELSE", yylineno));

    return ELSE;
}
"while" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <WHILE> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("while", "WHILE", yylineno));

    return WHILE;
}
"break" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <BREAK> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("BREAK", "KEYWORD", yylineno));

    return BREAK;
}
"char" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <CHAR> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("CHAR", "KEYWORD", yylineno));

    return CHAR;
}
"double" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <DOUBLE> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("DOUBLE", "KEYWORD", yylineno));

    return DOUBLE;
}
"return" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <RETURN> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("return", "RETURN", yylineno));

    return RETURN;
}
"case" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <CASE> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("CASE", "KEYWORD", yylineno));

    return CASE;
}
"continue" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <CONTINUE> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("CONTINUE", "KEYWORD", yylineno));

    return CONTINUE;
}
"println" {
    end_indentation();
    logout << "Line#" << yylineno << ": Token <PRINTLN> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("println", "PRINTLN", yylineno));

    return PRINTLN;
}
\' {
    end_indentation();
    
    BEGIN CHAR_LITERAL;
    char_found = 0;
    log_str = "";
    multi_char_char = false;
}
<CHAR_LITERAL>' {
    BEGIN INITIAL;

    if(char_found == 0) {
        log_str = "\'" + log_str + "\'";
        logout << "Error at line# " << yylineno << ": EMPTY_CONST_CHAR \'\'\n";
        error_count++;
    }
    else if (multi_char_char) {
        log_str = "\'" + log_str + "\'";
        logout << "Error at line# " << yylineno << ": MULTICHAR_CONST_CHAR " << log_str << "\n";
        error_count++;
    }
    else if(log_str.size() == 1 && log_str.at(0) == '\\') {
        log_str = "\'" + log_str + "\'";
        logout << "Error at line# " << yylineno << ": UNFINISHED_CONST_CHAR " << log_str << "\n";
        error_count++;

        BEGIN INITIAL;
    }
    else if(char_found) {
        logout << "Line# " << yylineno << ": Token <CONST_CHAR> Lexeme " << log_str << " found\n";
        yylval.info = new ParseTree(new SymbolInfo(log_str, "CONST_CHAR", yylineno));

        return CONST_CHAR;
    }
}
<CHAR_LITERAL>\\\'/' {
    log_str += "\'";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\\"/' {
    log_str += "\"";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\n/' {
    log_str += "\n";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\t/' {
    log_str += "\t";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\\\/' {
    log_str += "\\";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\a/' {
    log_str += "\a";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\f/' {
    log_str += "\f";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\r/' {
    log_str += "\r";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\b/' {
    log_str += "\b";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\v/' {
    log_str += "\v";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\0/' {
    log_str += "\0";
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
}
<CHAR_LITERAL>\\./' {
    log_str += yytext;
    logout << "Error at line# " << yylineno << ": UNRECOGNIZED_CHAR " << log_str << "\n";
    error_count ++;

    BEGIN INITIAL;
}
<CHAR_LITERAL>\\./[\r\n] {
    log_str += yytext;
    log_str = "\'" + log_str;
    logout << "Error at line# " << yylineno << ": UNFINISHED_CHAR " << log_str << "\n";
    error_count++;

    BEGIN COUNT_INDENTATION;
}
<CHAR_LITERAL><<EOF>> {
    logout << "Error at line# " << yylineno << ": UNFINISHED_CHAR " << log_str << "\n";
    error_count++;
    // symbol_table->printAllScopeTable();
    print_summary();
    // delete symbol_table;
    total_line = yylineno;
    return 0;
}
<CHAR_LITERAL>. {
    log_str += yytext;
    if(char_found == 0) {
        char_found = 1;
    }
    else {
        multi_char_char = true;
    }
    printf("unfinished char %c, yylineno %d\n", yytext[0], yylineno);
}
<CHAR_LITERAL>[\r]?\n {
    log_str = "\'" + log_str;
    // cout << "unfinished char size " << log_str.size() << " " << yylineno << "\n";
    if(log_str.size() > 2) {
        logout << "Error at line# " << (yylineno - 1) << ": UNFINISHED_CONST_CHAR " << log_str[0] << log_str[1] << "\n";
    }
    else {        
        logout << "Error at line# " << (yylineno - 1) << ": UNFINISHED_CONST_CHAR " << log_str << "\n";
    }
    error_count++;
    if(multi_char_char) {
        // symbol_table->insert(log_str.c_str() + 2, "ID");
        // symbol_table->printAllScopeTable();
    }

    reset_indentation();
    BEGIN COUNT_INDENTATION;
}
[+-] {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <ADDOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "ADDOP", yylineno));

    return ADDOP;
}
[*%/] {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <MULOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "MULOP", yylineno));

    return MULOP;
}
"++" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <INCOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "INCOP", yylineno));

    return INCOP;
}
"--" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <DECOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "DECOP", yylineno));

    return DECOP;
}
"<"|"<="|">"|">="|"=="|"!=" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <RELOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "RELOP", yylineno));

    return RELOP;
}
"=" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <ASSIGNOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "ASSIGNOP", yylineno));

    return ASSIGNOP;
}
"&&"|"||" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <LOGICOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "LOGICOP", yylineno));

    return LOGICOP;
}
"&"|"|"|"^"|"<<"|">>" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <BITOP> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "BITOP", yylineno));

    return BITOP;
}
"!" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <NOT> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("!", "NOT", yylineno));

    return NOT;
}
"(" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <LPAREN> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("(", "LPAREN", yylineno));

    return LPAREN;
}
")" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <RPAREN> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(")", "RPAREN", yylineno));

    return RPAREN;
}
"{" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <LCURL> Lexeme " << yytext << " found\n";
    // symbol_table->enterScope();
    tab_needed++;
    yylval.info = new ParseTree(new SymbolInfo("{", "LCURL", yylineno));

    return LCURL;
}
"}" {
    tab_needed--;
    end_indentation();
    logout << "Line# " << yylineno << ": Token <RCURL> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("}", "RCURL", yylineno));
 
    return RCURL;
}
"[" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <LSQUARE> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("[", "LSQUARE", yylineno));

    return LSQUARE;
}
"]" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <RSQUARE> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo("]", "RSQUARE", yylineno));

    return RSQUARE;
}
"," {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <COMMA> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(",", "COMMA", yylineno));

    return COMMA;
}
";" {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <SEMICOLON> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(";", "SEMICOLON", yylineno));

    return SEMICOLON;
}
{digit}+ {
    end_indentation();
    
    yylval.info = new ParseTree(new SymbolInfo(yytext, "CONST_INT", yylineno));
    
    logout << "Line# " << yylineno << ": Token <CONST_INT> Lexeme " << yytext << " found\n";
    // cout << "const_int " << yytext << " " << yylval.info->getValue() << " allocated\n";
    return CONST_INT;
}
{digit}+E[+-]?{digit}+|{digit}*\.{digit}+(E[+-]?{digit}+)? {
    end_indentation();
    
    yylval.info = new ParseTree(new SymbolInfo(yytext, "CONST_FLOAT", yylineno));
    logout << "Line# " << yylineno << ": Token <CONST_FLOAT> Lexeme " << yytext << " found\n";
     
    return CONST_FLOAT;
}
{digit}*\.{digit}*(\.{digit}*)+(E[+-]?{digit}+)? {
    end_indentation();
    
    logout << "Error at line# " << yylineno << ": TOO_MANY_DECIMAL_POINTS " << yytext << "\n";
    error_count++;
}
{digit}*(\.{digit}+)?E[+-]?{digit}*(\.{digit}*)+ {
    end_indentation();
    
    logout << "Error at line# " << yylineno << ": ILLFORMED_NUMBER " << yytext << "\n";
    error_count++;
}
{digit}+(\.{digit}+(E[+-]?{digit}+)?)?[_a-zA-Z]+ {
    end_indentation();
    
    logout << "Error at line# " << yylineno << ": INVALID_ID_SUFFIX_NUM_PREFIX " << yytext << "\n";
    error_count++;
}
[_a-zA-Z][_a-zA-Z0-9]* {
    end_indentation();
    logout << "Line# " << yylineno << ": Token <ID> Lexeme " << yytext << " found\n";
    yylval.info = new ParseTree(new SymbolInfo(yytext, "ID", yylineno));

    return ID;
    // if(symbol_table->insert(yytext, "ID")) {
    //     symbol_table->printAllScopeTable();
    // }  
    
}
\" {
    end_indentation();
    
    BEGIN STRING_LITERAL;
    log_str = "";
    token_str = "";
    multi_line_string = false;
    start_line = yylineno;
} 
<STRING_LITERAL>\" {
    BEGIN INITIAL;
    if(!multi_line_string) {
        // tokenout << "<SINGLE LINE STRING, " << token_str << ">\n";
        logout << "Line# " << start_line << ": Token <SINGLE LINE STRING> Lexeme \"" << log_str << "\" found\n";

    }
    else {
        // tokenout << "<MULTI LINE STRING, " << token_str << ">\n";
        logout << "Line# " << start_line << ": Token <MULTI LINE STRING> Lexeme \"" << log_str << "\" found\n";
    }
    multi_line_string = false;
}
<STRING_LITERAL>\n {
    int problem_line = yylineno - 1;   
    // cout << "found \\n at yyline " << yylineno << " " << log_str << "\n";
    log_str = "\"" + log_str;
    logout << "Error at line# " << problem_line << ": UNFINISHED_STRING " << log_str << "\n";
    error_count++;

    reset_indentation();
    BEGIN COUNT_INDENTATION;
}
<STRING_LITERAL>\\\' {
    token_str += "\'";
    log_str += yytext; 
}
<STRING_LITERAL>\\\" {
    token_str += "\"";
    log_str += yytext; 
}
<STRING_LITERAL>\\n {
    token_str += "\n";
    log_str += yytext; 
}
<STRING_LITERAL>\\t {
    token_str += "\t";
    log_str += yytext; 
}
<STRING_LITERAL>\\\\ {
    token_str += "\\";
    log_str += yytext; 
}
<STRING_LITERAL>\\a {
    token_str += "\a";
    log_str += yytext; 
}
<STRING_LITERAL>\\f {
    token_str += "\f";
    log_str += yytext; 
}
<STRING_LITERAL>\\r {
    token_str += "\r";
    log_str += yytext; 
}
<STRING_LITERAL>\\b {
    token_str += "\b";
    log_str += yytext; 
}
<STRING_LITERAL>\\v {
    token_str += "\v";
    log_str += yytext; 
}
<STRING_LITERAL>\\0 {
    token_str += "\0";
    log_str += yytext; 
}
<STRING_LITERAL>\\[\r]?\n {

    log_str += "\\\n";
    multi_line_string = true;

}
<STRING_LITERAL>. {
    log_str += yytext[0];
    token_str += yytext[0];
}
<STRING_LITERAL><<EOF>> {
    logout << "Error at line# " << yylineno << ": UNFINISHED_STRING " << log_str << "\n";
    error_count++;

    // symbol_table->printAllScopeTable();
    // print_summary();

    // delete symbol_table;
    total_line = yylineno;

    return 0;
}
\/\/ {
    indent_ended = true;
    
    BEGIN SINGLE_LINE_COMMENT;

    log_single_line_comment = "//";
    start_line = yylineno;
}
<SINGLE_LINE_COMMENT>[\r]?\n {
    printf("new line in single line comment %d\n", yylineno);
    logout << "Line# " << start_line << ": Token <SINGLE LINE COMMENT> Lexeme " << log_single_line_comment << " found\n";

    BEGIN INITIAL;
}
<SINGLE_LINE_COMMENT>\\\r[\n]? {
    printf("single line made multi-line by \\ %d\n", yylineno);
    log_single_line_comment += "\\\n";
}
<SINGLE_LINE_COMMENT><<EOF>> {
    logout << "Error at line# " << yylineno << ": UNFINISHED_COMMENT " << log_str << "\n";
    error_count++;

    // symbol_table->printAllScopeTable();
    // print_summary();

    // delete symbol_table;
    total_line = yylineno;
    return 0;
}
<SINGLE_LINE_COMMENT>. {
    log_single_line_comment += yytext;
}
\/\* {
    indent_ended = true;
    
    BEGIN MULTI_LINE_COMMENT;
    log_str = "/*";
    start_line = yylineno;
}
<MULTI_LINE_COMMENT>\*\/ {
    indent_ended = true;

    BEGIN INITIAL;
    log_str += "*/";
    logout << "Line# " << start_line << ": Token <MULTI LINE COMMENT> Lexeme " << log_str << " found\n" ;
    
}
<MULTI_LINE_COMMENT><<EOF>> {
    logout << "Error at line# " << yylineno << ": UNFINISHED_COMMENT " << log_str << "\n";
    error_count++;

    // symbol_table->printAllScopeTable();
    // print_summary();

    // delete symbol_table;
    total_line = yylineno;
    return 0;
}
<MULTI_LINE_COMMENT>[\r]?\n {
    log_str += "\n";
}
<MULTI_LINE_COMMENT>. {
    log_str += yytext;
}

<<EOF>> {
    // symbol_table->printAllScopeTable();
    // print_summary();

    // delete symbol_table;
    total_line = yylineno;
    return 0;
}
[\r]?\n {
    reset_indentation();
    BEGIN COUNT_INDENTATION;
}
<COUNT_INDENTATION>\t {
    tab_found++;
}
[ \t] {
    space_found++;
}
. {
    end_indentation();
    
    logout << "Error at line# " << yylineno << ": UNRECOGNIZED_CHAR " << yytext << "\n";
    // cout << "Error at line# " << yylineno << ": UNRECOGNIZED_CHAR " << toascii(yytext[0]) << "\n";
    error_count++;
}
%%

