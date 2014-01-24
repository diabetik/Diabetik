//
//  UAShortcutButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/08/2013.
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

#import "UAShortcutButton.h"

@implementation UAShortcutButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setTitleColor:[UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        
        self.titleLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(floorf(self.bounds.size.width/2.0f - self.imageView.image.size.width/2.0f), floorf(self.bounds.size.height/2.0f - 39.0f), floorf(self.imageView.image.size.width), floorf(self.imageView.image.size.height));
    self.titleLabel.frame = CGRectMake(0, floorf(self.bounds.size.height/2.0f + 27.0f), self.bounds.size.width, 16.0f);
}

@end
