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

@interface UASyncController ()
@property (nonatomic, strong) NSTimer *syncTimer;

@end

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

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:5*60
                                                              target:strongSelf
                                                            selector:@selector(sync)
                                                            userInfo:nil
                                                             repeats:YES];
            
            [self sync];
        });
    }
    
    return self;
}

#pragma mark - Logic
- (void)sync
{
    // Have we got an Analytik API account setup?
    if([[self analytikController] activeAccount])
    {
        NSLog(@"Attemping Analytik sync");
        [[self analytikController] syncFromDate:[NSDate distantPast] success:^{
            NSLog(@"Analytik sync was successful");
        } failure:^(NSError *error) {
            NSLog(@"Analytik sync failed");
        }];
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
