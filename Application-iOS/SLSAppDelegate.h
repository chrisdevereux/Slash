//
//  SLSAppDelegate.h
//  Application-iOS
//
//  Created by Chris Devereux on 14/12/2012.
//  Copyright (c) 2012 ChrisDevereux. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSViewController;

@interface SLSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SLSViewController *viewController;

@end
