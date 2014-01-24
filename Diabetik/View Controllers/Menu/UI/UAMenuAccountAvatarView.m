//
//  UAMenuAccountAvatarView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 29/11/2013.
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

#import "UAMenuAccountAvatarView.h"

@implementation UAMenuAccountAvatarView

#pragma mark - Setup
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if(self)
    {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.layer.cornerRadius = 45.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 4.0f;
        self.clipsToBounds = YES;
    }
    
    return self;
}
@end
