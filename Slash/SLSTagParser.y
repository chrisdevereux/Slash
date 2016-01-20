%{
#import <Foundation/Foundation.h>
#import "SLSTaggedRange.h"
#import "SLSTagParser.h"
#import "SLSTagLexer.gen.h"
#import "SLSErrors.h"

#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wunreachable-code"
#pragma clang diagnostic ignored "-Wunused-function"
#pragma clang diagnostic ignored "-Wunneeded-internal-declaration"
%}

%pure-parser
%parse-param { yyscan_t scanner }
%parse-param { SLSTagParser *output }
%lex-param { yyscan_t scanner }

%no-lines
%name-prefix="SLSTagParser_"
%output="SLSTagParser.gen.m"

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
        output.error = [NSError errorWithDomain:SLSErrorDomain code:kSLSSyntaxError userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unterminated attributed", nil)}];
    }
    
    [output addTag:[SLSTaggedRange tagWithName:$1 range:$2]];
    $$ = $2;
}
| tagged_text tagged_text {
    $$ = NSMakeRange(($1).location, ($1).length + ($2).length);
}

// The first recognized production for all text.
// Text is appended to the output NSAttributedString here.
text
: TEXT {
    NSRange tagRange;
    tagRange.location = output.currentLength;
    tagRange.length = ($1).length;
    
    [output appendString:$1];
    
    $$ = tagRange;
}
| OPEN CLOSE {
    NSRange tagRange;
    tagRange.location = output.currentLength;
    tagRange.length = 0;

    $$ = tagRange;
}

abort_parse
: ERR {
    output.error = [NSError errorWithDomain:SLSErrorDomain code:kSLSSyntaxError userInfo:@{NSLocalizedDescriptionKey: $1}];
}

