//
//  UAAutocompleteBarButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/12/2012.
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

#import "UAAutocompleteBarButton.h"
#import <QuartzCore/QuartzCore.h>

@interface UAAutocompleteBarButton ()
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIColor *labelSelectedColor;

// Logic
- (void)updateState;

@end

@implementation UAAutocompleteBarButton
@synthesize labelColor = _labelColor;
@synthesize labelSelectedColor = _labelSelectedColor;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImage *normalBG = [[UIImage imageNamed:@"AccessoryViewBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f)];
        UIImage *highlightedBG = [[UIImage imageNamed:@"AccessoryViewBubblePressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f)];
        [self setBackgroundImage:normalBG forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedBG forState:UIControlStateHighlighted];
        [self setBackgroundImage:highlightedBG forState:UIControlStateSelected];
        [self setBackgroundImage:highlightedBG forState:UIControlStateHighlighted | UIControlStateSelected];
        
        self.labelColor = [UIColor colorWithRed:115.0f/255.0f green:127.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
        self.labelSelectedColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UAFont standardDemiBoldFontWithSize:14.0f];
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        
        [self setAdjustsImageWhenHighlighted:NO];
        [self setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.6f] forState:UIControlStateNormal];
        [self setTitleColor:self.labelColor forState:UIControlStateNormal];
    }
    return self;
}

#pragma mark - Logic
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self updateState];
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self updateState];
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    CGFloat padding = 10.0f;
    CGSize newSize = [title sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newSize.width + (padding*2.0f), self.frame.size.height);
}
- (void)updateState
{
    if([self isHighlighted] || [self isSelected])
    {
        [self setTitleColor:self.labelSelectedColor forState:UIControlStateNormal];
    }
    else
    {
        [self setTitleColor:self.labelColor forState:UIControlStateNormal];
    }
}
- (void)setLabelColor:(UIColor *)aColor
{
    _labelColor = aColor;
    self.titleLabel.textColor = aColor;
    
    [self setNeedsDisplay];
}
@end
