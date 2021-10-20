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

static StringTable<Entry> stringtab;

static int nested_comment_count = 0;
static int string_length = 0;

/*
 *  Add Your own definitions here
 */

%}

 /*
 * Define names for regular expressions here.
 */
  /*cannot use (?i:xxx), flex complains about "unrecognized rule"*/
CLASS   [C|c][L|l][A|a][S|s][S|s]
ELSE    [E|e][L|l][S|s][E|e]
FI      [F|f][I|i]
IF      [I|i][F|f]
IN      [I|i][N|n]
INHERITS        [I|i][N|n][H|h][E|e][R|r][I|i][T|t][S|s]
LET     [L|l][E|e][T|t]
LOOP    [L|l][O|o][O|o][P|p]
POOL    [P|p][O|o][O|o][L|l]
THEN    [T|t][H|h][E|e][N|n]
WHILE   [W|w][H|h][I|i][L|l][E|e]
CASE    [C|c][A|a][S|s][E|e]
ESAC    [E|e][S|s][A|a][C|c]
OF      [O|o][F|f]
DARROW  =>
NEW     [N|n][E|e][W|w]
ISVOID  [I|i][S|s][V|v][O|o][I|i][D|d]
ASSIGN  <-
NOT     [N|n][O|o][T|t]
LE      <=

%Start COMMENT
%Start STRING
%Start STRING_ERROR

%%

 /*
 * 1. Invalid characters
 */

[\!\#\%\&\`\\\?\$\^\|\[\]\'\>] {
  strcpy(string_buf_ptr,yytext);
  cool_yylval.error_msg=string_buf_ptr;
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
  BEGIN(INITIAL);
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
  BEGIN(INITIAL);
  strcpy(string_buf_ptr,"EOF in string constant");
  cool_yylval.error_msg=string_buf_ptr;
  string_length = 0;
  return ERROR;
}

<STRING>\n {
  BEGIN(INITIAL);
  curr_lineno++;
  strcpy(string_buf_ptr,"Unterminated string constant");
  cool_yylval.error_msg=string_buf_ptr;
  string_length = 0;
  return ERROR;
}

<STRING>\"  {
  BEGIN(INITIAL);
  string_buf_ptr[string_length]='\0';
  cool_yylval.symbol=stringtab.add_string(string_buf_ptr);
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

<STRING>\\(.|\n) {
  if(string_length==MAX_STR_CONST){
    BEGIN(STRING_ERROR);
    strcpy(string_buf_ptr,"String constant too long");
    cool_yylval.error_msg=string_buf_ptr;
    string_length = 0;
    return ERROR;
  }else{
    switch(yytext[1]){
      case 'n':
        string_buf_ptr[string_length++] = '\n';
        break;
      case 't':
        string_buf_ptr[string_length++] = '\t';
        break;
      case 'b':
        string_buf_ptr[string_length++] = '\b';
        break;
      case 'f':
        string_buf_ptr[string_length++] = '\f';
        break;
      default:
        string_buf_ptr[string_length++] = yytext[1];
    }
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
    string_buf_ptr[string_length++]=yytext[0];
  }
}

<STRING_ERROR>[\"|\n]  {
  if(yytext[0]=='\n'){
    curr_lineno++;
  }
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

t[r|R][u|U][e|E] {
  cool_yylval.boolean=1;
  return BOOL_CONST;
}

f[a|A][l|L][s|S][e|E]  {
  cool_yylval.boolean=0;
  return BOOL_CONST;
}

  /*
  *  7. OBJECTID
  */

[[:upper:]][[:alnum:]_]*  {

  cool_yylval.symbol=*(stringtab.add_string(yytext));
  return TYPEID;
}

  /*
  *  8. TYPEID
  */

[[:lower:]][[:alnum:]_]*  {
  cool_yylval.symbol=*(stringtab.add_string(yytext));
  return OBJECTID;
}
  /*
  *  9. Operators and other characters
  */
[\+\-\*\/\<\=\.\~\,\;\:\(\)\@\{\}]  {
  return yytext[0];
}

  /*
  *  10. OTHERS
  */

  \n  {curr_lineno++;}

%%
