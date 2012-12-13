%top{
    #import <Foundation/Foundation.h>
    #import "SLSMarkupParserImpl.gen.h"


    #pragma clang diagnostic ignored "-Wconversion"
}

%option reentrant
%option noyywrap
%option bison-bridge
%option stack

%option prefix="slash"
%option header-file="SLSMarkupLexer.gen.h"
%option outfile="SLSMarkupLexer.gen.m"



nontag      [[:print:]]{-}[\<\>\/]

%%

{nontag}+ {
    yylval->text = [NSString stringWithUTF8String:yytext];
    return TEXT;
}

"<"{nontag}+">" {
    yylval->text = [ [ [NSString alloc] initWithBytes:yytext+1 length:strlen(yytext)-2 encoding:NSUTF8StringEncoding] autorelease];
    return OPEN;
}
    
"</"{nontag}+">" {
    yylval->text = [ [ [NSString alloc] initWithBytes:yytext+2 length:strlen(yytext)-3 encoding:NSUTF8StringEncoding] autorelease];
    return CLOSE;
}

"<"{nontag}* {
    yylval->text = NSLocalizedString(@"Unterminated tag", nil);
    return ERR;
}
