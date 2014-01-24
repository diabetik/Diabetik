//
//  UAGenericTableHeaderView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 16/03/2013.
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

#import "UAGenericTableHeaderView.h"

@interface UAGenericTableHeaderView ()
@property (nonatomic, retain) UILabel *label;
@end

@implementation UAGenericTableHeaderView
@synthesize label = _label;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, frame.size.height-24.0f, frame.size.width-40.0f, 16.0f)];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UAFont standardDemiBoldFontWithSize:14.0f];
        _label.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        
        [self addSubview:_label];
    }
    return self;
}

#pragma mark - Logic
- (void)setText:(NSString *)text
{
    _label.text = [text uppercaseString];
}

@end
