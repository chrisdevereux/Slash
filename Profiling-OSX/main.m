//
//  main.m
//  Profiling-OSX
//
//  Created by Chris Devereux on 09/02/2013.
//  Copyright (c) 2013 ChrisDevereux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSMarkupParser.h"

int main(int argc, const char * argv[])
{
    for (NSUInteger i = 0 ; i < 100000; i++) { @autoreleasepool {
        NSString *str = @"<h1>No blind <strong>spots</strong><strong></strong> in the leopard's eyes can <strong>only</strong> help to</h1> jeopardize the lives of lambs, the shepherd cries. An<h2> afterlife</h2><h2> for a silverfish. Eternal</h2> dust less ticklish.";
        
        [SLSMarkupParser attributedStringWithMarkup:str error:NULL];
    }}
    
    return 0;
}

