#ifndef _NODE_H_
#define _NODE_H_

	struct record
	{
		int i_val; 
		char c_val;
		char *name, *type;
	};

	struct node
    {
	    char id[500], type[10];
		char c_val;
		int i_val;
	    struct node *next;
    };
 	void push_back(char*, char*);
	int is_declared(char*);
	char* get_type(char*);
	int is_char(char*);

    static struct node *names = NULL;
	

#endif // _NODE_H_
