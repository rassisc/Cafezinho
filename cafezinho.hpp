#include <cstdio>
#include <vector>
#include <algorithm>

using namespace std;

typedef enum {
	any,	
	block,
	single,
	unknown,
	integer,
	returns,
	if_while,
	character,
	statements,
	invocation,
	assignment,
	declarations,
	unknown_array,
	integer_array,
	variable_list,
	parameter_list,
	integer_method,
	character_array,
	character_method,
	logical_operator,
	arithmetic_operator,
	relational_operator
} node_type;

struct Node {
	int at;
	string name;
	vector <Node*> children;
	node_type type;

	Node() {}

	Node(int _at, string _name, node_type _type) {
		at = _at;
		name = _name;
		type = _type;
	}
};

typedef struct Node node;
