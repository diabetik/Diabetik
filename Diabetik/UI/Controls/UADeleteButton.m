//
//  UADeleteButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 26/02/2013.
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

#import "UADeleteButton.h"

@implementation UADeleteButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *buttonBG = [[UIImage imageNamed:@"DeleteBtn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f)];
        UIImage *buttonHighlightedBG = [[UIImage imageNamed:@"DeleteBtnPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f)];
        
        [self setBackgroundImage:buttonBG forState:UIControlStateNormal];
        [self setBackgroundImage:buttonHighlightedBG forState:UIControlStateHighlighted];
        
        self.titleLabel.font = [UAFont standardBoldFontWithSize:17.0f];
        self.titleLabel.shadowColor = [UIColor colorWithRed:167.0f/255.0f green:16.0f blue:16.0f alpha:1.0f];
        self.titleLabel.shadowOffset = CGSizeMake(0, -1);
    }
    return self;
}

#pragma mark - Accessors
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:[title uppercaseString] forState:state];
}

@end
