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
{
    __block UIBackgroundTaskIdentifier backgroundTask;
}
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
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf sync];
        }];
    }
    
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Logic
- (void)sync
{
    NSDate *syncFromDate = [[NSDate date] dateBySubtractingDays:90];
    NSNumber *lastSyncTimestamp = [[NSUserDefaults standardUserDefaults] valueForKey:kAnalytikLastSyncTimestampKey];
    if(lastSyncTimestamp)
    {
        syncFromDate = [NSDate dateWithTimeIntervalSince1970:[lastSyncTimestamp integerValue]];
    }

    // Check if we actually have anything to sync
    if([[self analytikController] needsToSyncFromDate:syncFromDate])
    {
        UIApplication *application = [UIApplication sharedApplication];
        backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSLog(@"Attemping Analytik sync from date: %@", syncFromDate);
            [[self analytikController] syncFromDate:syncFromDate success:^{
                NSLog(@"Analytik sync was successful");
                
                [[NSUserDefaults standardUserDefaults] setInteger:[[NSDate date] timeIntervalSince1970] forKey:kAnalytikLastSyncTimestampKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Finish up our background task
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
                
            } failure:^(NSError *error) {
                NSLog(@"Analytik sync failed: %@", [error localizedDescription]);
                
                // Finish up our background task
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }];
            
        });
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
