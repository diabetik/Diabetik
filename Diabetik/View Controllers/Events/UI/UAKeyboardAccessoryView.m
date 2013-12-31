//
//  UAKeyboardAccessoryView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 20/03/2013.
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

#import "UAKeyboardAccessoryView.h"

@interface UAKeyboardAccessoryView ()
@property (nonatomic, retain) UAKeyboardBackingView *backingView;

@end

@implementation UAKeyboardAccessoryView
@synthesize backingView = _backingView;
@synthesize contentView = _contentView;

#pragma mark - Setup
- (id)initWithBackingView:(UAKeyboardBackingView *)aBackingView
{
    self = [super initWithFrame:CGRectMake(0, 0, aBackingView.frame.size.width, 48.0f)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
        _backingView = aBackingView;        
        
        CGRect contentViewFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            contentViewFrame.size.width -= 50.0f;
        }
        _contentView = [[UIView alloc] initWithFrame:contentViewFrame];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
    }
    return self;
}

#pragma mark - Logic
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        CGRect button = CGRectMake(self.frame.size.width - self.backingView.keyboardToggleButton.frame.size.width, 0.0f, self.backingView.keyboardToggleButton.frame.size.width, self.frame.size.height);
        
        if(CGRectContainsPoint(button, point))
        {
            return NO;
        }
    }
    
    BOOL pointInsideContentViewChild = NO;
    for(UIView *view in [self.contentView subviews])
    {
        if(CGRectContainsPoint(view.frame, point))
        {
            pointInsideContentViewChild = YES;
            break;
        }
    }
    
    if(!pointInsideContentViewChild)
    {
        return NO;
    }
    
    return [super pointInside:point withEvent:event];
}

@end
