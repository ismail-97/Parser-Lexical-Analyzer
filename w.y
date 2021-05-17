%{
	void yyerror(char *s);
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "node.h"
	int yylex(void);
	int is_keyword(char*);
	int error_flag = 0;   
	int linenumber = 2;

	char* add_strs(const char*, const char*);
	void get_types(char*, char*, char*, char*, char*, char*);
	char* err_used_name = " was declared before! Each variable mush have a unique name.";
	char* err_undeclared = " was not declared before! You must declare the variable\
 before using it.";
	char* err_diff_type = " of different data types is not allowed!";
	char* err_keyword = " is a keyword. A variable can't have a keyword as its name.";
	
%}

%name	 		parse
%union			{
					struct record* data;
				}

%start			program

%token			int_l char_l string_l Type ident semi type_ident multi_type_ident 
%token			int_t main_f_start main_f_end Return arg_list

//%token		assign add_assign sub_assign			//oper0
//%token		multi_assign divide_assign mod_assign	//oper0

%token			assign_op assign					//oper---
%token			equal not_equal						//oper1
%token			great great_equal less less_equal	//oper2
%token			add subtract						//oper3
%token			multiply divide mod 				//oper4
%token			increment decrement					//oper5
%token			l_array r_array l_pranth r_pranth	//oper6

%token			While If Else then					//comment_line comment_block preprocessor
%token			Read Readc Output Outputc
%token			l_brkt r_brkt


%right 			assign_op
%left			l_brkt r_brkt
%left			arg_list
%right			then Else
%left			equal not_equal
%left			great great_equal less less_equal
%left			add subtract
%left			multiply divide mod
%left			increment decrement
%left			l_array r_array l_pranth r_pranth

%nonassoc		Readc Read Output Outputc
%type<data>		stmt exp ident term type_ident expstmt multi_type_ident


// 							end of the FIRST section.
//----------------------------------------------------------------------------------


%%

program		:	declarations prototypes main_f
			;

declarations:	 
			|	declarations declaration
			;

prototypes	:
			|	prototypes prototype
			;

prototype	:	arg_list l_brkt stmts Return exp semi r_brkt
			;	

main_f	: main_f_start stmts Return exp semi r_brkt
		{

			char t4[10];
			if(!strcmp($4->type, "var"))
				strcpy(t4, get_type($4->name));
			else
				strcpy(t4, $4->type);
	
			//printf("t4: %s\n", t4);
			if (strcmp(t4, "int_l") && strcmp(t4, "int"))
				yyerror("Bad return in main function!");
		}
		;

stmts	:  
		| stmts stmt		{}
		;

stmt 	: semi				{}
		| expstmt			{}
		| iteration			{}
		| selection			{}
		| declaration		{}
//		| function_call		{}
	
		| Readc l_pranth ident r_pranth semi
		{
			if(!is_char($3->name))
				yyerror("readc reads only chars, do you mean read?");
		}

		| Outputc l_pranth ident r_pranth semi
		{
			if(!is_char($3->name))
				yyerror("Outputc prints only chars, do you mean output?");
		}


		| Read ident semi 
		{
			if(is_char($2->name))
				yyerror("read reads only ints, do you mean readc?");
		}

		| Output ident semi 
		{
			if(is_char($2->name))
				yyerror("Output prints only ints, do you mean outputc?");
			
		}

		| ident assign expstmt
		{
			if(!is_declared($1->name))	//printf("Yes, it is me :\n");
				 yyerror(add_strs($1->name, err_undeclared)); 

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
//			printf("t1: %s\tt3: %s\n", t1, t3);

			if (!strcmp(t1, "int_l") || !strcmp(t1, "char_l") || !strcmp(t1, "string_l"))
				yyerror("can't assign to a literal value");
			else if (!strcmp(t1, "int") && !strcmp(t3, "int_l"));
			else if (!strcmp(t1, "char") && !strcmp(t3, "char_l"));
			else if (strcmp(t1, t3))
				yyerror(add_strs("Assigning", err_diff_type));


		}

		| ident assign_op expstmt
		{
			if(!is_declared($1->name))
				 yyerror(strcat($1->name, err_undeclared));

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			//printf("t1: %s\tt3: %s\n", t1, t3);
			if (strcmp(t1, "int") || (strcmp(t3, "int") && strcmp(t3, "int_l")))
				yyerror("Bad assingment");

		}
		;

declaration	: type_ident semi		
			{
				if (is_keyword($1->name))	
					yyerror(add_strs($1->name, err_keyword));
				else if(is_declared($1->name))
					 yyerror(add_strs($1->name, err_used_name)); 
				else 
					push_back($1->name, $1->type);
			}
	
			| type_ident assign expstmt
			{
				if (is_keyword($1->name))	
					yyerror(add_strs($1->name, err_keyword));
				else if(is_declared($1->name))
					 yyerror(add_strs($1->name, err_used_name)); 
				else 
					push_back($1->name, $1->type);
	
				char t1[10], t3[10];
				get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
				//printf("t1: %s\tt3: %s\n", t1, t3);
		
				if (!strcmp(t1, "int_l") || !strcmp(t1, "char_l") || !strcmp(t1, "string_l"))
					yyerror("can't assign to a literal value");
				else if (!strcmp(t1, "int") && !strcmp(t3, "int_l"));
				else if (!strcmp(t1, "char") && !strcmp(t3, "char_l"));
				else if (strcmp(t1, t3))
					yyerror(add_strs("Assigning", err_diff_type));

			}		

			| type_ident assign_op expstmt
			{
				if (is_keyword($1->name))	
					yyerror(add_strs($1->name, err_keyword));
				else if(is_declared($1->name))
					 yyerror(add_strs($1->name, err_used_name)); 
				else 
					push_back($1->name, $1->type);

				char t1[10], t3[10];
				get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
				//printf("t1: %s\tt3: %s\n", t1, t3);
				if (strcmp(t1, "int") || (strcmp(t3, "int") && strcmp(t3, "int_l")))
					yyerror("Bad assingment");

			}

			| multi_type_ident 		
			{
//				printf("multi multi multi.\n");
				int i = 0;
//				printf("size: %d, type: %c\n", $1[0].i_val, $1[0].c_val);

				for (i = 0; i < $1->i_val; ++i)
				{
//printf("name: %s\ttype: %s length: %ld\n", $1[i].name, $1[i].type, strlen($1[i].name));
					if (is_keyword($1[i].name))	
						yyerror(add_strs($1[i].name, err_keyword));
					else if(is_declared($1[i].name))
						 yyerror(add_strs($1[i].name, err_used_name)); 
					else 
						push_back($1[i].name, $1[i].type);
//						push_back($1[i].name, ($1[0].c_val == 'i' ? "int" : "char") );
//					printf("namoo: %s\ttypoo:%s\n", $1[i].name, $1[i].type);
				}
			}
			
			;

expstmt : exp semi		{}
		;

iteration	:	While l_pranth exp r_pranth l_brkt stmts r_brkt
			|	While l_pranth exp r_pranth stmt 	
			;

selection	:	If l_pranth exp r_pranth then stmt 	
			|	If l_pranth exp r_pranth then l_brkt stmts r_brkt

			|	If l_pranth exp r_pranth then stmt Else stmt 
			|	If l_pranth exp r_pranth then stmt Else l_brkt stmts r_brkt

			|	If l_pranth exp r_pranth then l_brkt stmts r_brkt Else stmt
			|	If l_pranth exp r_pranth then l_brkt stmts r_brkt Else l_brkt stmts r_brkt
			;

exp 	: term
		| exp add term				
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("Addition is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			//printf("t1: %st3: %s\n", t1, t3);
			if(strcmp(t1, t3))
				yyerror(add_strs("Addition", err_diff_type));
		}

		| exp subtract term			
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("Subtraction is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Subtraction", err_diff_type));
		}

		| exp multiply term			
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("Multiplication is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Multiplication", err_diff_type));

		}

		| exp divide term			
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("Division is not defined for char.");
			
			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Division", err_diff_type));
		}

		| exp mod term				
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("Remainder is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Remainder", err_diff_type));
		}

		| exp great term
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("'Greater' is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Comparing", err_diff_type));
		}

		| exp great_equal term		
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("'Greater or equal' is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Comparing", err_diff_type));
		}

		| exp less term				
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("'Less' is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Comparing", err_diff_type));
		}

		| exp less_equal term		
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("'Less or equal' is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Comparing", err_diff_type));
		}

		| exp equal term			
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("'is_equal' is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Comparing", err_diff_type));
		}
		
		| exp not_equal term		
		{
			if(is_char($1->name) || is_char($3->name))
				yyerror("'is_not_equal' is not defined for char.");

			char t1[10], t3[10];
			get_types(t1, t3, $1->type, $3->type, $1->name, $3->name);
			if(strcmp(t1, t3))
				yyerror(add_strs("Comparing", err_diff_type));
		}

		| increment ident			
		{
			if(is_char($2->name))
				yyerror("Can't pre-increment a char.");
		}

		| decrement ident			
		{
			if(is_char($2->name))
				yyerror("Can't pre-decrement a char.");
		}

		| ident	increment			
		{
			if(is_char($1->name))
				yyerror("Can't post-increment a char.");
		}
		| ident decrement			
		{
			if(is_char($1->name))
				yyerror("Can't post-decrement char.");
		}


 
	;


term	: int_l			{}
		| char_l		{}
		| ident			
		{
			if(!is_declared($1->name))
				 yyerror(add_strs($1->name, err_undeclared));
		}	

		| string_l		{}
		| l_pranth exp r_pranth		{}
		;

// 							end of the SECOND section.
//----------------------------------------------------------------------------------
%%

void error(char *s)
{
	printf("error: %s\n", s);
	abort();
}

void push_back(char* id, char* type)
{
	struct node *ptr = NULL, *newnode = NULL;
	newnode = (struct node*)malloc(sizeof(struct node));
	if (!newnode) error("Can't allocate memory for newnode in push_back!\n");

	strcpy(newnode->id, id);
	strcpy(newnode->type, type);

	if (!names)				// if there is no nodes yet.
	{
		names = newnode;
		names->next = NULL;
	}

	ptr = names;
	while (ptr->next)		// advance to the last node.
		ptr = ptr->next;

	ptr->next = newnode;
	newnode->next = NULL;

}

int is_declared(char* id)
{
	struct node *ptr = names;
	while (ptr)
	{

//		if (strlen(id) != strlen(ptr->id))
//			return 0;

		if(!strcmp(ptr->id, id))
			return 1;	// it is declared.
		ptr = ptr->next;
	}
	return 0;			// it is not declared.
}

void get_types(char* t1, char* t3, char* st1, char* st3, char* sn1, char* sn3)
{
	if(!strcmp(st1, "var"))
		strcpy(t1, get_type(sn1));
	else
		strcpy(t1, st1);
	
	if(!strcmp(st3, "var"))
		strcpy(t3, get_type(sn3));
	else
		strcpy(t3, st3);


}
int is_keyword(char* name)
{
	if (
			   !strcmp(name, "int") 	|| !strcmp(name, "char") 
			|| !strcmp(name, "if") 		||	!strcmp(name, "else")
			|| !strcmp(name, "then") 	|| !strcmp(name, "read") 
			|| !strcmp(name, "readc") 	|| !strcmp(name, "output")
			|| !strcmp(name, "outputc")	|| !strcmp(name, "while")
								|| !strcmp(name, "return") 			
	)
		return 1;	// it is a reserved keyword.
	else
		return 0;	// it is not a reserved keyword.
}

char* get_type(char* name)
{
	struct node* ptr = names;
	while(name && ptr)//	{printf("\nid: %s\t name: %s\n", ptr->id, name);
		if (!strcmp(ptr->id, name))
			 return ptr->type;
		else
			ptr = ptr->next;
	return NULL;
}

int is_char(char* name)
{

	struct node *ptr = names;
	while (ptr)
	{
		if(!strcmp(ptr->id, name))
			if (!strcmp(ptr->type, "char"))
				return 1;	// it is a char
		ptr = ptr->next;
	}
	return 0;			// it is not a char
}

char* add_strs(const char *s1, const char *s2)
{
    char* result = (char*)malloc(strlen(s1) + strlen(s2) + 1);	// +1 for the null char
	if(!result) error("Can't allocate memory for result in add_strs!\n");
	strcpy(result, s1);
    strcat(result, s2);
    return result;
}

void yyerror(char* s)
{
	error_flag = 1;
	fprintf(stderr, "around line:%d error: %s\n",linenumber, s);
	exit(0);
}

void print_help()
{
	FILE *help_file = fopen("Help.txt", "r");
	if(!help_file) error("Couldn't open 'help.txt' file for reading.\n");
	
	printf("\n");	
	char line[255];
	while (fgets(line, sizeof(line), help_file))
		printf("%s", line);
}

int main(void) 
{

	ASK:;
	printf("Do you some help? 'y' or 'n'\n");
	char ans = ' ';
	scanf(" %c", &ans);
	if (ans == 'y') print_help();
	else if (ans != 'n') { printf("Bad answer!\n") ; goto ASK; }
	
//	printf("Enter the code. (type 'exit' to quit)\n");	

    yyparse();

	if (!error_flag)
		printf("\n------------------\nNo known syntax error.\n");
    return 0;
}
