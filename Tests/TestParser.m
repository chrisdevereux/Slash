//
//  TestParser.m
//  Slash
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 Chris Devereux. All rights reserved.
//

#import "TestParser.h"
#import "SLSMarkupParser.h"
#import "SLSErrors.h"

#if TARGET_OS_IPHONE
#define FONT_CLASS UIFont
#define COLOR_CLASS UIColor

#else
#define FONT_CLASS NSFont
#define COLOR_CLASS NSColor

#endif


#define AssertAttributeAtIndex(attrStr, attrKey, attrVal, idx) XCTAssertEqualObjects([(attrStr) attribute:(attrKey) atIndex:(idx) effectiveRange:NULL], (attrVal), @"Expected attribute '%s' to equal '%s' at index %d", #attrKey, #attrVal, (int)(idx))

#define AssertHasAttributeFor(attrStr, attr) XCTAssertNotNil([[(attrStr) attributesAtIndex:0 effectiveRange:NULL] objectForKey:(attr)], @"Expected attribute '%s' to be defined", (#attr))

static NSDictionary * AttributesWithDefaults(NSDictionary *style, NSString *key)
{
    NSMutableDictionary *result = [[[SLSMarkupParser defaultStyle] valueForKey:@"$default"] mutableCopy];
    [result setValuesForKeysWithDictionary:[style valueForKey:key]];
    return result;
}


@implementation TestParser

- (NSUInteger)numberOfTestIterationsForTestWithSelector:(SEL)testMethod
{
    if (testMethod == @selector(testCanParseUnicodeCharacters)) {
        return 1;
    }
    
    NSString *iterationsEnvVar = [[[NSProcessInfo processInfo] environment] objectForKey:@"SLSTestIterations"];
    return iterationsEnvVar ? (NSUInteger)[iterationsEnvVar intValue] : 1;
}

- (void)testCanParseSimpleString
{
    NSString *str = @"this is <strong>awesome</strong>";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"this is awesome"];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"$default") range:NSMakeRange(0, 15)];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"strong") range:NSMakeRange(8, 7)];
    
    NSAttributedString *actual = [SLSMarkupParser attributedStringWithMarkup:str error:NULL];
    XCTAssertEqualObjects(actual, expected, @"Parsed markup does not have expected attributes.");
}

- (void)testCanParseComplexString
{
    NSString *str = @"<h1>No blind <strong>spots</strong><strong></strong> in the leopard's eyes can <strong>only</strong> help to</h1> jeopardize the lives of lambs, the shepherd cries. An<h2> afterlife</h2><h2> for a silverfish. Eternal</h2> dust less ticklish.";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"No blind spots in the leopard's eyes can only help to jeopardize the lives of lambs, the shepherd cries. An afterlife for a silverfish. Eternal dust less ticklish."];
    
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"$default") range:NSMakeRange(0, 163)];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"h1") range:NSMakeRange(0, 53)];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"h2") range:NSMakeRange(107, 10)];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"h2") range:NSMakeRange(117, 26)];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"strong") range:NSMakeRange(9, 5)];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"strong") range:NSMakeRange(41, 4)];
    
    NSError *error;
    NSAttributedString *actual = [SLSMarkupParser attributedStringWithMarkup:str error:&error];
    XCTAssertEqualObjects(actual, expected, @"Parsed markup does not have expected attributes.");
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
            [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"h1") range:NSMakeRange(0, [testStr length])];
            
            XCTAssertEqualObjects(expected, attrStr, @"Failed to parse codepoint +%X", chr);
        }
    }
}

- (void)testCanParseSomeNiceHearts
{
    NSString *str = @"<h1>❤❤❤❤</h1>";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"❤❤❤❤"];
    [expected setAttributes:AttributesWithDefaults([SLSMarkupParser defaultStyle], @"h1") range:NSMakeRange(0, 4)];
    
    NSError *error;
    NSAttributedString *actual = [SLSMarkupParser attributedStringWithMarkup:str error:&error];
    XCTAssertEqualObjects(actual, expected, @"Parsed markup not correct.");
}

- (void)testCanParseMultilineString
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"a\nb" error:NULL];
    XCTAssertEqualObjects(str, [[NSAttributedString alloc] initWithString:@"a\nb" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]]);
}

- (void)testCanParseEmptyString
{
    XCTAssertNotNil([SLSMarkupParser attributedStringWithMarkup:@"" error:NULL], @"Should accept empty string");
}

- (void)testCanParseEscapedOpen
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"foo\\<bar" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"foo<bar" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    XCTAssertEqualObjects(str, expected, @"Should allow escaped open angle-parenthesis");
}

- (void)testCanParseEscapedClose
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"foo\\>bar" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"foo>bar" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    XCTAssertEqualObjects(str, expected, @"Should allow escaped open angle-parenthesis");
}

- (void)testCanParseEscapedOpenClose
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"f\\<oo\\>bar" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"f<oo>bar" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    XCTAssertEqualObjects(str, expected, @"Should allow escaped open and close angle-parenthesis");
}

- (void)testCanParseEscapedEscape
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"foo\\\\bar" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"foo\\bar" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    XCTAssertEqualObjects(str, expected, @"Should allow escaped backslash");
}

- (void)testIgnoresEscapedText
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"\\X" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    XCTAssertEqualObjects(str, expected, @"ordinary characters should be ignored when escaped");
}

- (void)testIgnoresSingleEscape
{
    NSAttributedString *str = [SLSMarkupParser attributedStringWithMarkup:@"\\" error:NULL];
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"" attributes:[[SLSMarkupParser defaultStyle] objectForKey:@"$default"]];
    
    XCTAssertEqualObjects(str, expected, @"single escape characters should be ignored");
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
    XCTAssertNil([SLSMarkupParser attributedStringWithMarkup:str error:&error], @"%@ should raise error", str);
    XCTAssertEqual((SLSErrorCode)[error code], kSLSSyntaxError, @"Expected syntax error code");
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
    XCTAssertNil([SLSMarkupParser attributedStringWithMarkup:@"<undefined>xyz</undefined>" error:&error], @"Expected error");
    XCTAssertNotNil(error, @"Expected error");
    XCTAssertEqual((SLSErrorCode)[error code], kSLSUnknownTagError, @"Incorrect error code");
}



- (void)testInnerAttributesAreCombinedWithOuterAttributes
{
    id innerAttr = [FONT_CLASS fontWithName:@"Helvetica" size:74];
    id outerAttr = [COLOR_CLASS whiteColor];
    
    NSDictionary *style = @{
        @"inner" : @{NSFontAttributeName : innerAttr},
        @"outer" : @{NSForegroundColorAttributeName : outerAttr}
    };
    
    NSString *markup = @"<outer>outer<inner>inner</inner></outer>";
    NSAttributedString *parsedString = [SLSMarkupParser attributedStringWithMarkup:markup style:style error:NULL];
    
    AssertAttributeAtIndex(parsedString, NSFontAttributeName, innerAttr, 6);
    AssertAttributeAtIndex(parsedString, NSForegroundColorAttributeName, outerAttr, 6);
}

- (void)testInnerAttributesTakePrescidenceOverOuterAttributes
{
    id innerAttr = [FONT_CLASS fontWithName:@"Helvetica" size:74];
    id outerAttr = [FONT_CLASS fontWithName:@"Helvetica" size:12];
    
    NSDictionary *style = @{
        @"inner" : @{NSFontAttributeName : innerAttr},
        @"outer" : @{NSFontAttributeName : outerAttr}
    };
    
    NSString *markup = @"<outer>outer<inner>inner</inner></outer>";
    NSAttributedString *parsedString = [SLSMarkupParser attributedStringWithMarkup:markup style:style error:NULL];
    
    AssertAttributeAtIndex(parsedString, NSFontAttributeName, innerAttr, 6);
}



- (void)testDefaultsAreProvidedForRequiredAttributes
{
    // Fixes: https://github.com/chrisdevereux/Slash/issues/4s
    
    NSAttributedString *attrStr = [SLSMarkupParser attributedStringWithMarkup:@"untagged text" error:NULL];
    
    AssertHasAttributeFor(attrStr, NSForegroundColorAttributeName);
    AssertHasAttributeFor(attrStr, NSFontAttributeName);
    AssertHasAttributeFor(attrStr, NSKernAttributeName);
    AssertHasAttributeFor(attrStr, NSStrokeColorAttributeName);
    AssertHasAttributeFor(attrStr, NSStrokeWidthAttributeName);
}

- (void)testUserProvidedDefaultAttributesAreMergedWithDefaultAttributes
{
    FONT_CLASS *expectedFont = [FONT_CLASS fontWithName:@"Helvetica" size:11];
    NSDictionary *style = @{@"$default" : @{NSFontAttributeName : expectedFont}};
    
    NSAttributedString *attrStr = [SLSMarkupParser attributedStringWithMarkup:@"untagged text" style:style error:NULL];
    FONT_CLASS *fontAttribute = [[attrStr attributesAtIndex:0 effectiveRange:NULL] objectForKey:NSFontAttributeName];
    
    AssertHasAttributeFor(attrStr, NSForegroundColorAttributeName);
    AssertHasAttributeFor(attrStr, NSFontAttributeName);
    AssertHasAttributeFor(attrStr, NSKernAttributeName);
    AssertHasAttributeFor(attrStr, NSStrokeColorAttributeName);
    AssertHasAttributeFor(attrStr, NSStrokeWidthAttributeName);
    
    XCTAssertEqualObjects(fontAttribute, expectedFont, @"Should override default font");
}

@end
