# Parser-Lexical-Analyzer


(type "exit" at any time to quit the parser)

Welcome to our basic syntax checker for small-c.

Before using the compiler, we would like to notify you that the following
restrictions will hold untill we update the program.

Restrictions:
1- You can declare multiple variables at once (int x,y,u;), but you can't
initialze them. You can assign the values one by one after that statment.

2- You can use a lot of operators (+,-,*,/,>,<,==,!=,%,>=,<=,+=,-=,*=,/=,%=)
but they are only defined for integer variables and literals.

3- You can define functions with up to 100 parameters, and the name of 
the parameters will be clashed with anything else, they are considered shallow,
and you MUST return an expression at the end of each function, and functions
can't be called yet.

4- You can write nested if-statements and while-statements, but the logical
expression type will not be checked.

5- Any error will cause terminate the program, so even if there is multiple
errors, you will see only the first.

6- Only line-comments are allowed, bolck of comments are not implemented yet.

7- (readc, outputc) takes the argument between pranthesis, while (read,output)
don't.


