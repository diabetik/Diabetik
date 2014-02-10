//
//  UASyncController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 04/01/2014.
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

#import <Dropbox/Dropbox.h>
#import "SSKeychain.h"
#import "Reachability.h"

#import "UAAnalytikController.h"
#import "UASyncController.h"
#import "UABackupController.h"

@interface UASyncController ()
{
    __block UIBackgroundTaskIdentifier backgroundTask;
}
@property (nonatomic, strong) NSTimer *syncTimer;

// Helpers
- (BOOL)analytikRequiresSync;

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
            [strongSelf syncInBackground:YES];
        }];
    }
    
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Logic
- (void)syncInBackground:(BOOL)backgroundSync
{
    BOOL analyticRequiresSync = [self analytikRequiresSync];
    BOOL backupRequiresSync = [self backupRequiresSync];
    
    if(analyticRequiresSync || backupRequiresSync)
    {
        UIApplication *application = [UIApplication sharedApplication];
        if(backgroundSync)
        {
            backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }];
        }
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            if(backupRequiresSync)
            {
                dispatch_group_enter(dispatchGroup);
                [self syncBackupWithCompletionHandler:^{
                    dispatch_group_leave(dispatchGroup);
                }];
            }
            if(analyticRequiresSync)
            {
                dispatch_group_enter(dispatchGroup);
                [self syncAnalytikWithCompletionHandler:^{
                    dispatch_group_leave(dispatchGroup);
                }];
            }
        });
        
        dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if(backgroundSync)
            {
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
    }
}
- (void)syncBackupWithCompletionHandler:(void (^)(void))completionBlock
{
    UABackupController *backupController = [[UABackupController alloc] init];
    [backupController backupToDropbox:^(NSError *error) {
        
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setInteger:timestamp forKey:kLastBackupTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(completionBlock) completionBlock();
    }];
}
- (void)syncAnalytikWithCompletionHandler:(void (^)(void))completionBlock
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [[self analytikController] syncFromDate:syncFromDate success:^{
                
                [[NSUserDefaults standardUserDefaults] setInteger:[[NSDate date] timeIntervalSince1970] forKey:kAnalytikLastSyncTimestampKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if(completionBlock) completionBlock();
                
            } failure:^(NSError *error) {
                if(completionBlock) completionBlock();
            }];
            
        });
    }
    else
    {
        if(completionBlock) completionBlock();
    }
}

#pragma mark - Helpers
- (BOOL)analytikRequiresSync
{
    NSDate *syncFromDate = [[NSDate date] dateBySubtractingDays:90];
    NSNumber *lastSyncTimestamp = [[NSUserDefaults standardUserDefaults] valueForKey:kAnalytikLastSyncTimestampKey];
    if(lastSyncTimestamp)
    {
        syncFromDate = [NSDate dateWithTimeIntervalSince1970:[lastSyncTimestamp integerValue]];
    }
    
    return [[self analytikController] needsToSyncFromDate:syncFromDate];
}
- (BOOL)backupRequiresSync
{
    if([[DBAccountManager sharedManager] linkedAccount])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults boolForKey:kAutomaticBackupEnabledKey])
        {
            NSInteger frequency = [defaults integerForKey:kAutomaticBackupFrequencyKey];
            NSInteger lastBackupTimestamp = [defaults integerForKey:kLastBackupTimestamp];
            NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
            
            if((currentTimestamp-lastBackupTimestamp) >= frequency)
            {
                BOOL requiresWifi = ![defaults boolForKey:kWWANAutomaticBackupEnabledKey];
                Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
                if(requiresWifi && ![reachability isReachableViaWiFi])
                {
                    return NO;
                }
                
                return YES;
            }
        }
    }
    
    return NO;
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
