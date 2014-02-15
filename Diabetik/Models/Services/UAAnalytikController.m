//
//  UAAnalytikController.m
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

#import "AFNetworking.h"
#import "SSKeychain.h"

#import "UAAnalytikController.h"
#import "UAEventController.h"

@interface UAAnalytikController ()
{
    AFHTTPRequestOperationManager *liveOperationManager;
    AFHTTPRequestOperationManager *stagingOperationManager;
}
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

// Accessors
- (AFHTTPRequestOperationManager *)operationManager;

// Helpers
- (NSArray *)eventsToSyncFromDate:(NSDate *)fromDate;
- (NSDictionary *)representationForEvent:(UAEvent *)event;
- (NSError *)responseError:(NSDictionary *)response;

@end

@implementation UAAnalytikController

#pragma mark - Logic
- (void)authorizeWithCredentials:(NSDictionary *)credentials
                         success:(void (^)(void))successBlock
                         failure:(void (^)(NSError *))failureBlock
{
    NSDictionary *parameters = @{@"email": credentials[@"email"], @"password": credentials[@"password"]};
    
    [self.operationManager POST:[NSString stringWithFormat:@"%@user/validate", kAnalytikAPIURL]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
            
          dispatch_async(dispatch_get_main_queue(), ^{
              NSError *error = [self responseError:responseObject];
              if(!error)
              {
                  // If our authorization is successful, store our login credentials securely in the keychain
                  [SSKeychain setPassword:credentials[@"password"]
                               forService:kAnalytikServiceIdentifier
                                  account:credentials[@"email"]
                                    error:&error];
                  if(!error)
                  {
                      successBlock();
                  }
                  else
                  {
                      failureBlock(error);
                  }
              }
              else
              {
                  failureBlock(error);
              }
          });
          
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock(error);
        });
        
    }];
}
- (void)syncFromDate:(NSDate *)fromDate
             success:(void (^)(void))successBlock
             failure:(void (^)(NSError *))failureBlock
{
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *account = [self activeAccount];
    if(account)
    {
        NSManagedObjectContext *moc = [self managedObjectContext];
        if(moc)
        {
            [moc performBlock:^{
               
                __strong typeof(weakSelf) strongSelf = self;
                
                NSArray *events = [strongSelf eventsToSyncFromDate:fromDate];
                if(events)
                {
                    @autoreleasepool {
                        
                        NSMutableArray *batch = [NSMutableArray array];
                        for(UAEvent *event in events)
                        {
                            NSDictionary *representation = [strongSelf representationForEvent:event];
                            if(representation)
                            {
                                [batch addObject:representation];
                            }
                            [moc refreshObject:event mergeChanges:NO];
                        }
                        
                        // Check to see if we have left-over entities. If we do, add them to our operations list
                        if([batch count])
                        {
                            NSInteger earliestTS = NSIntegerMax; NSInteger latestTS = NSIntegerMin;
                            for(NSDictionary *event in batch)
                            {
                                if([event[@"ts"] integerValue] > latestTS) latestTS = [event[@"ts"] integerValue];
                                if([event[@"ts"] integerValue] < earliestTS) earliestTS = [event[@"ts"] integerValue];
                            }
                            
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            NSDictionary *metadata = @{@"fromDate": @(earliestTS),
                                                       @"toDate": @(latestTS),
                                                       @"bgTrackingUnit": [defaults valueForKey:kBGTrackingUnitKey],
                                                       @"minHealthyBG": [defaults valueForKey:kMinHealthyBGKey],
                                                       @"maxHealthyBG": [defaults valueForKey:kMaxHealthyBGKey],
                                                       };
                            NSDictionary *data = @{@"metadata": metadata, @"events": batch};
                        
                            NSDictionary *parameters = @{@"email": account[@"email"],
                                                         @"password": account[@"password"],
                                                         @"data": data};
                            
                            [self.operationManager POST:@"records"
                                             parameters:parameters
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    
                                                
                                                    successBlock();
                                                    
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                
                                // If our authentication credentials are invalid, destroy them
                                if([error code] == 401)
                                {
                                    [strongSelf destroyCredentials];
                                }
                                
                                failureBlock(error);
                            }];
                        }
                        else
                        {
                            // We couldn't find anything to sync, so let's consider that a success!
                            successBlock();
                        }
                    }
                }
                else
                {
                    // We're up to date, there's nothing to sync!
                    successBlock();
                }
            }];
        }
        else
        {
            NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Unable to fetch a suitable MOC"}];
            failureBlock(error);
        }
    }
    else
    {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No valid Analytik credentials found"}];
        
        failureBlock(error);
    }
}
- (void)destroyCredentials
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *accounts = [SSKeychain accountsForService:kAnalytikServiceIdentifier];
        if(accounts && [accounts count])
        {
            for(NSDictionary *account in accounts)
            {
                [SSKeychain deletePasswordForService:kAnalytikServiceIdentifier account:account[kSSKeychainAccountKey]];
            }
        }
        
        // Remove our sync timestamp data
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnalytikLastSyncTimestampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

#pragma mark - Accessors
- (AFHTTPRequestOperationManager *)operationManager
{
    BOOL useStagingServer = NO; //[[NSUserDefaults standardUserDefaults] boolForKey:kAnalytikUseStagingServerKey];
    if(useStagingServer)
    {
        NSURL *baseURL = [NSURL URLWithString:kAnalytikStagingAPIURL];
        if(!stagingOperationManager)
        {
            stagingOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
            stagingOperationManager.operationQueue = [self operationQueue];
            stagingOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
        
        return stagingOperationManager;
        
    }
    else
    {
        NSURL *baseURL = [NSURL URLWithString:kAnalytikAPIURL];
        if(!liveOperationManager)
        {
            liveOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
            liveOperationManager.operationQueue = [self operationQueue];
            liveOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
        
        return liveOperationManager;
    }
    
    return nil;
}
- (NSOperationQueue *)operationQueue
{
    if(!_operationQueue)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return _operationQueue;
}
- (NSManagedObjectContext *)managedObjectContext
{
    if(!_managedObjectContext)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.parentContext = [[UACoreDataController sharedInstance] managedObjectContext];
    }
    
    return _managedObjectContext;
}
- (BOOL)needsToSyncFromDate:(NSDate *)date
{
    if([self activeAccount] && [self eventsToSyncFromDate:date])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - Helpers
- (NSArray *)eventsToSyncFromDate:(NSDate *)fromDate
{
    __block NSArray *events = nil;
    NSManagedObjectContext *moc = [self managedObjectContext];
    if(moc)
    {
        [moc performBlockAndWait:^{
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@", fromDate];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
            events = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate
                                                                  sortDescriptors:@[sortDescriptor]
                                                                        inContext:moc];
        }];
    }
    
    return events;
}
- (NSDictionary *)representationForEvent:(UAEvent *)event
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionary];
    representation[@"type"] = [event filterType];
    representation[@"ts"] = [NSNumber numberWithInteger:[[event timestamp] timeIntervalSince1970]];
    if([event notes]) representation[@"notes"] = [event notes];
    
    if([event isKindOfClass:[UAMedicine class]])
    {
        UAMedicine *medicine = (UAMedicine *)event;
        if([medicine name]) representation[@"name"] = [medicine name];
        if([medicine amount]) representation[@"amount"] = [medicine amount];
        if([medicine type]) representation[@"unit"] = [medicine type];
    }
    else if([event isKindOfClass:[UAMeal class]])
    {
        UAMeal *meal = (UAMeal *)event;
        if([meal name]) representation[@"name"] = [meal name];
        if([meal grams]) representation[@"grams"] = [meal grams];
    }
    else if([event isKindOfClass:[UAReading class]])
    {
        UAReading *reading = (UAReading *)event;
        if([reading mgValue]) representation[@"mgValue"] = [reading mgValue];
        if([reading mmoValue]) representation[@"mmoValue"] = [reading mmoValue];
    }
    else if([event isKindOfClass:[UAActivity class]])
    {
        UAActivity *activity = (UAActivity *)event;
        if([activity minutes]) representation[@"mins"] = [activity minutes];
    }
    
    return representation;
}
- (NSError *)responseError:(NSDictionary *)response
{
    // Check for the existance of an 'error' key in our JSON response to determine whether we've done something wrong
    if([response isKindOfClass:[NSDictionary class]] && response[@"error"])
    {
        NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"The Analytik API responded with the following error: %@", nil), response[@"error"][@"message"]];
        return [NSError errorWithDomain:kErrorDomain code:[response[@"error"][@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    }
    else
    {
        // Since it appears there's no error present, try to look for a valid response
        if([response isKindOfClass:[NSDictionary class]] && response[@"response"])
        {
            if([response[@"response"][@"code"] integerValue] == 200)
            {
                return nil;
            }
        }
    }
    
    // If all else has failed, it looks like we don't understand the response, so throw back a generic error
    NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"The Analytik API returned an unrecognized response", nil)];
    return [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
}
- (NSDictionary *)activeAccount
{
    NSArray *accounts = [SSKeychain accountsForService:kAnalytikServiceIdentifier];
    if(accounts && [accounts count])
    {
        NSError *error = nil;
        NSString *email = accounts[0][kSSKeychainAccountKey];
        NSString *password = [SSKeychain passwordForService:kAnalytikServiceIdentifier account:email error:&error];
        
        if(!error)
        {
            return @{@"email": email, @"password": password};
        }
    }
    
    return nil;
}

@end
