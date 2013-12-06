//
//  UAKeyboardBackingView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/03/2013.
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
#import "UAKeyboardBackingView.h"

@interface UAKeyboardBackingView ()
{
    UISwipeGestureRecognizer *keyboardSwipeGestureRecognizer;
    NSInteger keyboardState;
}
@end

@implementation UAKeyboardBackingView
@synthesize controlContainer = _controlContainer;
@synthesize keyboardToggleButton = _keyboardToggleButton;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame andButtons:(NSArray *)theButtons
{
    frame.size.height += kAccessoryViewHeight;
    frame.origin.y -= kAccessoryViewHeight;
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:36.0f/255.0f green:36.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
        self.buttons = theButtons;
        
        _controlContainer = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - (26.0f+12.0f), 0.0f, (26.0f+12.0f), kAccessoryViewHeight)];
        _controlContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:_controlContainer];
        
        UIView *backingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kAccessoryViewHeight, frame.size.width, frame.size.height)];
        backingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
        [self addSubview:backingView];
        
        _keyboardToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 26.0f, 33.0f)];
        [_keyboardToggleButton setImage:[UIImage imageNamed:@"KeyboardDismissDownButton.png"] forState:UIControlStateNormal];
        [_keyboardToggleButton setImage:[UIImage imageNamed:@"KeyboardDismissDownButtonPressed.png"] forState:UIControlStateHighlighted];
        [_keyboardToggleButton addTarget:self action:@selector(keyboardTogglePress:) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardToggleButton setAdjustsImageWhenHighlighted:NO];
        //[_keyboardToggleButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 30.0f, 0.0f, 0.0f)];
        
        [_controlContainer addSubview:_keyboardToggleButton];
        
        keyboardSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        keyboardSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:keyboardSwipeGestureRecognizer];
        
        keyboardState = kKeyboardHidden;
        for(UAKeyboardBackingViewButton *button in self.buttons)
        {
            [self addSubview:button];
        }
        
        /*
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddEntryKeyboardShadow.png"]];
        shadowImageView.frame = CGRectMake(0.0f, _controlContainer.frame.size.height, self.frame.size.width, 4.0f);
        [self addSubview:shadowImageView];
        */
        
        [self setNeedsLayout];
    }
    return self;
}
- (void)dealloc
{
    [self removeGestureRecognizer:keyboardSwipeGestureRecognizer];
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat buttonWidth = floorf(self.frame.size.width/kButtonsPerRow);
    CGFloat buttonHeight = floorf((self.frame.size.height-kAccessoryViewHeight-1.0f)/([self.buttons count]/kButtonsPerRow));
    
    CGFloat x = 0.0f, y = kAccessoryViewHeight + 1.0f;
    NSInteger row = 0;
    for(UAKeyboardBackingViewButton *button in self.buttons)
    {
        button.frame = CGRectMake(x, y, buttonWidth, buttonHeight);
        x += buttonWidth + 1.0f;
        row ++;
        
        if(row >= kButtonsPerRow)
        {
            x = 0.0f;
            row = 0;
            y += buttonHeight + 1.0f;
        }
    }
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, kAccessoryViewHeight), point))
    {
        if(!CGRectContainsPoint(_controlContainer.frame, point))
        {
            return NO;
        }
    }
    
    return [super pointInside:point withEvent:event];
}
- (void)setKeyboardState:(NSInteger)state
{
    if(state == kKeyboardHidden)
    {
        [_keyboardToggleButton setImage:[UIImage imageNamed:@"KeyboardDismissUpButton.png"] forState:UIControlStateNormal];
        [_keyboardToggleButton setImage:[UIImage imageNamed:@"KeyboardDismissUpButtonPressed.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        [_keyboardToggleButton setImage:[UIImage imageNamed:@"KeyboardDismissDownButton.png"] forState:UIControlStateNormal];
        [_keyboardToggleButton setImage:[UIImage imageNamed:@"KeyboardDismissDownButtonPressed.png"] forState:UIControlStateHighlighted];
    }
    
    keyboardState = state;
}
- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if(keyboardState == kKeyboardHidden)
    {
        [self.delegate presentKeyboard];
    }
}

#pragma mark - UI
- (void)keyboardTogglePress:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    if(keyboardState == kKeyboardHidden)
    {
        [self.delegate presentKeyboard];
    }
    else
    {
        [self.delegate dismissKeyboard];
    }
}

@end
