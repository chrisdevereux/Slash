%top{
#import <Foundation/Foundation.h>
#import "SLSTagParser.gen.h"

#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wunreachable-code"
#pragma clang diagnostic ignored "-Wunused-function"
#pragma clang diagnostic ignored "-Wunneeded-internal-declaration"
}

%option reentrant
%option noyywrap
%option bison-bridge
%option stack

%option prefix="SLSTagParser_"
%option header-file="SLSTagLexer.gen.h"
%option outfile="SLSTagLexer.gen.m"

/*
  **Unicode**

  Flex doesn't know about UTF-8, so any patterns that match outside the
  ascii character set need to explicitly specify that they should accept
  multibyte characters, and ensure that when part of a multibyte character

  {utf8_multi} matches valid multibyte UTF-8 characters. So long as any
  special characters are in the ascii range, this allows unicode support.
*/

utf8_extra      [\x80-\xBF]
utf8_2b         [\xC0-\xDF]({utf8_extra}{1})
utf8_3b         [\xE0-\xEF]({utf8_extra}{2})
utf8_4b         [\xF0-\xF7]({utf8_extra}{3})
utf8_5b         [\xF8-\xFB]({utf8_extra}{4})
utf8_6b         [\xFC-\xFD]({utf8_extra}{5})
utf8_multi      {utf8_2b}|{utf8_3b}|{utf8_4b}|{utf8_5b}|{utf8_6b}

ascii_nontag    [\x01-\x7F]{-}[\<\>\\]
nontag          {ascii_nontag}|{utf8_multi}

digit           [0-9]
letter          [a-zA-Z_-]
identifier      {letter}({digit}|{letter})*

%%

"\\<" {
    yylval->text = @"<";
    return TEXT;
}

"\\>" {
    yylval->text = @">";
    return TEXT;
}

"\\\\" {
    yylval->text = @"\\";
    return TEXT;
}

"\\"{nontag} {
    yylval->text = @"";
    return TEXT;
}

"\\" {
    yylval->text = @"";
    return TEXT;
}

{nontag}+ {
    yylval->text = [NSString stringWithUTF8String:yytext];
    return TEXT;
}

"<"{identifier}+">" {
    yylval->text = [ [ [NSString alloc] initWithBytes:yytext+1 length:strlen(yytext)-2 encoding:NSUTF8StringEncoding] autorelease];
    return OPEN;
}
    
"</"{identifier}+">" {
    yylval->text = [ [ [NSString alloc] initWithBytes:yytext+2 length:strlen(yytext)-3 encoding:NSUTF8StringEncoding] autorelease];
    return CLOSE;
}

"<"{identifier}* {
    yylval->text = NSLocalizedString(@"Unterminated tag", nil);
    return ERR;
}
