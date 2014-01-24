//
//  UADateButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/05/2013.
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

#import <QuartzCore/QuartzCore.h>
#import "UADateButton.h"

@implementation UADateButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setAdjustsImageWhenHighlighted:NO];
        [[self titleLabel] setFont:[UAFont standardDemiBoldFontWithSize:14.0f]];
        [self setTitleColor:[UIColor colorWithRed:115.0f/255.0f green:127.0f/255.0f blue:123.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"ReportsDateButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13.0f, 13.0f, 14.0f, 13.0f)] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"ReportsDateButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13.0f, 13.0f, 14.0f, 13.0f)] forState:UIControlStateHighlighted];
    }
    return self;
}

@end
