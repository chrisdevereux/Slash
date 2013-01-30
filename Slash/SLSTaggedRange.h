//
//  SLSTaggedRange.h
//  Slash
//
//  Created by Chris Devereux on 29/01/2013.
//  Copyright (c) 2013 ChrisDevereux. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLSTaggedRange : NSObject

+ (instancetype)tagWithName:(NSString *)tagName range:(NSRange)range;

@property (copy, readonly, nonatomic) NSString *tagName;
@property (assign, readonly, nonatomic) NSRange range;

@end
