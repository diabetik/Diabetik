//
//  UABadgeView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 26/01/2014.
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

#import "UABadgeView.h"

@interface UABadgeView ()
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

// Rendering
//- (void)drawRoundedRectWithContext:(CGContextRef)context withRect:(CGRect)rect;
@end

@implementation UABadgeView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        _textColor = [UIColor colorWithRed:199.0f/255.0f green:199.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
        _badgeColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        _highlightedTextColor = [UIColor whiteColor];
        _highlightedBadgeColor = [UIColor whiteColor];
        
        _font = [UAFont standardRegularFontWithSize:12.0f];
        _badgePadding = 5;
        _badgeCornerRadius = 0.5;
        
        self.paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [self.paragraphStyle setAlignment:NSTextAlignmentCenter];
        [self.paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        self.layer.borderWidth = 2;
        self.layer.borderColor = self.badgeColor.CGColor;
        self.layer.cornerRadius = 5;
    }
    
    return self;
}

#pragma mark - Rendering
- (void)drawRect:(CGRect)rect
{
    if(self.value)
    {
        //CGContextRef context = UIGraphicsGetCurrentContext();
        //[self drawRoundedRectWithContext:context withRect:rect];
        
        CGSize valueSize = [self.value sizeWithAttributes:@{NSFontAttributeName: self.font}];
        [self.value drawInRect:CGRectMake(self.badgePadding, (rect.size.height / 2.0) - (valueSize.height / 2.0), rect.size.width - (self.badgePadding*2.0f), valueSize.height)
                withAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.highlighted ? self.highlightedTextColor : self.textColor, NSParagraphStyleAttributeName: self.paragraphStyle}];
    }
}
/*
- (void)drawRoundedRectWithContext:(CGContextRef)context withRect:(CGRect)rect
{
    CGContextSaveGState(context);
    
    CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRadius;
    CGFloat puffer = 0.0f; //CGRectGetMaxY(rect)*0.10;
    CGFloat maxX = CGRectGetMaxX(rect) - puffer;
    CGFloat maxY = CGRectGetMaxY(rect) - puffer;
    CGFloat minX = CGRectGetMinX(rect) + puffer;
    CGFloat minY = CGRectGetMinY(rect) + puffer;
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 3);
    CGContextSetStrokeColorWithColor(context, self.highlighted ? [self.highlightedBadgeColor CGColor] : [self.badgeColor CGColor]);
    CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
    CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
    CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
    CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}
*/

#pragma mark - Accessors
- (void)setValue:(NSString *)newValue
{
    _value = newValue;
    
    CGSize valueSize = [_value sizeWithAttributes:@{NSFontAttributeName: self.font, NSParagraphStyleAttributeName: self.paragraphStyle}];
    if(valueSize.width < 25.0f)
    {
        valueSize.width = 25.0f;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, valueSize.width + self.badgePadding*2.0f, self.frame.size.height);
}
- (void)setTextColor:(UIColor *)newTextColor
{
    _textColor = newTextColor;
    [self setNeedsDisplay];
}
- (void)setBadgeColor:(UIColor *)newBadgeColor
{
    _badgeColor = newBadgeColor;
    [self setNeedsDisplay];
}
- (void)setHighlighted:(BOOL)state
{
    _highlighted = state;
    
    self.layer.borderColor = state ? self.highlightedBadgeColor.CGColor : self.badgeColor.CGColor;
    
    [self setNeedsDisplay];
}

@end
