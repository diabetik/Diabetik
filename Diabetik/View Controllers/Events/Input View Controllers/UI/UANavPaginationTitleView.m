//
//  UANavPaginationTitleView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 21/04/2013.
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

#import "UANavPaginationTitleView.h"

@implementation UANavPaginationTitleView
@synthesize titleLabel = _titleLabel;
@synthesize pageControl = _pageControl;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 6.0f, frame.size.width, 16.0f)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UAFont standardDemiBoldFontWithSize:16.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        
        _pageControl = [[UANavPageControl alloc] initWithFrame:CGRectMake(0.0f, 25.0f, frame.size.width, 16.0f)];
            
        [self addSubview:_titleLabel];
        [self addSubview:_pageControl];
    }
    return self;
}

#pragma mark - Logic
- (void)setTitle:(NSString *)title
{
    _titleLabel.text = [title uppercaseString];
}

@end
