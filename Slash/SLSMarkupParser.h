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
 
 
 When a piece of text belongs to multiple elements, the attributes applied 
 will be the union of each tag's dictionary, with the innermost elements'
 attributes taking priority.
 
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
 
 @important
 Note that on versions of iOS prior to 6.0, [SLSMarkupParser defaultStyle] returns nil,
 so this method will return an unformatted string.
*/
+ (NSAttributedString *)attributedStringWithMarkup:(NSString *)string
                                             error:(NSError **)error;

/**
 Returns a dictionary defining the tags h1,h2,h3,h4,h5,h6,em,strong in various
 sizes and styles of Helvetica Neue.
 
 @important
 On versions of iOS prior to 6.0, this method returns nil.
*/
+ (NSDictionary *)defaultStyle;

@end
