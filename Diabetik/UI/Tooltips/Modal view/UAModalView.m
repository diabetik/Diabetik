//
//  UAModalView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 29/12/2012.
//  Copyright 2013 Nial Giacomelli
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
#import "UAModalView.h"

@interface UAModalView ()
{
    UIButton *closeButton;
}
@property (nonatomic, strong) UAModalViewPane *pane;
@property (nonatomic, assign) BOOL isDismissing;

@end

@implementation UAModalView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.isDismissing = NO;
        
        self.pane = [[UAModalViewPane alloc] initWithFrame:CGRectInset(frame, 15, 30)];
        [self addSubview:self.pane];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pane.bounds.size.width, self.pane.bounds.size.height)];
        [self.pane addSubview:self.contentView];
        
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.pane.frame.size.width-40, 0, 40, 50)];
        [closeButton setImage:[UIImage imageNamed:@"TooltipIconClose.png"] forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"TooltipIconClosePressed.png"] forState:UIControlStateHighlighted];
        [closeButton setAdjustsImageWhenHighlighted:NO];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.pane addSubview:closeButton];
    }
    return self;
}

#pragma mark - Logic
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}
- (void)present
{
    self.isDismissing = NO;
    
    if([self.delegate respondsToSelector:@selector(willDisplayModalView:)])
    {
        [self.delegate willDisplayModalView:self];
    }
    
    CGRect paneFrame = self.pane.frame;
    paneFrame.origin.y = self.superview.frame.size.height;
    self.pane.frame = paneFrame;
    
    // Animate overlay
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    } completion:^(BOOL finished) {
    }];
    
    // Animate pane in
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect paneFrame = self.pane.frame;
        paneFrame.origin.y = 30.0f;
        self.pane.frame = paneFrame;
        
    } completion:^(BOOL finished) {
        //[self dismiss];
    }];
}
- (void)dismiss
{
    if(self.isDismissing) return;
    
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"pop-view"];
    
    self.isDismissing = YES;
    
    // Animate overlay out
    [UIView animateWithDuration:0.5 delay:0.3 options:0 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    } completion:^(BOOL finished) {
        
    }];
    
    // Animate pane out
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect paneFrame = self.pane.frame;
        paneFrame.origin.y = self.superview.frame.size.height;
        self.pane.frame = paneFrame;
        
    } completion:^(BOOL finished) {
        if([self.delegate respondsToSelector:@selector(didDismissModalView:)])
        {
            [self.delegate didDismissModalView:self];
        }
        [self removeFromSuperview];
    }];
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
