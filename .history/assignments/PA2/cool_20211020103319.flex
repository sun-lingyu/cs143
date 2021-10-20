 /*
 *  The scanner definition for COOL.
 */

 /*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Do not remove anything that was here initially
 */

%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

//added by myself below:

static StringTable stringtab;

static nested_comment_count = 0;
static string_length = 0;

/*
 *  Add Your own definitions here
 */

%}

 /*
 * Define names for regular expressions here.
 */
CLASS   (?i:class)
ELSE    (?i:else)
FI      (?i:fi)
IF      (?i:if)
IN      (?i:in)
INHERITS        (?i:inherits)
LET     (?i:let)
LOOP    (?i:loop)
POOL    (?i:pool)
THEN    (?i:then)
WHILE   (?i:while)
CASE    (?i:case)
ESAC    (?i:esac)
OF      (?i:of)
DARROW  =>
NEW     (?i:new)
ISVOID  (?i:isvoid)
ASSIGN  <-
NOT     (?i:not)
LE      <=

%Start COMMENT
%Start STRING
%Start STRING_ERROR

%%

 /*
 * 1. Invalid characters
 */

[\!\#\%\&\`\\\?\$\^\|\[\]\'\>] {
  cool_yylval.error_msg=yytext;
  return ERROR;
}

 /*
  *  2. Nested comments
  */

--.*$ {}

\(\*  {
  BEGIN(COMMENT);
  nested_comment_count = 1;
}

\*\) {
  strcpy(string_buf_ptr,"Unmatched *)");
  cool_yylval.error_msg=string_buf_ptr;
  return ERROR;
}

<COMMENT>\(\* {
  nested_comment_count++;
}

<COMMENT>\*\) {
  nested_comment_count--;
  if(nested_comment_count == 0){
    BEGIN(INITIAL);
  }
}

<COMMENT><<EOF>>  {
  strcpy(string_buf_ptr,"EOF in comment");
  cool_yylval.error_msg=string_buf_ptr;
  nested_comment_count = 0;
  return ERROR;
}

 /*
  * 3. Keywords
  */

{CLASS} {return CLASS;}
{ELSE}  {return ELSE;}
{FI}    {return FI;}
{IF}    {return IF;}
{IN}    {return IN;}
{INHERITS}      {return INHERITS;}
{LET}   {return LET;}
{LOOP}  {return LOOP;}
{POOL}  {return POOL;}
{THEN}  {return THEN;}
{WHILE} {return WHILE;}
{CASE}  {return CASE;}
{ESAC}  {return ESAC;}
{OF}    {return OF;}
{DARROW}        {return DARROW;}
{NEW}   {return NEW;}
{ISVOID}        {return ISVOID;}
{ASSIGN}        {return ASSIGN;}
{NOT}   {return NOT;}
{LE}    {return LE;}

 /*
  *  4. String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\"  {
  BEGIN(STRING);
  string_length = 0;
}

<STRING><<EOF>> {
  strcpy(string_buf_ptr,"EOF in string constant");
  cool_yylval.error_msg=string_buf_ptr;
  string_length = 0;
  return ERROR;
}

<STRING>\n {
  strcpy(string_buf_ptr,"Unterminated string constant");
  cool_yylval.error_msg=string_buf_ptr;
  string_length = 0;
  return ERROR;
}

<STRING>\"  {
  BEGIN(INITIAL);
  yytext[string_length]=\0;
  cool_yylval.symbol=stringtab.add_string(yytext);
  string_length = 0;
  return STR_CONST;
}

<STRING>\0 {
  BEGIN(STRING_ERROR);
  strcpy(string_buf_ptr,"String contains null character");
  cool_yylval.error_msg=string_buf_ptr;
  string_length = 0;
  return ERROR;
}

<STRING>\\((.|\n){-}[ntbf]) {
  unput(yytext[1]);
}

<STRING>\\[ntbf]  {
  switch(yytext[1]){
    case 'n':
      
      break;
    case 't':
      unput('\t');
      break;
    case 'b':
      unput('\b');
      break;
    case 'f':
      unput('\f');
      break;
  }
  
}

<STRING>. {
  if(string_length==MAX_STR_CONST){
    BEGIN(STRING_ERROR);
    strcpy(string_buf_ptr,"String constant too long");
    cool_yylval.error_msg=string_buf_ptr;
    string_length = 0;
    return ERROR;
  }else{
    string_length++;
    yymore();
  }
}

<STRING_ERROR>[\"|\n]  {
  BEGIN(INITIAL);
}

  /*
  *  5. Int constants
  */
[[:digit:]]+  {
  cool_yylval.symbol=stringtab.add_string(yytext);
  return INT_CONST;
}

  /*
  *  6. Bool constants
  */

t(?i:rue) {
  cool_yylval.boolean=1;
  return BOOL_CONST;
}

f(?i:alse)  {
  cool_yylval.boolean=0;
  return BOOL_CONST;
}

  /*
  *  7. OBJECTID
  */

[[:upper:]][[:alnum:]_]*  {
  cool_yylval.symbol=stringtab.add_string(yytext);
  return TYPEID;
}

  /*
  *  8. TYPEID
  */

[[:lower:]][[:alnum:]_]*  {
  cool_yylval.symbol=stringtab.add_string(yytext);
  return OBJECTID;
}
  /*
  *  9. Operators and other characters
  */
[\+\-\*\/\<\=\.\~\,\;\:\(\)\@\{\}]  {
  reuturn *yytext;
}


  /*
  *  10. OTHERS
  */

  \n  {curr_lineno++;}

%%
