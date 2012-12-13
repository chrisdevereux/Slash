//
//  TestParser.m
//  Slash
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 ChrisDevereux. All rights reserved.
//

#import "TestParser.h"
#import "SLSMarkupParser.h"

@implementation TestParser

- (void)testSimpleString
{
    NSString *str = @"this is <strong>awesome</strong>";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"this is awesome"];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"$default"] range:NSMakeRange(0, 15)];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"strong"] range:NSMakeRange(8, 7)];
    
    NSAttributedString *actual = [SLSMarkupParser stringByParsingTaggedString:str error:NULL];
    STAssertEqualObjects(actual, expected, @"Parsed markup does not have expected attributes.");
}

- (void)testComplexString
{
    NSString *str = @"<h1>No blind <strong>spots</strong><strong></strong> in the leopard's eyes can <strong>only</strong> help to</h1> jeopardize the lives of lambs, the shepherd cries. An<h2> afterlife</h2><h2> for a silverfish. Eternal</h2> dust less ticklish.";
    
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"No blind spots in the leopard's eyes can only help to jeopardize the lives of lambs, the shepherd cries. An afterlife for a silverfish. Eternal dust less ticklish."];
    
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"$default"] range:NSMakeRange(0, 163)];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"h1"] range:NSMakeRange(0, 53)];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"strong"] range:NSMakeRange(9, 5)];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"strong"] range:NSMakeRange(14, 0)];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"strong"] range:NSMakeRange(41, 4)];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"h2"] range:NSMakeRange(107, 10)];
    [expected setAttributes:[[SLSMarkupParser defaultTagDefinitions] valueForKey:@"h2"] range:NSMakeRange(117, 26)];
    
    NSAttributedString *actual = [SLSMarkupParser stringByParsingTaggedString:str error:NULL];
    STAssertEqualObjects(actual, expected, @"Parsed markup does not have expected attributes.");
}

- (void)testUnknownTagProducesError
{
    NSError *error;
    STAssertNil([SLSMarkupParser stringByParsingTaggedString:@"<undefined>xyz</undefined>" error:&error], @"Expected error");
    STAssertNotNil(error, @"Expected error");
    STAssertEquals((SLSErrorCode)[error code], kSLSUnknownTagError, @"Incorrect error code");
}

- (void)testSyntaxErrorProducesError
{
    NSError *error;
    STAssertNil([SLSMarkupParser stringByParsingTaggedString:@"<h1>xyz" error:&error], @"Expected error");
    STAssertNotNil(error, @"Expected error");
    STAssertEquals((SLSErrorCode)[error code], kSLSSyntaxError, @"Incorrect error code");
}

@end
