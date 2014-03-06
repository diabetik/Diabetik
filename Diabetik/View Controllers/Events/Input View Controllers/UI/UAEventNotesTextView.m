//
//  UAEventNotesTextView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 19/02/2013.
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

#import "UAEventNotesTextView.h"
#import "UAInputBaseViewController.h"

@implementation UAEventNotesTextView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setContentInset:UIEdgeInsetsMake(3.0f, 0.0f, 0.0f, 0.0f)];
    }
    return self;
}

#pragma mark - Logic
- (void)setContentOffset:(CGPoint)contentOffset
{
    [self setContentInset:UIEdgeInsetsMake(3.0f, 0.0f, 0.0f, 0.0f)];
    [super setContentOffset:contentOffset];
}
- (BOOL)canResignFirstResponder
{
    if(self.delegate)
    {
        UAInputBaseViewController *delegate = (UAInputBaseViewController *)self.delegate;
        return !delegate.parentVC.isDisplayingPopover;
    }
    
    return [super canResignFirstResponder];
}

@end
