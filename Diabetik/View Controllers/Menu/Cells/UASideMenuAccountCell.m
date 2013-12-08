//
//  UASideMenuAccountCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 01/04/2013.
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

#import <QuartzCore/QuartzCore.h>
#import "UASideMenuAccountCell.h"

@implementation UASideMenuAccountCell

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accessoryIcon.contentMode = UIViewContentModeScaleToFill;
    self.accessoryIcon.frame = CGRectMake(14.0f, 11.0f, 20.0f, 20.0f);
    self.accessoryIcon.layer.cornerRadius = 10.0f;
    self.accessoryIcon.layer.masksToBounds = YES;
}

@end
