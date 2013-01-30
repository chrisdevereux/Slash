//
//  SLSParseContext.m
//  Slash
//
//  Created by Chris Devereux on 29/01/2013.
//  Copyright (c) 2013 ChrisDevereux. All rights reserved.
//

#import "SLSTagParser.h"
#import "SLSTagLexer.gen.h"
#import "SLSTagParser.gen.h"
#import "SLSErrors.h"

int SLSTagParser_parse(yyscan_t scanner, SLSTagParser *ctx);


@implementation SLSTagParser {
    NSMutableArray *_taggedRanges;
    yyscan_t _scanner;
    BOOL _hasParsed;
}

@synthesize taggedRanges = _taggedRanges;

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    SLSTagParser_lex_init(&_scanner);
    _attributedString = [[NSMutableAttributedString alloc] init];
    _taggedRanges = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc
{
    [_attributedString release];
    [_taggedRanges release];
    [_error release];
    
    if (_scanner) {
        SLSTagParser_lex_destroy(_scanner);
    }
    
    [super dealloc];
}

- (void)parseMarkup:(NSString *)markup
{
    NSAssert(!_hasParsed, @"SLSTagParser is not reusable");
    _hasParsed = YES;
             
    YY_BUFFER_STATE buf = SLSTagParser__scan_string([markup UTF8String], _scanner);
    SLSTagParser_parse(_scanner, self);
    SLSTagParser__delete_buffer(buf, _scanner);
}

- (void)addTag:(SLSTaggedRange *)tag
{
    [_taggedRanges insertObject:tag atIndex:0];
}

- (void)appendString:(NSString *)string
{
    [_attributedString.mutableString appendString:string];
}

- (NSUInteger)currentLength
{
    return _attributedString.length;
}

@end

void SLSTagParser_error(void *scanner, SLSTagParser *ctx, const char *msg)
{
    ctx.error = [NSError errorWithDomain:SLSErrorDomain code:kSLSSyntaxError userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Syntax error", nil)}];
}
