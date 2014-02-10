//
//  UAAddEntryModalButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 06/04/2013.
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

#import "UAAddEntryModalButton.h"

#define kLabelSpacing 20.0f

@implementation UAAddEntryModalButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
        self.titleLabel.font = [UAFont standardMediumFontWithSize:15.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        //[self setTitleColor:[UIColor colorWithRed:143.0f/255.0f green:153.0f/255.0f blue:150.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:119.0f/255.0f green:127.0f/255.0f blue:125.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(floorf(self.bounds.size.width/2-self.imageView.image.size.width/2), floorf(self.bounds.size.height/2 - self.imageView.image.size.height/2)-kLabelSpacing, self.imageView.image.size.width, self.imageView.image.size.height);
    self.titleLabel.frame = CGRectMake(0.0f, floorf(self.frame.size.height/2 + kLabelSpacing), self.frame.size.width, 18.0f);
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:244.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
    }
}
- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if(enabled)
    {
        [self setTitleColor:[UIColor colorWithRed:148.0f/255.0f green:148.0f/255.0f blue:148.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    else
    {
        [self setTitleColor:[UIColor colorWithRed:97.0f/255.0f green:97.0f/255.0f blue:97.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
}
@end
