//
//  UATooltipViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 29/12/2012.
//  Copyright (c) 2013-2014 Nial Giacomelli
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <QuartzCore/QuartzCore.h>
#import "UATooltipViewController.h"

@interface UATooltipViewController ()
{
    UIButton *closeButton;
}
@property (nonatomic, strong) UAModalViewPane *pane;
@property (nonatomic, assign) BOOL isDismissing;

@end

@implementation UATooltipViewController

#pragma mark - Setup
- (id)initWithParentVC:(UIViewController *)parentVC andDelegate:(id <UATooltipViewControllerDelegate>)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.isDismissing = NO;
        self.delegate = delegate;
        self.automaticallyAdjustsScrollViewInsets = NO;
    
        [self willMoveToParentViewController:self];
        [parentVC addChildViewController:self];
        [parentVC.view addSubview:self.view];
        [self didMoveToParentViewController:self];
    }
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.pane = [[UAModalViewPane alloc] initWithFrame:CGRectZero];
    self.pane.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [baseView addSubview:self.pane];
    
    self.contentContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.pane addSubview:self.contentContainerView];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [closeButton setImage:[UIImage imageNamed:@"TooltipIconClose"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"TooltipIconClosePressed"] forState:UIControlStateHighlighted];
    [closeButton setAdjustsImageWhenHighlighted:NO];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.pane addSubview:closeButton];
   
    self.view = baseView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    closeButton.frame = CGRectMake(self.pane.frame.size.width-40, 0, 40, 50);
    self.contentContainerView.frame = CGRectMake(0, 0, self.pane.frame.size.width, self.pane.frame.size.height);
}

#pragma mark - Logic
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}
- (void)setContentView:(UATooltipView *)view
{
    view.modalViewController = self;
    view.frame = CGRectMake(0, 0, self.contentContainerView.frame.size.width, self.contentContainerView.frame.size.height);
    [self.contentContainerView addSubview:view];
    
    [view setNeedsLayout];
}
- (void)present
{
    self.isDismissing = NO;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(willDisplayModalView:)])
    {
        [self.delegate willDisplayModalView:self];
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGSize size = CGSizeMake(400.0f, 480.0f);
        self.pane.frame = CGRectMake(self.view.bounds.size.width/2.0f - size.width/2.0f, self.view.bounds.size.height/2.0f - size.height/2.0f, size.width, size.height);
    }
    else
    {
        self.pane.frame = CGRectInset(self.view.frame, 15, 30);
    }
    self.contentContainerView.frame = CGRectMake(0, 0, self.pane.frame.size.width, self.pane.frame.size.height);
    
    CGRect paneFrame = self.pane.frame;
    paneFrame.origin.y = self.view.frame.size.height;
    self.pane.frame = paneFrame;
    
    // Animate overlay
    [UIView animateWithDuration:0.5 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    } completion:nil];
    
    // Animate pane in
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect paneFrame = self.pane.frame;
        paneFrame.origin.y = self.view.bounds.size.height/2.0f - paneFrame.size.height/2.0f;
        self.pane.frame = paneFrame;
        
    } completion:nil];
}
- (void)dismiss
{
    if(self.isDismissing) return;
    
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"pop-view"];
    
    self.isDismissing = YES;
    
    // Animate overlay out
    [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    } completion:nil];
    
    // Animate pane out
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect paneFrame = self.pane.frame;
        paneFrame.origin.y = self.view.frame.size.height;
        self.pane.frame = paneFrame;
        
    } completion:^(BOOL finished) {
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didDismissModalView:)])
        {
            [self.delegate didDismissModalView:self];
        }
        
        [self.view removeFromSuperview];
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
        [self didMoveToParentViewController:nil];
    }];
}

#pragma mark - UIViewController methods
- (void)willMoveToParentViewController:(UIViewController *)parentVC
{
    if(parentVC)
    {
        self.view.frame = parentVC.view.bounds;
    }
}

@end

@implementation UAModalViewPane

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

@end
