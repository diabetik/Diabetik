//
//  UADragMenuViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 29/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UADragMenuViewController : UIViewController
@property (nonatomic, strong) UIViewController *contentViewController;

// Setup
- (id)initWithContentViewController:(UIViewController *)vc andMenuViewController:(UIViewController *)menuVC;

@end
