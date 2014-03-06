//
//  UAUIHintView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 12/05/2013.
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
#import "UAUIHintView.h"

@interface UAUIHintView ()
{
    UIView *containerView;
    
    BOOL isRemoving;
    UAUIHintCallback presentCallback;
    UAUIHintCallback dismissCallback;
}

@property (nonatomic, retain) UILabel *label;
@end

@implementation UAUIHintView
@synthesize label = _label;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame text:(NSString *)text presentationCallback:(UAUIHintCallback)present dismissCallback:(UAUIHintCallback)dismiss
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        isRemoving = NO;
        presentCallback = present;
        dismissCallback = dismiss;

        containerView = [[UIView alloc] initWithFrame:CGRectMake(15.0f, frame.size.height/2.0f - 20.0f, frame.size.width-30.0f, 40.0f)];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        containerView.alpha = 0.0f;
        
        UIView *messageBackground = [[UIView alloc] initWithFrame:containerView.bounds];
        messageBackground.layer.cornerRadius = 20.0f;
        messageBackground.backgroundColor = [UIColor colorWithRed:21.0f/255.0f green:207.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        [containerView addSubview:messageBackground];
                                     
        _label = [[UILabel alloc] initWithFrame:CGRectInset(messageBackground.frame, 10.0f, 0.0f)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UAFont standardDemiBoldFontWithSize:16.0f];
        _label.text = text;
        _label.adjustsFontSizeToFitWidth = YES;
        [messageBackground addSubview:_label];
        [self addSubview:containerView];
    }
    return self;
}

#pragma mark - Logic
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(!isRemoving) [self dismiss];
    return NO;
}
- (void)present
{
    [UIView animateWithDuration:0.25 animations:^{
        presentCallback();
        
        containerView.alpha = 1.0f;
    }];
}
- (void)dismiss
{
    if(isRemoving) return;
    
    dismissCallback();
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.75 animations:^{
        containerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_4);
        containerView.frame = CGRectMake(-weakSelf.frame.size.width/4.0f, weakSelf.label.frame.origin.y+weakSelf.frame.size.height*2, weakSelf.label.frame.size.width, weakSelf.label.frame.size.height);
        containerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    isRemoving = YES;
}

@end
