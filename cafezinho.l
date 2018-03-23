%{
#include <cstdio>
#include <string>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <algorithm>
#include "cafezinho.hpp"
#include "sintatico.hpp"

using namespace std;

int seen = 1;

extern void yyerror(char const *s);
%}

%%

";"				{ return(';'); }
"["				{ return('['); }
"]"				{ return(']'); }
","				{ return(','); }
"("				{ return('('); }
")"				{ return(')'); }
"{"				{ return('{'); }
"}"				{ return('}'); }
"="				{ return('='); }
"?"				{ return('?'); }
":"				{ return(':'); }
"=="			{ return(EQ); }
"!="			{ return(NE); }
"<"				{ return('<'); }
">"				{ return('>'); }
">="			{ return(GEQ); }
"<="			{ return(LEQ); }
"+"				{ return('+'); }
"-"				{ return('-'); }
"*"				{ return('*'); }
"/"				{ return('/'); }
"%"				{ return('%'); }
"!"				{ return('!'); }
"programa"		{ return(PROGRAMA); }
"car"			{ return(CAR); }
"int"			{ return(INT); }
"retorne"		{ return(RETORNE); }
"leia"			{ return(LEIA); }
"escreva"		{ return(ESCREVA); }
"novalinha"		{ return(NOVALINHA); }
"se"			{ return(SE); }
"entao"			{ return(ENTAO); }
"senao"			{ return(SENAO); }
"enquanto"		{ return(ENQUANTO); }
"execute"		{ return(EXECUTE); }
"ou"			{ return(OU); }
"e"				{ return(E); }

[a-zA-Z][a-zA-Z0-9]*	{ yylval.variable = new string(yytext); return(ID); }
[0-9]+					{ yylval.integer = atoi(yytext); return(INTCONST); }
['][a-zA-Z][']			{ yylval.character = string(yytext)[1]; return(CARCONST); }

\" {
	char ch;
	string tmp = "";
	for (ch = yyinput(); ch != '\"' && ch != '\n' && ch != EOF; ch = yyinput()) {
		tmp += ch;
	}
	if (ch == '\n') {
		yyerror(("cadeia de caracteres ocupa mais de uma linha :. linha " + to_string(seen)).c_str());
	} else if (ch == EOF) {
		yyerror(("cadeia de caracteres nao termina :. linha " + to_string(seen)).c_str());
	} else {
		yylval.variable = new string(tmp); return(STRING);
	}
}

"/*" {
	int tmp = seen;
	char pre = '-';
	char now = '-';
	for (now = yyinput();; now = yyinput()) {
		if (now == EOF) {
			seen = tmp;			
			yyerror(("comentario nao termina :. linha " + to_string(seen)).c_str());
			break;
		}
		if (now == '\n') {
			++seen;
		}
		if (pre == '*' && now == '/') {
			break;
		}
		pre = now;
	}
}

"\n"			{ ++seen; }
[ \t]			{ }
.				{ yyerror(("caractere invalido :. linha " + to_string(seen)).c_str()); }

%%

int yywrap() {
	return 1;
}
