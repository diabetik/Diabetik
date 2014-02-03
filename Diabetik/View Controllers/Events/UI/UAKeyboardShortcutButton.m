//
//  UAKeyboardShortcutButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 31/01/2014.
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

#import "UAKeyboardShortcutButton.h"

@implementation UAKeyboardShortcutButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:219.0f/255.0f alpha:1.0f].CGColor;
        self.layer.cornerRadius = 3.0f;
        self.layer.borderWidth = 0.5f;
        self.layer.masksToBounds = YES;
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.tintColor = [UIColor redColor];
    }
    return self;
}

#pragma mark - Logic
- (void)setHighlighted:(BOOL)highlighted
{
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Accessors
- (UIImageView *)fullsizeImageView
{
    if(!_fullsizeImageView)
    {
        _fullsizeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _fullsizeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fullsizeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self insertSubview:_fullsizeImageView aboveSubview:self.imageView];
    }
    
    return _fullsizeImageView;
}

@end
