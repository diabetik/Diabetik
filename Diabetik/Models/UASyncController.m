//
//  UASyncController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 04/04/2013.
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

#import "UASyncController.h"
#import "UAAppDelegate.h"

@interface UASyncController ()
@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, retain) NSTimer *syncTimer;

- (void)syncTimerTick;
@end

@implementation UASyncController
@synthesize moc = _moc;
@synthesize runKeeper = _runKeeper;
@synthesize syncTimer = _syncTimer;
@synthesize networkOperationQueue = _networkOperationQueue;

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
        _networkOperationQueue = [[NSOperationQueue alloc] init];
        _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _moc.parentContext = [(UAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

        _syncTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(syncTimerTick) userInfo:nil repeats:YES];
        _runKeeper = [[UARunKeeperClient alloc] init];
    }
    
    return self;
}

#pragma mark - Logic
- (void)syncTimerTick
{
    [self requestExternalSyncByForce:NO];
}
- (void)requestExternalSyncByForce:(BOOL)force
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.runKeeper performSyncByForce:force];
    });
}
- (id)externalAccountForServiceIdentifier:(NSString *)serviceIdentifier withAccount:(UAAccount *)account
{
    for (NXOAuth2Account *externalAccount in [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:serviceIdentifier])
    {
        if([account.uuid isEqualToString:(NSString *)externalAccount.userData])
        {
            return externalAccount;
        }
    }
    
    return nil;
}

@end
