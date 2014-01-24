//
//  UASlider.m
//  Diabetik
//
//  Based heavily on the mneuwert's ValueTrackingSlider
//  https://github.com/mneuwert/iOS-Custom-Controls/tree/master/ValueTrackingSlider
//
//  Created by Nial Giacomelli on 12/03/2013.
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

#import "UASlider.h"

@interface UASlider ()
@property (nonatomic, strong) UASliderPopoverView *popoverView;

// Logic
- (void)createPopover;

// Helpers
- (CGRect)thumbRect;
@end

@implementation UASlider
@synthesize popoverView = _popoverView;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _popoverView = nil;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _popoverView = nil;
    }
    return self;
}

#pragma mark - Logic
- (void)createPopover
{
    _popoverView = [[UASliderPopoverView alloc] initWithFrame:CGRectZero];
    _popoverView.backgroundColor = [UIColor clearColor];
    _popoverView.alpha = 1.0;
    [self.window addSubview:_popoverView];
}
- (void)setVisible:(BOOL)visible
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    if (visible)
    {
        _popoverView.alpha = 1.0;
    }
    else
    {
        _popoverView.alpha = 0.0;
    }
    [UIView commitAnimations];
}
- (void)updatePosition
{
    if(!_popoverView) [self createPopover];
    
    CGRect _thumbRect = self.thumbRect;
    CGRect popupRect = CGRectOffset(_thumbRect, 0, -floorf(_thumbRect.size.height * 1.5));
    _popoverView.frame = CGRectInset([self convertRect:popupRect toView:nil], -20, -10);
    _popoverView.value = self.value;
}

#pragma mark - UIControl overrides
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL state = [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint touchPoint = [touch locationInView:self];
    if(CGRectContainsPoint(CGRectInset(self.thumbRect, -12.0, -12.0), touchPoint))
    {
        [self updatePosition];
        [self setVisible:YES];
    }
    return state;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL state = [super continueTrackingWithTouch:touch withEvent:event];
    [self updatePosition];
    return state;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setVisible:NO];
    [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark - Helpers
- (CGRect)thumbRect
{
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbR = [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
    return thumbR;
}

@end

@implementation UASliderPopoverView
@synthesize value = _value;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont boldSystemFontOfSize:18];
    }
    return self;
}

#pragma mark - Logic
- (void)setValue:(float)aValue
{
    _value = aValue;
    self.text = [NSString stringWithFormat:@"%4.2f", _value];
    [self setNeedsDisplay];
}

#pragma mark - Rendering
- (void)drawRect:(CGRect)rect
{
    // Set the fill color
	[[UIColor colorWithWhite:0 alpha:0.8] setFill];
    
    // Create the path for the rounded rectangle
    CGRect roundedRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, floorf(self.bounds.size.height * 0.8));
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:6.0];
    
    // Create the arrow path
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat midX = CGRectGetMidX(self.bounds);
    CGPoint p0 = CGPointMake(midX, CGRectGetMaxY(self.bounds));
    [arrowPath moveToPoint:p0];
    [arrowPath addLineToPoint:CGPointMake((midX - 10.0), CGRectGetMaxY(roundedRect))];
    [arrowPath addLineToPoint:CGPointMake((midX + 10.0), CGRectGetMaxY(roundedRect))];
    [arrowPath closePath];
    
    // Attach the arrow path to the rounded rect
    [roundedRectPath appendPath:arrowPath];
    [roundedRectPath fill];
    
    // Draw the text
    if (self.text)
    {
        [[UIColor colorWithWhite:1 alpha:0.8] set];
        CGSize s = [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
        CGFloat yOffset = (roundedRect.size.height - s.height) / 2;
        CGRect textRect = CGRectMake(roundedRect.origin.x, yOffset, roundedRect.size.width, s.height);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        [self.text drawInRect:textRect withAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: paragraphStyle}];
    }
}

@end