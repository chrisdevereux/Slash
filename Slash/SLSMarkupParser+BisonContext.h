//
//  SLSMarkupParser+BisonContext.h
//  Slash
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 Chris Devereux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSMarkupParser.h"
#import "SLSMarkupLexer.gen.h"

@interface SLSMarkupParser (SLSBisonContext)

@property (strong, readonly, nonatomic) NSMutableAttributedString *outAttStr;
@property (strong, nonatomic) NSError *error;

- (id)initWithTagDictionary:(NSDictionary *)tagDict;
- (NSAttributedString *)parseString:(NSString *)string;

- (void)addAttributesForTag:(NSString *)tag inRange:(NSRange)range;

@end

OBJC_EXTERN void slasherror(yyscan_t scanner, SLSMarkupParser *ctx, const char *msg);
