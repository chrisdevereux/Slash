//
//  SLSParseContext.h
//  Slash
//
//  Created by Chris Devereux on 29/01/2013.
//  Copyright (c) 2013 ChrisDevereux. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLSTaggedRange;


@interface SLSTagParser : NSObject

- (void)parseMarkup:(NSString *)markup;


// Callbacks from parser function:

- (void)addTag:(SLSTaggedRange *)tag;
- (void)appendString:(NSString *)string;

@property (assign, readonly, nonatomic) NSUInteger currentLength;


// Parse result:

// Set after parseMarkup: is called.
// Contains instances of SLSTaggedRange, ordered where each occures before
// any tagged ranges it contains.
@property (strong, readonly, nonatomic) NSArray *taggedRanges;

// Set after parseMarkup: is called.
// An instance of NSMutableAttributedString containing the input text,
// stripped of any markup tags, without any attributes applied.
@property (strong, readonly, nonatomic) NSMutableAttributedString *attributedString;

// Set after parseMarkup is called.
// Either an error or nil if the parse was successful.
@property (strong, nonatomic) NSError *error;

@end


OBJC_EXTERN void SLSTagParser_error(void *scanner, SLSTagParser *ctx, const char *msg);

