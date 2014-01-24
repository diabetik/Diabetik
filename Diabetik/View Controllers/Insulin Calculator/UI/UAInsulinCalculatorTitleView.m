//
//  UAInsulinCalculatorTextFieldViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/12/2013.
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

#import "UAInsulinCalculatorTitleView.h"

@implementation UAInsulinCalculatorTitleView
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = [NSLocalizedString(@"Insulin Calculator", nil) uppercaseString];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UAFont standardDemiBoldFontWithSize:17.0f];
        _subtitleLabel = [[UILabel alloc] initWithFrame:frame];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.font = [UAFont standardDemiBoldFontWithSize:17.0f];
        _subtitleLabel.hidden = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:_titleLabel];
        [self addSubview:_subtitleLabel];
        [self layoutSubviews];
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(_subtitleLabel.text.length)
    {
        _titleLabel.font = [UAFont standardDemiBoldFontWithSize:12.0f];
        _titleLabel.frame = CGRectMake(0.0f, 2.0f, self.bounds.size.width, 16.0f);
        _subtitleLabel.frame = CGRectMake(0.0f, 20.0f, self.bounds.size.width, 16.0f);
        _subtitleLabel.hidden = NO;
    }
    else
    {
        _titleLabel.font = [UAFont standardDemiBoldFontWithSize:17.0f];
        _titleLabel.frame = self.bounds;
    }
}

#pragma mark - Accessors
- (void)setTitle:(NSString *)theTitle
{
    _titleLabel.text = theTitle;
    [self setNeedsLayout];
}
- (void)setSubtitle:(NSString *)theSubtitle
{
    _subtitleLabel.text = theSubtitle;
    [self setNeedsLayout];
}
@end
