//
//  UAInputLabel.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/03/2013.
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

#import "UAInputLabel.h"

@implementation UAInputLabel

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Logic
- (BOOL)isUserInteractionEnabled
{
    return YES;
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate inputLabelDidBeginEditing:self];
    [self becomeFirstResponder];
}

@end
