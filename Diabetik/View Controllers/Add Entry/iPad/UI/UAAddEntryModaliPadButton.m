//
//  UAAddEntryModaliPadButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 16/01/2014.
//  Copyright 2014 Nial Giacomelli
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

#import "UAAddEntryModaliPadButton.h"

@implementation UAAddEntryModaliPadButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UAFont standardRegularFontWithSize:18.0f];

        [self setTitleColor:[UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25.0f, 0)];
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0.0f, self.bounds.size.height-20.0f, self.bounds.size.width, 20.0f);
    self.imageView.frame = CGRectMake(0.0f, 0.0f, 105.0f, 105.0f);
}

@end
