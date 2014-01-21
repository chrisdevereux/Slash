//
//  SLSViewController.m
//  Slash
//
//  Created by Chris Devereux on 14/12/2012.
//  Copyright (c) 2012 Chris Devereux. All rights reserved.
//

#import "SLSViewController.h"
#import <Slash/Slash.h>

@interface SLSViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *markupView;
@property (strong, nonatomic) IBOutlet UILabel *displayView;
@property (strong, nonatomic) IBOutlet UIView *errorMarker;
@end

@implementation SLSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground:)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapBackground:(UIGestureRecognizer *)_
{
    [self.markupView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSAttributedString *attributedString = [SLSMarkupParser attributedStringWithMarkup:textView.text error:NULL];
    
    if (attributedString) {
        self.displayView.attributedText = attributedString;
    }
    
    self.errorMarker.hidden = (attributedString != nil);
}

@end
