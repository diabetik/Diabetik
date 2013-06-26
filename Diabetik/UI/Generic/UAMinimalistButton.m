//
//  UAMinimalistButton.m
//  Diabetting
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

#import "UAMinimalistButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation UAMinimalistButton
@synthesize labelColor, labelSelectedColor;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
        
        self.labelColor = [UIColor colorWithRed:115.0f/255.0f green:127.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
        self.labelSelectedColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
        
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f];
        self.titleLabel.textColor = self.labelSelectedColor;
        self.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
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
- (void)updateState
{
    if([self isHighlighted] || [self isSelected])
    {
        self.titleLabel.textColor = self.labelSelectedColor;
    }
    else
    {
        self.titleLabel.textColor = self.labelColor;
    }
}
- (void)setLabelColor:(UIColor *)aColor
{
    labelColor = aColor;
    self.titleLabel.textColor = aColor;
    
    [self setNeedsDisplay];
}
@end
