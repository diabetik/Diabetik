//
//  UANavSubtitleHeaderView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 08/04/2013.
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

#import "UANavSubtitleHeaderView.h"

@implementation UANavSubtitleHeaderView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 6.0f, frame.size.width, 16.0f)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UAFont standardBoldFontWithSize:15.0f];
        _titleLabel.shadowColor = [UIColor colorWithRed:26.0f/255.0f green:148.0f/255.0f blue:111.0f/255.0f alpha:1.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 22.0f, frame.size.width, 16.0f)];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.font = [UAFont standardDemiBoldFontWithSize:13.0f];
        _subtitleLabel.shadowColor = [UIColor colorWithRed:26.0f/255.0f green:148.0f/255.0f blue:111.0f/255.0f alpha:1.0];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_titleLabel];
        [self addSubview:_subtitleLabel];
    }
    return self;
}

#pragma mark - Logic
- (void)setTitle:(NSString *)title
{
    _titleLabel.text = [title uppercaseString];
}
- (void)setSubtitle:(NSString *)subtitle
{
    _subtitleLabel.text = subtitle;
}

@end