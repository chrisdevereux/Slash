//
//  SLSAppDelegate.m
//  Application-OSX
//
//  Created by Chris Devereux on 13/12/2012.
//  Copyright (c) 2012 ChrisDevereux. All rights reserved.
//

#import "SLSAppDelegate.h"
#import "SLSMarkupParser.h"

@interface SLSAppDelegate () <NSTextViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet NSTextView *displayView;
@property (unsafe_unretained, nonatomic) IBOutlet NSTextView *markupView;
@property (unsafe_unretained, nonatomic) IBOutlet NSView *errorMarker;
@end


@implementation SLSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)textDidChange:(NSNotification *)notification
{
    NSAttributedString *str = [SLSMarkupParser stringByParsingTaggedString:self.markupView.string error:NULL];
    
    if (str) {
        [self.displayView.textStorage setAttributedString:str];
    }
    
    [self.errorMarker setHidden:str != nil];
}

@end
