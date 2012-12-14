//
//  SLSMarkupParser.h
//  Slash
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 Chris Devereux. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLSMarkupParser : NSObject

/**
 Returns an NSAttributedString styled using _style_.
 
 Style dictionary keys should name a tag.
 
 Style dictionary values should be a dictionary mapping attribute 
 names to attribute values, suitable for passing to NSAttributedString's 
 setAttributes: method.
 
 Example:
     NSString *markup = @"This is <strong>awesome</strong>!"
     NSDictionary *style = @{
        @"strong": @{NSFontAttributeName  : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]}
     };
     
     NSAttributedString *attributedString = [SLSMarkupParser attributedStringWithMarkup:markup style:style error:NULL];
 
 
 If a region of text has multiple styles applied to it, the attributes of each
 will be applied, with the attributes of the innermost markup elements taking priority.
 
 As a convenience, you may provide a style with a $default key. The associated attributes will
 provide a base style for the whole string, as if you had enclosed your markup in
 with <$default></$default>
 */

+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)string
                                             style:(NSDictionary *)style
                                             error:(NSError **)error;

/**
 Returns an NSAttributedString styled using [SLSMarkupParser defaultStyle],
 or nil if an error occured.
*/
+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)string
                                             error:(NSError **)error;

/**
 Returns a dictionary defining the tags h1,h2,h3,h4,h5,h6,emp,strong in various
 sizes and styles of Helvetica Neue.
*/
+ (NSDictionary *)defaultStyle;

@end

typedef enum {
    kSLSSyntaxError = 1,
    kSLSUnknownTagError
} SLSErrorCode;

OBJC_EXTERN NSString * const SLSErrorDomain;
