//
//  SLSMarkupParser.m
//  SLSMarkup
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 Unbounded. All rights reserved.
//

#import "SLSMarkupParser.h"
#import "SLSMarkupParser+BisonContext.h"
#import "SLSMarkupParserImpl.gen.h"
#import "SLSMarkupLexer.gen.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define FONT_CLASS UIFont

#else
#import <AppKit/AppKit.h>
#define FONT_CLASS NSFont

#endif

int slashparse (yyscan_t scanner, SLSMarkupParser *ctx);

@interface SLSMarkupParser ()
@property (strong, readonly, nonatomic) NSMutableArray *taggedRangeStack;
@end

extern int slashdebug;

@implementation SLSMarkupParser {
    NSDictionary *_attributeDict;
    NSMutableAttributedString *_outAttStr;
    NSError *_error;
}

+ (NSDictionary *)defaultTagDefinitions
{
    return @{
        @"$default" : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue" size:14]},
        @"strong"   : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Bold" size:14]},
        @"emph"     : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Italic" size:14]},
        @"h1"       : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Medium" size:48]},
        @"h2"       : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Medium" size:36]},
        @"h3"       : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Medium" size:32]},
        @"h4"       : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Medium" size:24]},
        @"h5"       : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Medium" size:18]},
        @"h6"       : @{NSFontAttributeName  : [FONT_CLASS fontWithName:@"HelveticaNeue-Medium" size:16]}
    };
}

+ (NSAttributedString *)stringByParsingTaggedString:(NSString *)string withTagDefinitions:(NSDictionary *)defs error:(NSError **)error
{
    if (!string) {
        return nil;
    }
    
    if ([string length] == 0) {
        return [[[NSAttributedString alloc] init] autorelease];
    }
    
    defs = defs ?: [self defaultTagDefinitions];
    
    SLSMarkupParser *parser = [[self alloc] initWithTagDictionary:defs];
    [parser parseString:string];
    
    NSAttributedString *attributedString = nil;
    if (parser.error) {
        if (error) {
            *error = [[parser.error retain] autorelease];
        }
    } else {
        [parser applyAttributes];
        attributedString = [[parser.outAttStr copy] autorelease];
        
        if (parser.error) {
            if (error) {
                *error = [[parser.error retain] autorelease];
            }
            
            attributedString = nil;
        }
    }
    
    [parser release];
    return attributedString;
}

+ (NSAttributedString *)stringByParsingTaggedString:(NSString *)string error:(NSError **)error
{
    return [self stringByParsingTaggedString:string withTagDefinitions:nil error:error];
}

- (id)initWithTagDictionary:(NSDictionary *)tagDict
{
    self = [super init];
    if (!self)
        return nil;
    
    _attributeDict = [tagDict retain];
    _outAttStr = [[NSMutableAttributedString alloc] init];
    _taggedRangeStack = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc
{
    [_attributeDict release];
    [_outAttStr release];
    [_taggedRangeStack release];
    [_error release];
    [super dealloc];
}

- (void)parseString:(NSString *)string
{
    yyscan_t scanner;
    
    slashlex_init(&scanner);
    YY_BUFFER_STATE buf = slash_scan_string([string UTF8String], scanner);
    
    slashparse(scanner, self);
    
    slash_delete_buffer(buf, scanner);
    slashlex_destroy(scanner);
}

- (void)applyAttributes
{
    // Parser produces an array of tag ranges, outermost tag
    // at index 0. Apply the default style to the whole string,
    // then work inwards, applying the attributes defined for the tag
    
    [_outAttStr setAttributes:[_attributeDict objectForKey:@"$default"] range:NSMakeRange(0, [_outAttStr length])];
    
    for (NSArray *taggedRange in _taggedRangeStack) {
        NSString *tag = [taggedRange objectAtIndex:0];
        NSRange range = [[taggedRange objectAtIndex:1] rangeValue];
        
        NSDictionary *attributes = [_attributeDict objectForKey:tag];
        if (!attributes) {
            self.error = [NSError errorWithDomain:SLSErrorDomain code:kSLSUnknownTagError userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Unknown tag" , nil), tag]}];
        }
        
        [_outAttStr setAttributes:[_attributeDict objectForKey:tag] range:range];
    }
}

- (NSMutableAttributedString *)outAttStr
{
    return [[_outAttStr retain] autorelease];
}

- (void)addAttributesForTag:(NSString *)tag inRange:(NSRange)range
{
    [_taggedRangeStack insertObject:@[tag, [NSValue valueWithRange:range]] atIndex:0];
}

- (void)setError:(NSError *)error
{
    [error retain];
    [_error release];
    _error = error;
}

- (NSError *)error
{
    return [[_error retain] autorelease];
}

@end

void slasherror(yyscan_t scanner, SLSMarkupParser *ctx, const char *msg)
{
    ctx.error = [NSError errorWithDomain:SLSErrorDomain code:kSLSSyntaxError userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"Syntax error", nil)}];
}

NSString * const SLSErrorDomain = @"SLSErrorDomain";
