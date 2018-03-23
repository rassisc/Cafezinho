%{
#include <map>
#include <set>
#include <vector>
#include <cstdio>
#include <string>
#include <cstring>
#include <cassert>
#include <cstdlib>
#include <iostream>
#include <algorithm>
#include "cafezinho.hpp"

using namespace std;

#define X first
#define Y second

extern int seen;
extern int yylex();
extern FILE* yyin;
void yyerror(char const *s);
int check(int scope, node *root, node_type expected);
%}

%union {
	int integer;
	char character;
	std::string *variable;
	node *vertex;
};

%start Programa

%token <variable> ID
%token <int> INTCONST
%token PROGRAMA
%token INT
%token CAR
%token RETORNE
%token LEIA
%token ESCREVA
%token <variable> STRING
%token NOVALINHA
%token SE
%token ENTAO
%token SENAO
%token ENQUANTO
%token EXECUTE
%token OU
%token E
%token EQ
%token NE
%token GEQ
%token LEQ
%token <char> CARCONST

%type <vertex> Programa
%type <vertex> DeclFuncVar
%type <vertex> DeclProg
%type <vertex> DeclVar
%type <vertex> DeclFunc
%type <vertex> ListaParametros
%type <vertex> ListaParametrosCont
%type <vertex> Bloco
%type <vertex> ListaDeclVar
%type <vertex> Tipo
%type <vertex> ListaComando
%type <vertex> Comando
%type <vertex> Expr
%type <vertex> AssignExpr
%type <vertex> CondExpr
%type <vertex> OrExpr
%type <vertex> AndExpr
%type <vertex> EqExpr
%type <vertex> DesigExpr
%type <vertex> AddExpr
%type <vertex> MulExpr
%type <vertex> UnExpr
%type <vertex> LValueExpr
%type <vertex> PrimExpr
%type <vertex> ListExpr

%%

Programa :
	DeclFuncVar DeclProg {
		$$ = new node(seen, "", declarations);
		$$->children.push_back($1);
		$$->children.push_back($2);
		check(0, $$, unknown);	
	};

DeclFuncVar :
	Tipo ID DeclVar ';' DeclFuncVar {
		$$ = new node(seen, "", declarations);
		$$->children.push_back(new node($1->at, *$2, $1->type));
		for (int i = 0; i < $3->children.size(); i++) {
			node_type tmp = $3->children[i]->type;
			tmp = (tmp == unknown) ? $1->type : ($1->type == integer ? integer_array : character_array);
			$$->children.push_back(new node($3->children[i]->at, $3->children[i]->name, tmp));
		}
		for (int i = 0; i < $5->children.size(); i++) {
			$$->children.push_back($5->children[i]);
		}
	} |	Tipo ID '[' INTCONST ']' DeclVar ';' DeclFuncVar {
		$$ = new node(seen, "", declarations);
		node_type tmp = $1->type == integer ? integer_array : character_array;
		$$->children.push_back(new node($1->at, *$2, tmp));
		for (int i = 0; i < $6->children.size(); i++) {
			tmp = $6->children[i]->type;
			tmp = (tmp == unknown) ? $1->type : ($1->type == integer ? integer_array : character_array);
			$$->children.push_back(new node($6->children[i]->at, $6->children[i]->name, tmp));
		}
		for (int i = 0; i < $8->children.size(); i++) {
			$$->children.push_back($8->children[i]);
		}
	} |	Tipo ID DeclFunc DeclFuncVar {
		$$ = new node(seen, "", declarations);
		$3->type = ($1->type == integer ? integer_method : character_method);
		$3->name = *$2;
 		$$->children.push_back($3);
		for (int i = 0; i < $4->children.size(); i++) {
			$$->children.push_back($4->children[i]);
		}
	} | {
		$$ = new node(seen, "", declarations);
	};

DeclProg :
	PROGRAMA Bloco {
		$$ = $2;	
	};

DeclVar :
	',' ID DeclVar {
		$$ = new node(seen, "", variable_list);
		$$->children.push_back(new node(seen, *$2, unknown));
		for (int i = 0; i < $3->children.size(); i++) {
			$$->children.push_back($3->children[i]);
		}
	} | ',' ID '[' INTCONST ']' DeclVar {
		$$ = new node(seen, "", variable_list);
		$$->children.push_back(new node(seen, *$2, unknown_array));
		for (int i = 0; i < $6->children.size(); i++) {
			$$->children.push_back($6->children[i]);
		}
	} |	{
		$$ = new node(seen, "", variable_list);
	};

DeclFunc :
	'(' ListaParametros ')' Bloco {
		$$ = new node(seen, "", unknown);
		$$->children.push_back($2);
		$$->children.push_back($4);
	};

ListaParametros :
	{
		$$ = new node(seen, "", parameter_list);
	} |	ListaParametrosCont { 
		$$ = $1;
	};

ListaParametrosCont :
	Tipo ID {
		$$ = new node(seen, "", parameter_list);
		$$->children.push_back(new node($1->at, *$2, $1->type));
	} |	Tipo ID '['']' {
		$$ = new node(seen, "", parameter_list);
		$$->children.push_back(new node($1->at, *$2, $1->type == integer ? integer_array : character_array));
	} |	Tipo ID ',' ListaParametrosCont {
		$$ = new node(seen, "", parameter_list);
		$$->children.push_back(new node($1->at, *$2, $1->type));
		for (int i = 0; i < $4->children.size(); i++) {
			$$->children.push_back($4->children[i]);
		}
	} |	Tipo ID '['']' ',' ListaParametrosCont {
		$$ = new node(seen, "", parameter_list);
		$$->children.push_back(new node($1->at, *$2, $1->type == integer ? integer_array : character_array));
		for (int i = 0; i < $6->children.size(); i++) {
			$$->children.push_back($6->children[i]);
		}
	};

Bloco :
	'{' ListaDeclVar ListaComando '}' {
		$$ = new node(seen, "", block);
		$$->children.push_back($2);
		$$->children.push_back($3);
	} |	'{' ListaDeclVar '}' {
		$$ = new node(seen, "", block);
		$$->children.push_back($2);
	};

ListaDeclVar :
	{
		$$ = new node(seen, "", variable_list);
	} |	Tipo ID DeclVar ';' ListaDeclVar {
		$$ = new node(seen, "", variable_list);
		$$->children.push_back(new node($1->at, *$2, $1->type));
		for (int i = 0; i < $3->children.size(); i++) {
			node_type tmp = $3->children[i]->type;
			tmp = (tmp == unknown) ? $1->type : ($1->type == integer ? integer_array : character_array);
			$$->children.push_back(new node($3->children[i]->at, $3->children[i]->name, tmp));
		}
		for (int i = 0; i < $5->children.size(); i++) {
			$$->children.push_back($5->children[i]);
		}
	} |	Tipo ID '[' INTCONST ']' DeclVar ';' ListaDeclVar {
		$$ = new node(seen, "", variable_list);
		node_type tmp = $1->type == integer ? integer_array : character_array;
		$$->children.push_back(new node($1->at, *$2, tmp));
		for (int i = 0; i < $6->children.size(); i++) {
			tmp = $6->children[i]->type;
			tmp = (tmp == unknown) ? $1->type : ($1->type == integer ? integer_array : character_array);
			$$->children.push_back(new node($6->children[i]->at, $6->children[i]->name, tmp));
		}
		for (int i = 0; i < $8->children.size(); i++) {
			$$->children.push_back($8->children[i]);
		}
	};

Tipo :
	INT {
		$$ = new node(seen, "", integer);
	} |	CAR {
		$$ = new node(seen, "", character);
	};

ListaComando :
	Comando {
		$$ = new node(seen, "", statements);
		$$->children.push_back($1);		
	} |	Comando ListaComando {
		$$ = new node(seen, "", statements);
		$$->children.push_back($1);
		for (int i = 0; i < $2->children.size(); i++) {
			$$->children.push_back($2->children[i]);
		}
	};

Comando :
	';' {
		$$ = new node(seen, "", statements);
	} |	Expr ';' {
		$$ = $1;
	} |	RETORNE Expr ';' {
		$$ = new node(seen, "", returns);
		$$->children.push_back($2);
	} |	LEIA LValueExpr ';' {
		$$ = $2;
	} |	ESCREVA Expr ';' {
		$$ = $2;
	} |	ESCREVA STRING ';' {
		$$ = new node(seen, "", statements);
	} |	NOVALINHA ';' {
		$$ = new node(seen, "", statements);
	} |	SE '(' Expr ')' ENTAO Comando {
		$$ = new node(seen, "", if_while);
		$$->children.push_back($3);
		$$->children.push_back($6);
	} |	SE '(' Expr ')' ENTAO Comando SENAO Comando {
		$$ = new node(seen, "", if_while);
		$$->children.push_back($3);
		$$->children.push_back($6);
		$$->children.push_back($8);
	} |	ENQUANTO '(' Expr ')' EXECUTE Comando {
		$$ = new node(seen, "", if_while);
		$$->children.push_back($3);
		$$->children.push_back($6);
	} |	Bloco {
		$$ = $1;
	};

Expr :
	AssignExpr { 
		$$ = $1;
	};

AssignExpr :
	CondExpr { 
		$$ = $1;
	} |	LValueExpr '=' AssignExpr {
		$$ = new node(seen, "", assignment);
		$$->children.push_back($1);
		$$->children.push_back($3);
	};

CondExpr :
	OrExpr { 
		$$ = $1;
	} |	OrExpr '?' Expr ':' CondExpr {
		$$ = new node(seen, "", if_while);
		$$->children.push_back($1);
		$$->children.push_back($3);
		$$->children.push_back($5);
	};

OrExpr :
	OrExpr OU AndExpr {
		$$ = new node(seen, "", logical_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} |	AndExpr { 
		$$ = $1;
	};

AndExpr :
	AndExpr E EqExpr {
		$$ = new node(seen, "", logical_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} |	EqExpr { 
		$$ = $1;
	};

EqExpr :
	EqExpr EQ DesigExpr {
		$$ = new node(seen, "", relational_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} |	EqExpr NE DesigExpr {
		$$ = new node(seen, "", relational_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} | DesigExpr {
 		$$ = $1;
	};

DesigExpr :
	DesigExpr '<' AddExpr {
		$$ = new node(seen, "", relational_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} | DesigExpr '>' AddExpr {
		$$ = new node(seen, "", relational_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} |	DesigExpr GEQ AddExpr {
		$$ = new node(seen, "", relational_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} |	DesigExpr LEQ AddExpr {
		$$ = new node(seen, "", relational_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);	
	} |	AddExpr { 
		$$ = $1;
	};

AddExpr :
	AddExpr '+' MulExpr {
		$$ = new node(seen, "", arithmetic_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} | AddExpr '-' MulExpr {
		$$ = new node(seen, "", arithmetic_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} | MulExpr { 
		$$ = $1;
	};

MulExpr :
	MulExpr '*' UnExpr {
		$$ = new node(seen, "", arithmetic_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} | MulExpr '/' UnExpr {
		$$ = new node(seen, "", arithmetic_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} |	MulExpr '%' UnExpr {
		$$ = new node(seen, "", arithmetic_operator);
		$$->children.push_back($1);
		$$->children.push_back($3);
	} |	UnExpr { 
		$$ = $1;
	};

UnExpr :
	'-'PrimExpr {
		$$ = new node(seen, "", arithmetic_operator);
		$$->children.push_back($2);
	} | '!'PrimExpr {
		$$ = new node(seen, "", logical_operator);
		$$->children.push_back($2);
	} |	PrimExpr { 
		$$ = $1;
	};

LValueExpr :
	ID '[' Expr ']' {
		$$ = new node(seen, *$1, single);
	} |	ID {
		$$ = new node(seen, *$1, any);
	};

PrimExpr :
	ID '(' ListExpr ')' {
		$$ = new node(seen, *$1, invocation);
		$$->children = $3->children;
	} |	ID '(' ')' {
		$$ = new node(seen, *$1, invocation);
	} |	ID '[' Expr ']' {
		$$ = new node(seen, *$1, single);
	} |	ID {
		$$ = new node(seen, *$1, any);
	} |	CARCONST {
		$$ = new node(seen, "", character);
	} |	INTCONST {
		$$ = new node(seen, "", integer);
	} |	'(' Expr ')' { 
		$$ = $2;
	};

ListExpr :
	AssignExpr {
		$$ = new node(seen, "", parameter_list);
		$$->children.push_back($1);
	} |	ListExpr ',' AssignExpr {
		$$ = $1;
		$$->children.push_back($3);
	};

%%

int scope = 0;
map < string, vector <int> > params;
map < int, map < string, pair <int, int> > > table;

void yyerror(char const *s) {
	printf("erro: %s", s);
	if (strcmp(s, "syntax error") == 0) {
		printf(" :. linha %d", seen);
	}
	puts("");
	exit(1);
}

bool valid(int val) {
	return val == integer || val == character || val == integer_array || val == character_array;
}

string get(int where) {
	return ":. linha " + to_string(where);
}

int check(int now, node *root, node_type expected) {
	if (root->name != "" && (root->type == integer || root->type == integer_array)) {
		if (table[now].count(root->name) != 0 && table[now][root->name].X == now) {
			string e = "variavel " + root->name + " ja declarada neste escopo " + get(root->at);
			yyerror(e.c_str());
		}
		table[now][root->name] = make_pair(now, root->type);
	} else if (root->name != "" && (root->type == character || root->type == character_array)) {
		if (table[now].count(root->name) != 0 && table[now][root->name].X == now) {
			string e = "variavel " + root->name + " ja declarada neste escopo " + get(root->at);
			yyerror(e.c_str());
		}
		table[now][root->name] = make_pair(now, root->type);
	} else if (root->type == integer_method || root->type == character_method) {
		int tmp = ++scope;
		if (table[now].count(root->name) != 0 && table[now][root->name].X == now) {
			string e = "nome de funcao " + root->name + " ja declarado neste escopo " + get(root->at);
			yyerror(e.c_str());
		}
		table[now][root->name] = make_pair(now, root->type);
		table[tmp] = table[now];
		assert((int) root->children.size() == 2);
		vector <int> all;
		for (int i = 0; i < root->children[0]->children.size(); i++) {
			all.push_back(root->children[0]->children[i]->type);
		}
		params[root->name] = all;
		for (int i = 0; i < 2; i++) {
			for (int j = 0; j < root->children[i]->children.size(); j++) {
				check(tmp, root->children[i]->children[j], root->type == integer_method ? integer : character);
			}
		}
		table[tmp].clear();
	} else if (root->type == variable_list) {
		for (int i = 0; i < root->children.size(); i++) {
			check(now, root->children[i], expected);
		}
	} else if (root->type == block) {
		int tmp = ++scope;
		table[tmp] = table[now];
		for (int i = 0; i < root->children.size(); i++) {
			check(tmp, root->children[i], expected);
		}
		table[tmp].clear();
	} else if (root->type == declarations) {
		for (int i = 0; i < root->children.size(); i++) {
			check(now, root->children[i], expected);
		}
	} else if (root->type == statements) {
		for (int i = 0; i < root->children.size(); i++) {
			check(now, root->children[i], expected);
		}
	} else if (root->type == any) {
		if (table[now].count(root->name) == 0) {
			string e = "variavel " + root->name + " nao declarada neste escopo " + get(root->at);
			yyerror(e.c_str());
		}
		int tmp = table[now][root->name].Y;
		if (tmp == integer_method || tmp == character_method) {
			string e = root->name + " esperava variavel mas encontrou nome de funcao " + get(root->at);
			yyerror(e.c_str());
		}
		return table[now][root->name].Y;
	} else if (root->type == single) {
		if (table[now].count(root->name) == 0) {
			string e = "variavel " + root->name + " nao declarada neste escopo " + get(root->at);
			yyerror(e.c_str());
		}
		int tmp = table[now][root->name].Y;
		if (tmp != integer_array && tmp != character_array) {
			string e = "variavel " + root->name + " nao corresponde a um vetor " + get(root->at);
			yyerror(e.c_str());
		}
		return table[now][root->name].Y == integer_array ? integer : character;
	} else if (root->type == if_while) {
		for (int i = 0; i < root->children.size(); i++) {
			check(now, root->children[i], expected);
		}
	} else if (root->type == returns) {
		assert((int) root->children.size() == 1);
		int u = check(now, root->children[0], expected);
		assert(valid(u));
		if (u != expected) {
			string e = "retorno de funcao tem tipo diferente do esperado " + get(root->at);
			yyerror(e.c_str());
		}
	} else if (root->type == assignment) {
		assert((int) root->children.size() == 2);
		int u = check(now, root->children[0], expected);
		int v = check(now, root->children[1], expected);
		assert(valid(u));
		assert(valid(v));
		if (u != v) {
			string e = "atribuicao entre tipos distintos " + get(root->at);
			yyerror(e.c_str());
		}
		return u;
	} else if (root->type == relational_operator) {
		assert((int) root->children.size() == 2);
		int u = check(now, root->children[0], expected);
		int v = check(now, root->children[1], expected);
		assert(valid(u));
		assert(valid(v));
		if (u != v) {
			string e = "operacao relacional entre tipos distintos " + get(root->at);
			yyerror(e.c_str());
		}
		return integer;
	} else if (root->type == arithmetic_operator) {
		if (root->children.size() == 2) {
			int u = check(now, root->children[0], expected);
			int v = check(now, root->children[1], expected);
			assert(valid(u));
			assert(valid(v));
			if (u != v) {
				string e = "operacao aritmetica entre tipos distintos " + get(root->at);
				yyerror(e.c_str());
			}
		}
		for (int i = 0; i < root->children.size(); i++) {
			int u = check(now, root->children[0], expected);
			assert(valid(u));
			if (u != integer) {
				string e = "operador aritmetico aplicado em expressao de tipo diferente de int " + get(root->at);
				yyerror(e.c_str());
			}			
		}
		return integer;
	} else if (root->type == logical_operator) {
		if (root->children.size() == 2) {
			int u = check(now, root->children[0], expected);
			int v = check(now, root->children[1], expected);
			assert(valid(u));
			assert(valid(v));
			if (u != v) {
				string e = "operacao logica entre tipos distintos " + get(root->at);
				yyerror(e.c_str());
			}
		}
		return integer;
	} else if (root->type == invocation) {
		if (table[now].count(root->name) == 0) {
			string e = "funcao de nome " + root->name + " inexistente " + get(root->at);
			yyerror(e.c_str());
		}
		int tmp = table[now][root->name].Y;
		if (tmp != integer_method && tmp != character_method) {
			string e = root->name + " nao corresponde a uma funcao declarada " + get(root->at);
			yyerror(e.c_str());
		}
		if (params[root->name].size() != root->children.size()) {
			string e = "funcao " + root->name + " chamada com numero de parametros incorreto " + get(root->at);
			yyerror(e.c_str());
		}
		for (int i = 0; i < root->children.size(); i++) {
			int u = check(now, root->children[i], expected);
			assert(valid(u));
			if (u != params[root->name][i]) {
				string e = "funcao " + root->name + " chamada com parametro de tipo distinto do esperado " + get(root->at);
				yyerror(e.c_str());
			}
		}
		return tmp == integer_method ? integer : character;
	} else if (root->type == integer || root->type == character) {
		return root->type;
	}
	return -1;
}

int main(int argc, char *argv[]) {

	if (argc != 2) {
		yyerror("MODO DE USO: ./cafezinho filename");
	} else {
		FILE *file = fopen(argv[1], "r");
		if (file == NULL) {
			yyerror("FALHA AO ABRIR ARQUIVO");
		}
		yyin = file;
		yyparse();
		puts("analise concluida :. nenhum erro sintatico ou semantico encontrado");
	}

	return 0;

}
