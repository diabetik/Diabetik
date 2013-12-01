//
//  UADragMenuViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 29/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UADragMenuViewController.h"

@implementation UADragMenuViewController

#pragma mark - Setup
- (id)initWithContentViewController:(UIViewController *)vc andMenuViewController:(UIViewController *)menuVC
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        self.contentViewController = vc;
        
        [self addChildViewController:self.contentViewController];
        self.contentViewController.view.frame = self.view.frame;
        [self.view addSubview:self.contentViewController.view];
        [self.contentViewController didMoveToParentViewController:self];
    }
    
    return self;
}
@end
