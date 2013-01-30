//
//  SLSTaggedRange.m
//  Slash
//
//  Created by Chris Devereux on 29/01/2013.
//  Copyright (c) 2013 ChrisDevereux. All rights reserved.
//

#import "SLSTaggedRange.h"

@interface SLSTaggedRange ()
@property (copy, nonatomic) NSString *tagName;
@property (assign, nonatomic) NSRange range;
@end


@implementation SLSTaggedRange

+ (instancetype)tagWithName:(NSString *)tagName range:(NSRange)range
{
    SLSTaggedRange *taggedRange = [[self alloc] init];
    
    taggedRange.tagName = tagName;
    taggedRange.range = range;
    
    return taggedRange;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", _tagName, NSStringFromRange(_range)];
}

@end
