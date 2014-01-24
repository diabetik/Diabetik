//
//  UASettingsTextViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/12/2013.
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

#import "UASettingsTextViewCell.h"

@implementation UASettingsTextViewCell

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accessoryView.frame = CGRectInset(self.bounds, 15.0f, 0.0f);
}

@end
