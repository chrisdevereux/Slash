%{
    #import <Foundation/Foundation.h>
    #import "SLSMarkupParser+BisonContext.h"
    #import "SLSMarkupLexer.gen.h"
    
    #define YYDEBUG 1
%}

%pure-parser
%parse-param { yyscan_t scanner }
%parse-param { SLSMarkupParser *ctx }
%lex-param { yyscan_t scanner }

%no-lines
%name-prefix="slash"
%output="SLSMarkupParserImpl.gen.m"

%union {
    NSString    *text;
    NSRange     attribute_range;
}

%token <text> TEXT
%token <text> OPEN
%token <text> CLOSE

%type <attribute_range> attributed_string
%type <attribute_range> inner_attributed_string

%start start

%%

start
: attributed_string
    
attributed_string
: inner_attributed_string
| OPEN attributed_string CLOSE {
    [ctx addAttributesForTag:$1 inRange:$2];
    $$ = $2;
}
| attributed_string attributed_string {
    $$ = NSMakeRange($1.location, $1.length + $2.length);
}

// The first recognized production for all text.
// Text is appended to the output NSAttributedString here.
inner_attributed_string
: OPEN TEXT CLOSE {
    NSRange tagRange;
    tagRange.location = [ctx.outAttStr length];
    tagRange.length = [$2 length];
    
    [[ctx.outAttStr mutableString] appendString:$2];
    [ctx addAttributesForTag:$1 inRange:tagRange];

    $$ = tagRange;
}
| TEXT {
    NSRange tagRange;
    tagRange.location = [ctx.outAttStr length];
    tagRange.length = [$1 length];
    
    [[ctx.outAttStr mutableString] appendString:$1];

    $$ = tagRange;
}
