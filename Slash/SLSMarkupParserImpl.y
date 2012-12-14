%{
    #import <Foundation/Foundation.h>
    #import "SLSMarkupParser+BisonContext.h"
    #import "SLSMarkupLexer.gen.h"
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
    struct{}    noval;
}

%token <text> TEXT
%token <text> OPEN
%token <text> CLOSE
%token <text> ERR

%type <attribute_range> tagged_text
%type <attribute_range> text
%type <noval> abort_parse

%start start
%expect 2

%%

start
: tagged_text
| abort_parse
    
tagged_text
: text
| OPEN tagged_text CLOSE {
    if (![$1 isEqualToString:$3]) {
        ctx.error = [NSError errorWithDomain:SLSErrorDomain code:kSLSSyntaxError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unterminated attributed", nil)}];
    }
    
    [ctx addAttributesForTag:$1 inRange:$2];
    $$ = $2;
}
| tagged_text tagged_text {
    $$ = NSMakeRange($1.location, $1.length + $2.length);
}

// The first recognized production for all text.
// Text is appended to the output NSAttributedString here.
text
: TEXT {
    NSRange tagRange;
    tagRange.location = [ctx.outAttStr length];
    tagRange.length = [$1 length];
    
    [[ctx.outAttStr mutableString] appendString:$1];

    $$ = tagRange;
}
| OPEN CLOSE {
    NSRange tagRange;
    tagRange.location = [ctx.outAttStr length];
    tagRange.length = 0;

    $$ = tagRange;
}

abort_parse
: ERR {
    ctx.error = [NSError errorWithDomain:SLSErrorDomain code:kSLSSyntaxError userInfo:@{NSLocalizedDescriptionKey: $1}];
}
