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

ofstream tokenout;

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

SymbolTable* symbol_table = new SymbolTable(10);

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

%}

letter [a-zA-Z]
digit [0-9]

%%


"if" {
    end_indentation();

    tokenout << "<IF, if>\n";
    logout << "Line# " << yylineno << ": Token <IF> Lexeme " << yytext << " found\n";
}
"for" {
    end_indentation();

    tokenout << "<FOR, for>\n";
    logout << "Line# " << yylineno << ": Token <FOR> Lexeme " << yytext << " found\n";
}
"do" {
    end_indentation();
    
    tokenout << "<DO, do>\n";
    logout << "Line# " << yylineno << ": Token <DO> Lexeme " << yytext << " found\n";
}
"int" {
    end_indentation();
    
    tokenout << "<INT, int>\n";
    logout << "Line# " << yylineno << ": Token <INT> Lexeme " << yytext << " found\n";
}
"float" {
    end_indentation();
    
    tokenout << "<FLOAT, float>\n";
    logout << "Line# " << yylineno << ": Token <FLOAT> Lexeme " << yytext << " found\n";
}
"void" {
    end_indentation();
    
    tokenout << "<VOID, void>\n";
    logout << "Line# " << yylineno << ": Token <VOID> Lexeme " << yytext << " found\n";
}
"switch" {
    end_indentation();
    
    tokenout << "<SWITCH, switch>\n";
    logout << "Line# " << yylineno << ": Token <SWITCH> Lexeme " << yytext << " found\n";
}
"default" {
    end_indentation();
    
    tokenout << "<DEFAULT, default>\n";
    logout << "Line# " << yylineno << ": Token <DEFAULT> Lexeme " << yytext << " found\n";
}
"else" {
    end_indentation();
    
    tokenout << "<ELSE, else>\n";
    logout << "Line# " << yylineno << ": Token <ELSE> Lexeme " << yytext << " found\n";
}
"while" {
    end_indentation();
    
    tokenout << "<WHILE, while>\n";
    logout << "Line# " << yylineno << ": Token <WHILE> Lexeme " << yytext << " found\n";
}
"break" {
    end_indentation();
    
    tokenout << "<BREAK, break>\n";
    logout << "Line# " << yylineno << ": Token <BREAK> Lexeme " << yytext << " found\n";
}
"char" {
    end_indentation();
    
    tokenout << "<CHAR, char>\n";
    logout << "Line# " << yylineno << ": Token <CHAR> Lexeme " << yytext << " found\n";
}
"double" {
    end_indentation();
    
    tokenout << "<DOUBLE, double>\n";
    logout << "Line# " << yylineno << ": Token <DOUBLE> Lexeme " << yytext << " found\n";
}
"return" {
    end_indentation();
    
    tokenout << "<RETURN, return>\n";
    logout << "Line# " << yylineno << ": Token <RETURN> Lexeme " << yytext << " found\n";
}
"case" {
    end_indentation();
    
    tokenout << "<CASE, case>\n";
    logout << "Line# " << yylineno << ": Token <CASE> Lexeme " << yytext << " found\n";
}
"continue" {
    end_indentation();
    
    tokenout << "<CONTINUE, continue>\n";
    logout << "Line# " << yylineno << ": Token <CONTINUE> Lexeme " << yytext << " found\n";
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
        tokenout << "<CONST_CHAR, " << log_str << ">\n";
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
    symbol_table->printAllScopeTable();
    logout << "Total lines: " << yylineno << "\n";
    logout << "Total errors: " << error_count << "\n";
    logout << "Total warnings: " << warning_count << "\n";
    delete symbol_table;
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
    cout << "unfinished char size " << log_str.size() << " " << yylineno << "\n";
    if(log_str.size() > 2) {

        logout << "Error at line# " << (yylineno - 1) << ": UNFINISHED_CONST_CHAR " << log_str[0] << log_str[1] << "\n";
    }
    else {        
        logout << "Error at line# " << (yylineno - 1) << ": UNFINISHED_CONST_CHAR " << log_str << "\n";
    }
    error_count++;
    if(multi_char_char) {
        symbol_table->insert(log_str.c_str() + 2, "ID");
        symbol_table->printAllScopeTable();
    }

    reset_indentation();
    BEGIN COUNT_INDENTATION;
}
[+-] {
    end_indentation();
    
    tokenout << "<ADDOP, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <ADDOP> Lexeme " << yytext << " found\n";
}
[*/%] {
    end_indentation();
    
    tokenout << "<MULOP, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <MULOP> Lexeme " << yytext << " found\n";
}
"++"|"--" {
    end_indentation();
    
    tokenout << "<INCOP, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <INCOP> Lexeme " << yytext << " found\n";
}
"<"|"<="|">"|">="|"=="|"!=" {
    end_indentation();
    
    tokenout << "<RELOP, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <RELOP> Lexeme " << yytext << " found\n";
}
"=" {
    end_indentation();
    
    tokenout << "<ASSIGNOP, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <ASSIGNOP> Lexeme " << yytext << " found\n";
}
"&&"|"||" {
    end_indentation();
    
    tokenout << "<LOGICOP, "<< yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <LOGICOP> Lexeme " << yytext << " found\n";
}
"&"|"|"|"^"|"<<"|">>" {
    end_indentation();
    
    tokenout << "<BITOP, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <BITOP> Lexeme " << yytext << " found\n";
}
"!" {
    end_indentation();
    
    tokenout << "<NOT, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <NOT> Lexeme " << yytext << " found\n";
}
"(" {
    end_indentation();
    
    tokenout << "<LPAREN, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <LPAREN> Lexeme " << yytext << " found\n";
}
")" {
    end_indentation();
    
    tokenout << "<RPAREN, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <RPAREN> Lexeme " << yytext << " found\n";
}
"{" {
    end_indentation();
    
    tokenout << "<LCURL, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <LCURL> Lexeme " << yytext << " found\n";
    symbol_table->enterScope();
    tab_needed++;
}
"}" {
    tab_needed--;
    end_indentation();
    
    tokenout << "<RCURL, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <RCURL> Lexeme " << yytext << " found\n";
    symbol_table->exitScope();
}
"[" {
    end_indentation();
    
    tokenout << "<LSQUARE, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <LSQUARE> Lexeme " << yytext << " found\n";
}
"]" {
    end_indentation();
    
    tokenout << "<RSQUARE, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <RSQUARE> Lexeme " << yytext << " found\n";
}
"," {
    end_indentation();
    
    tokenout << "<COMMA, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <COMMA> Lexeme " << yytext << " found\n";
}
";" {
    end_indentation();
    
    tokenout << "<SEMICOLON, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <SEMICOLON> Lexeme " << yytext << " found\n";
}
[+-]?{digit}+ {
    end_indentation();
    
    if(yytext[0] == '+' || yytext[0] == '-') {
        tokenout << "<CONST_INT, " << yytext + 1 << ">\n";
    }
    else {
        tokenout << "<CONST_INT, " << yytext << ">\n";
    }
    logout << "Line# " << yylineno << ": Token <CONST_INT> Lexeme " << yytext << " found\n";
}
[+-]?{digit}+E[+-]?{digit}+|[+-]?{digit}*\.{digit}+(E[+-]?{digit}+)? {
    end_indentation();
    
    if(yytext[0] == '+' || yytext[0] == '-') {
        tokenout << "<CONST_FLOAT, " << yytext + 1 << ">\n";
    }
    else {
        tokenout << "<CONST_FLOAT, " << yytext << ">\n";
    }
    logout << "Line# " << yylineno << ": Token <CONST_FLOAT> Lexeme " << yytext << " found\n";
}
[+-]?{digit}*\.{digit}*(\.{digit}*)+(E[+-]?{digit}+)? {
    end_indentation();
    
    logout << "Error at line# " << yylineno << ": TOO_MANY_DECIMAL_POINTS " << yytext << "\n";
    error_count++;
}
[+-]?{digit}*(\.{digit}+)?E[+-]?{digit}*(\.{digit}*)+ {
    end_indentation();
    
    logout << "Error at line# " << yylineno << ": ILLFORMED_NUMBER " << yytext << "\n";
    error_count++;
}
[+-]?{digit}+(\.{digit}+(E[+-]?{digit}+)?)?[_a-zA-Z]+ {
    end_indentation();
    
    logout << "Error at line# " << yylineno << ": INVALID_ID_SUFFIX_NUM_PREFIX " << yytext << "\n";
    error_count++;
}
[_a-zA-Z][_a-zA-Z0-9]* {
    end_indentation();
    
    tokenout << "<ID, " << yytext << ">\n";
    logout << "Line# " << yylineno << ": Token <ID> Lexeme " << yytext << " found\n";
    if(symbol_table->insert(yytext, "ID")) {
        symbol_table->printAllScopeTable();
    }  
    
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
        tokenout << "<SINGLE LINE STRING, " << token_str << ">\n";
        logout << "Line# " << start_line << ": Token <SINGLE LINE STRING> Lexeme \"" << log_str << "\" found\n";

    }
    else {
        tokenout << "<MULTI LINE STRING, " << token_str << ">\n";
        logout << "Line# " << start_line << ": Token <MULTI LINE STRING> Lexeme \"" << log_str << "\" found\n";
    }
    multi_line_string = false;
}
<STRING_LITERAL>\n {
    int problem_line = yylineno - 1;   
    cout << "found \\n at yyline " << yylineno << " " << log_str << "\n";
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

    symbol_table->printAllScopeTable();
    logout << "Total lines: " << yylineno << "\n";
    logout << "Total errors: " << error_count << "\n";
    logout << "Total warnings: " << warning_count << "\n";
    delete symbol_table;
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

    symbol_table->printAllScopeTable();
    logout << "Total lines: " << yylineno << "\n";
    logout << "Total errors: " << error_count << "\n";
    logout << "Total warnings: " << warning_count << "\n";
    delete symbol_table;
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

    symbol_table->printAllScopeTable();
    logout << "Total lines: " << yylineno << "\n";
    logout << "Total errors: " << error_count << "\n";
    logout << "Total warnings: " << warning_count << "\n";
    delete symbol_table;
    return 0;
}
<MULTI_LINE_COMMENT>[\r]?\n {
    log_str += "\n";
}
<MULTI_LINE_COMMENT>. {
    log_str += yytext;
}

<<EOF>> {
    symbol_table->printAllScopeTable();
    logout << "Total lines: " << yylineno << "\n";
    logout << "Total errors: " << error_count << "\n";
    logout << "Total warnings: " << warning_count << "\n";
    delete symbol_table;
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
    cout << "Error at line# " << yylineno << ": UNRECOGNIZED_CHAR " << toascii(yytext[0]) << "\n";
    error_count++;
}
%%

int main(int argc, char* argv[]) {
    if(argc != 2) {
        printf("please provide input file name");
    }

    FILE *fin = fopen(argv[1],"r");
	if(fin == NULL){
		printf("Cannot open input file\n");
		return 0;
	}

    /* logout.open("2005027_log.txt"); */
    tokenout.open("2005027_token.txt");

    if(!logout.is_open()) {
        cout << "cannot open log file\n";
        return 0;
    }
    if(!tokenout.is_open()) {
        cout << "cannot open token file\n";
    }

    yyin = fin;
    yylineno = 1;
    yylex();
    fclose(yyin);
    return 0;
}