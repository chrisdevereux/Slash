//
//  TestParser.m
//  Slash
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 Chris Devereux. All rights reserved.
//

#import "TestParser.h"
#import "SLSMarkupParser.h"

@implementation TestParser

- (void)testCanParseSimpleString
{
    NSString *str = @"this is <strong>awesome</strong>";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"this is awesome"];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"$default"] range:NSMakeRange(0, 15)];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"strong"] range:NSMakeRange(8, 7)];
    
    NSAttributedString *actual = [SLSMarkupParser attributedStringWithMarkup:str error:NULL];
    STAssertEqualObjects(actual, expected, @"Parsed markup does not have expected attributes.");
}

- (void)testCanParseComplexString
{
    NSString *str = @"<h1>No blind <strong>spots</strong><strong></strong> in the leopard's eyes can <strong>only</strong> help to</h1> jeopardize the lives of lambs, the shepherd cries. An<h2> afterlife</h2><h2> for a silverfish. Eternal</h2> dust less ticklish.";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"No blind spots in the leopard's eyes can only help to jeopardize the lives of lambs, the shepherd cries. An afterlife for a silverfish. Eternal dust less ticklish."];
    
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"$default"] range:NSMakeRange(0, 163)];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"h1"] range:NSMakeRange(0, 53)];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"strong"] range:NSMakeRange(9, 5)];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"strong"] range:NSMakeRange(14, 0)];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"strong"] range:NSMakeRange(41, 4)];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"h2"] range:NSMakeRange(107, 10)];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"h2"] range:NSMakeRange(117, 26)];
    
    NSError *error;
    NSAttributedString *actual = [SLSMarkupParser attributedStringWithMarkup:str error:&error];
    STAssertEqualObjects(actual, expected, @"Parsed markup does not have expected attributes.");
}

- (void)testCanParseUnicodeCharacters
{
    NSSet *ignore = [NSSet setWithObjects:@">x", @"<x", @"\\x", nil];
    
    for (uint32_t chr = 0x1; chr <= 0x10FFFF; chr++) {
        @autoreleasepool {
            NSString *testStr = [[[NSString alloc] initWithBytes:&chr length:4 encoding:NSUTF32StringEncoding] stringByAppendingString:@"x"];
            
            if (!testStr || [ignore containsObject:testStr]) {
                continue;
            }
            
            NSString *markup = [NSString stringWithFormat:@"<h1>%@</h1>", testStr];
            
            NSAttributedString *attrStr = [SLSMarkupParser attributedStringWithMarkup:markup error:NULL];
            
            NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:testStr];
            [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"h1"] range:NSMakeRange(0, [testStr length])];
            
            STAssertEqualObjects(expected, attrStr, @"Failed to parse codepoint +%X", chr);
        }
    }
}

- (void)testCanParseSomeNiceHearts
{
    NSString *str = @"<h1>❤❤❤❤</h1>";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"❤❤❤❤"];
    [expected setAttributes:[[SLSMarkupParser defaultStyle] valueForKey:@"h1"] range:NSMakeRange(0, 4)];
    
    NSError *error;
    NSAttributedString *actual = [SLSMarkupParser attributedStringWithMarkup:str error:&error];
    STAssertEqualObjects(actual, expected, @"Parsed markup not correct.");
}

- (void)testCanParseMultilineString
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"a\nb" error:NULL];
    STAssertEqualObjects(str, [[NSAttributedString alloc] initWithString:@"a\nb" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]], nil);
}

- (void)testCanParseEmptyString
{
    STAssertNotNil([SLSMarkupParser attributedStringWithMarkup:@"" error:NULL], @"Should accept empty string");
}

- (void)testCanParseEscapedOpen
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"\\<" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"<" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    STAssertEqualObjects(str, expected, @"Should allow escaped open angle-parenthesis");
}

- (void)testCanParseEscapedClose
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"\\>" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@">" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    STAssertEqualObjects(str, expected, @"Should allow escaped open angle-parenthesis");
}

- (void)testCanParseEscapedEscape
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"\\\\" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"\\" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    STAssertEqualObjects(str, expected, @"Should allow escaped backslash");
}

- (void)testIgnoresEscapedText
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"\\X" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    STAssertEqualObjects(str, expected, @"ordinary characters should be ignored when escaped");
}

- (void)testIgnoresSingleEscape
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"\\" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    STAssertEqualObjects(str, expected, @"single escape characters should be ignored");
}

- (void)testIncompleteTagsThrowError
{
    for (NSString *str in @[@"<", @"<x", @"<xx", @"<x>abc<", @"<x>abc</", @"<x>abc</x"]) {
        [self assertStringProducesSyntaxError:str];
    }
}

- (void)assertStringProducesSyntaxError:(NSString *)str
{
    NSError *error;
    STAssertNil([SLSMarkupParser attributedStringWithMarkup:str error:&error], @"%@ should raise error", str);
    STAssertEquals((SLSErrorCode)[error code], kSLSSyntaxError, @"Expected syntax error code");
}

- (void)testUnterminatedSectionProducesError
{
    for (NSString *str in @[@"<x>y"]) {
        [self assertStringProducesSyntaxError:str];
    }
}

- (void)testCrossedSectionsProducesError
{
    [self assertStringProducesSyntaxError:@"<h1>12 <h3>34</h1></h2>"];
}

- (void)testUnexpectedTagProducesError
{
    [self assertStringProducesSyntaxError:@"</h1>"];
}

- (void)testUnknownTagProducesError
{
    if (![SLSMarkupParser defaultStyle]) {
        // Test only works for targets that support -defaultStyle
        return;
    }
    
    NSError *error;
    STAssertNil([SLSMarkupParser attributedStringWithMarkup:@"<undefined>xyz</undefined>" error:&error], @"Expected error");
    STAssertNotNil(error, @"Expected error");
    STAssertEquals((SLSErrorCode)[error code], kSLSUnknownTagError, @"Incorrect error code");
}

@end
