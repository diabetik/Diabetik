//
//  UASyncController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 04/01/2014.
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

#import "SSKeychain.h"
#import "UAAnalytikController.h"
#import "UASyncController.h"

@implementation UASyncController

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Logic
- (void)sync
{
    // Have we got an Analytik API account setup?
    if([[self analytikController] activeAccount])
    {
        NSLog(@"Has got an Analytik API account");
    }
}

#pragma mark - Accessors
- (UAAnalytikController *)analytikController
{
    static dispatch_once_t pred = 0;
    __strong static UAAnalytikController* _analytikController = nil;
    dispatch_once(&pred, ^{
        _analytikController = [[UAAnalytikController alloc] init];
    });
    
    return _analytikController;
}

@end
