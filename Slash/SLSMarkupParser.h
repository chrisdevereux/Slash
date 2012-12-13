//
//  SLSMarkupParser.h
//  SLSMarkup
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 Unbounded. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLSMarkupParser : NSObject

+ (NSAttributedString *)stringByParsingTaggedString:(NSString *)string withTagDefinitions:(NSDictionary *)defs error:(NSError **)error;
+ (NSAttributedString *)stringByParsingTaggedString:(NSString *)string error:(NSError **)error;

+ (NSDictionary *)defaultTagDefinitions;

@end

OBJC_EXTERN NSString * const SLSErrorDomain;
typedef enum {
    kSLSSyntaxError = 1,
    kSLSUnknownTagError
} SLSErrorCode;
