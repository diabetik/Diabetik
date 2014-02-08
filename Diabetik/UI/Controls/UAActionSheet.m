//
//  UAActionSheet.m
//  Diabetik
//
//  Created by Nial Giacomelli on 04/02/2014.
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

#import "UAActionSheet.h"

@implementation UAActionSheet

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.acceptsFirstResponder = YES;
    }
    
    return self;
}

#pragma mark - Accessors
- (BOOL)canBecomeFirstResponder
{
    return self.acceptsFirstResponder;
}

@end
