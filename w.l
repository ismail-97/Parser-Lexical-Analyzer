%{
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	#include "node.h"
	void yyerror(char*);
	void set_info(char* str, char** type, char** name);
	void solve_it(struct record**, char*);
	int linenumber;

%}

integer 		[0-9]+
char			['].[']
string			["][^\n]*["]
T				int|char
ID				[a-zA-Z][_a-zA-Z0-9]*
assignment		"="|"+="|"-="|"*="|"/="|"%="
operator_1		"=="|"!="
operator_2		">"|"<"|">="|"<="
operator_3		[+-]
operator_4		[*/%]
operator_5		"++"|"--"
operator_6		[()\[\]]
special			[{}<>!.,&#]
WS				[ \t\n]
declaration	 	{T}[ \t\n]+{ID}
mult_declar 	{T}[ \t\n]+{ID}[ \t\n]*(,[ \t\n]*{ID}[ \t\n]*)+[;]
keywords		while|if|else|read|output|then
ch_keywords		readc|outputc
comment			"//"[^\n]*
main_fun_s		"int"{WS}+"main"{WS}*"("{WS}*")"{WS}*"{"
main_fun_f		"return"{WS}*({ID}|{integer}){WS}*";"{WS}*"}"
parameter_list	(int|char|void){WS}+{ID}{WS}*[(]{WS}*({T}{WS}+{ID})?{WS}*(,{WS}*{T}{WS}+{ID}{WS}*)*[)]

%% 

#include[ \t]*[<][ \t]*{ID}[ \t]*([.][ \t]*{ID}[ \t]*)*[>]	;
#include[ \t]*["][ \t]*{ID}[ \t]*([.][ \t]*{ID}[ \t]*)*["]	;



exit						exit(1);

{T}							return Type;

{comment}					;

{parameter_list}			return arg_list;

{main_fun_s}				return main_f_start;


return						return Return;


{ch_keywords}				{
								if 		(yytext[0] == 'r') return Readc;
								else if (yytext[0] == 'o') return Outputc;
							}


{keywords}					{
								if 		(yytext[0] == 'w') return While;
								else if (yytext[0] == 'i') return If;
								else if (yytext[0] == 'e') return Else;
								else if (yytext[0] == 'r') return Read;
								else if (yytext[0] == 'o') return Output;
								else if (yytext[0] == 't') return then;
							}


{declaration}				{
								yylval.data = (struct record*)malloc(sizeof(struct record));
								set_info(yytext, &yylval.data->type, &yylval.data->name);
								if (yylval.data->type[0] == 'i')							
									yylval.data->i_val = 0;
								else 
									yylval.data->c_val = '\0'; 

								return type_ident;
							}


{mult_declar}				{ //printf("Multi Declaration.\n");
							solve_it(&yylval.data, yytext);

//							int i = 0; for (i = 0; i < yylval.data[0].i_val; ++i)
//							printf("(*data)[i].name: %s %s\n", yylval.data[i].type,yylval.data[i].name);

							// yylval.data is now an array of records, each element
							// has a name and the same type.
							// yylval.data[0].i_val shows how many elemnts in the array.

								return multi_type_ident;
							}


{ID}						{
								yylval.data = (struct record*)malloc(sizeof(struct record));
								yylval.data->name = strdup(yytext);
								yylval.data->type = "var";
								return ident;
							}


{assignment}				{
								//return assign_op;
								if(yytext[0] == '=') return assign;
								else return assign_op;
							}


{operator_1}				{
								if 		(yytext[0] == '=' && yytext[1] == '=') return equal;
								else if (yytext[0] == '!' && yytext[1] == '=') return not_equal;
							}


{operator_2}				{
								if 	(yytext[0] == '>' && yytext[1] == '=') return great_equal;
							else if (yytext[0] == '<' && yytext[1] == '=') return less_equal;
								else if (*yytext == '>') return great;
								else if (*yytext == '<') return less;

							}


{operator_3}				{
								if (*yytext == '+') return add;
								else return subtract;
							}


{operator_4}				{
								if 		(*yytext == '*') return multiply;
								else if (*yytext == '/') return divide;
								else return mod;
							}


{operator_5}				{
								if 		(yytext[0] == '+' && yytext[1] == '+') return increment;
								else if (yytext[0] == '-' && yytext[1] == '-') return decrement;
							}


{operator_6}				{
								if 		(*yytext == '(') return l_pranth;
								else if (*yytext == ')') return r_pranth;
								else if (*yytext == '[') return l_array;
								else if (*yytext == ']') return r_array;
							}

{integer}					{
								yylval.data = (struct record*)malloc(sizeof(struct record));
								yylval.data->i_val = atoi(yytext);
								yylval.data->type = "int_l";
								yylval.data->name = "$int";
								return int_l;
							}


{char}						{
								yylval.data = (struct record*)malloc(sizeof(struct record));
								yylval.data->type = "char_l";
								yylval.data->name = "$char";
								return char_l ;
							}

{string}					{
								yylval.data = (struct record*)malloc(sizeof(struct record));
								yylval.data->type = "string_l";
								yylval.data->name = strdup(yytext);
								return string_l ;
							}

{special}					{
								if (yytext[0] == '{') return l_brkt;
								else if (yytext[0] == '}') return r_brkt;
							}


";"							return semi;



{WS}					{ if (*yytext == '\n') linenumber++;}






%%


int yywrap(void) { return 1; }

void set_info(char* str, char** type, char** name)
{
	int i = 0, j = 0;
	char my_name[500];
	*name = (char*)malloc(500);
	if (str[0] == 'i')
		*type = "int";
	else
		*type = "char";

	for (i = 4; str[i] != '\0'; ++i)
	{
		if(str[i] == ' ') continue;
		my_name[j] = str[i];
		++j;
	}
	strcpy(*name, my_name);
	//printf("str: %s\n", str);
	//printf("my_type: %s\n", *type);
	//printf("my_name: %s\n", *name);
}

void solve_it(struct record** data, char* str)
{

	int i = 0, j = 0, name_count = 0 , o=0;

	char my_name[100][100];
	char type[5], temp[100];
//	*name = (char*)malloc(500);

	if (str[0] == 'i')
		strcpy(type, "int");
	else
		strcpy(type, "char");

	for (i = 4; str[i] != '\0'; ++i)
	{	
		
		if(str[i] == ' ') continue;

		for (j = 0; str[i + j] != ',' && str[i + j] != ';'; ++j)
		{
			if(str[i + j] == ' ') {o++; continue;}
			temp[j] = str[i + j];
		}
		temp[j-o] = '\0'; // it should be temp [ j
		o = 0;
		i += j;
		strcpy(my_name[name_count++], temp);
//		printf("str: %s\t my_name[name_count]: %s\n", temp, my_name[name_count]);
//		printf("size: %ld, j: %d\n", strlen(temp), j);
	}

	struct record* hold = (struct record*)malloc(sizeof(struct record) * name_count);
	if(!data) yyerror("Can't allocate memory for data in solve_it!\n");
	for (i = 0; i < name_count; ++i)
	{
		hold[i].type = (char*)malloc(strlen(type));
		hold[i].name = (char*)malloc(strlen(my_name[i]));

		strcpy(hold[i].name, my_name[i]);
		strcpy(hold[i].type, type);
//		hold[i].type = type;
//		printf("hold[i].type: %s\ttpye: %s\n", hold[i].type, type);
	}
	hold[0].i_val = name_count;
	hold[0].c_val = type[0];
	*data = hold;
//printf("--------\n");

//	for (i = 0; i < name_count; ++i)
//		printf("(*data)[i].name: %s %s\n", (*data)[i].type,(*data)[i].name);


}
