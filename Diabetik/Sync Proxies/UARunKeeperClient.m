//
//  UARunKeeperClient.m
//  Diabetik
//
//  Inspired by brierwood's RunKeeper-iOS API module
//  https://github.com/brierwood/RunKeeper-iOS
//
//  Created by Nial Giacomelli on 03/04/2013.
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

#import "NSDate+Extension.h"

#import "UARunKeeperClient.h"
#import "UAAccountController.h"
#import "UAEventController.h"
#import "UAActivity.h"

NSString *const kRunKeeperAuthorizeURL = @"https://runkeeper.com/apps/authorize";
NSString *const kRunKeeperBaseURL = @"https://api.runkeeper.com";

@implementation UARunKeeperClient

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                          object:[NXOAuth2AccountStore sharedStore]
                                                           queue:nil
                                                      usingBlock:^(NSNotification *aNotification){
                                                          
                                                          if([aNotification.userInfo objectForKey:NXOAuth2AccountStoreNewAccountUserInfoKey])
                                                          {
                                                              UAAccount *activeAccount = [[UAAccountController sharedInstance] activeAccount];
                                                              NXOAuth2Account *newAccount = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreNewAccountUserInfoKey];
                                                              newAccount.userData = [activeAccount guid];
                                                            
                                                              // Force a sync request
                                                              [self performSyncByForce:YES];
                                                              
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kRunKeeperLinkNotification object:newAccount];
                                                          }
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                          object:[NXOAuth2AccountStore sharedStore]
                                                           queue:nil
                                                      usingBlock:^(NSNotification *aNotification){
                                                          NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kRunKeeperLinkFailedNotification object:error];
                                                      }];
    }
    
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Logic
- (void)connect
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kRunKeeperServiceIdentifier];
}
- (void)removeAccount:(NXOAuth2Account *)account
{
    [[NXOAuth2AccountStore sharedStore] removeAccount:account];
}
- (void)performSyncByForce:(BOOL)force
{
    NSManagedObjectContext *moc = [[UASyncController sharedInstance] moc];
    
    [moc performBlock:^{        
        UAAccount *account = [[UAAccountController sharedInstance] activeAccountInContext:moc];
        if(account)
        {
            NXOAuth2Account *externalAccount = (NXOAuth2Account *)[[UASyncController sharedInstance] externalAccountForServiceIdentifier:kRunKeeperServiceIdentifier
                                                                                                                             withAccount:account];
            
            if(externalAccount)
            {
                if(account.runKeeperAccount)
                {
                    // If we're not being forced to update, check whether we're within our sync interval
                    if(!force)
                    {
                        NSDate *nextSyncDate = [account.runKeeperAccount.lastSyncTimestamp dateByAddingTimeInterval:[[account.runKeeperAccount syncInterval] integerValue]];
                        if(![[NSDate date] isLaterThanDate:nextSyncDate])
                        {
                            //NSLog(@"Within sync interval, bailing out");
                            return;
                        }
                    }
                    
                    [self fetchLatestActivitiesForAccount:account inContext:moc];
                }
                else
                {
                    [self performRequest:@"/user" success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

                        NSError *error = nil;
                        
                        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UARunKeeperAccount" inManagedObjectContext:moc];
                        UARunKeeperAccount *runKeeperAccount = (UARunKeeperAccount *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                        runKeeperAccount.userID = [[JSON objectForKey:@"userID"] stringValue];
                        runKeeperAccount.lastSyncTimestamp = [NSDate distantPast];
                        runKeeperAccount.syncInterval = [NSNumber numberWithInteger:6*60*60]; // every 6 hours
                        runKeeperAccount.account = account;
                        
                        [moc save:&error];
                        [moc.parentContext performBlock:^{
                            NSError *error = nil;
                            [moc.parentContext save:&error];
                        }];
                        
                        if(error)
                        {
                            NSLog(@"There was an error saving runKeeperAccount details: %@", error);
                        }
                        else
                        {
                            NSLog(@"Account with ID %@ saved", runKeeperAccount.userID);
                            
                            [self fetchLatestActivitiesForAccount:account inContext:moc];
                        }
                     
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        
                    }];
                }
            }
        }
    }];
}
- (void)performRequest:(NSString *)endpoint
               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
{
    UAAccount *activeAccount = [[UAAccountController sharedInstance] activeAccount];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kRunKeeperBaseURL, endpoint]];
    NSURLRequest *request = [self createRequestForAccount:activeAccount withURL:url];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithArray:@[@"application/vnd.com.runkeeper.user+json", @"application/vnd.com.runkeeper.fitnessactivityfeed+json"]]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    
    [[[UASyncController sharedInstance] networkOperationQueue] addOperation:operation];
}
- (void)fetchLatestActivitiesForAccount:(UAAccount *)account inContext:(NSManagedObjectContext *)moc
{
    [self performRequest:@"/fitnessActivities?pageSize=100" success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *activities = [JSON objectForKey:@"items"];
     
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
        
        for(NSDictionary *activity in activities)
        {
            NSString *guid = [activity objectForKey:@"uri"];
            if(guid)
            {
                UAActivity *existingEvent = (UAActivity *)[[UAEventController sharedInstance] fetchEventForAccount:account withExternalGUID:[activity objectForKey:@"uri"] inContext:moc];
                
                if(existingEvent)
                {
                    existingEvent.name = [activity objectForKey:@"type"];
                    existingEvent.minutes = [NSNumber numberWithDouble:[[activity objectForKey:@"duration"] integerValue]/60];
                    existingEvent.timestamp = [dateFormatter dateFromString:[activity objectForKey:@"start_time"]];
                    existingEvent.externalSource = @"RunKeeper";
                }
                else
                {
                    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAActivity" inManagedObjectContext:moc];
                    UAActivity *newEvent = (UAActivity *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                    newEvent.externalGUID = guid;
                    newEvent.name = [activity objectForKey:@"type"];
                    newEvent.minutes = [NSNumber numberWithDouble:[[activity objectForKey:@"duration"] integerValue]/60];
                    newEvent.timestamp = [dateFormatter dateFromString:[activity objectForKey:@"start_time"]];
                    newEvent.account = account;
                    newEvent.filterType = [NSNumber numberWithInteger:ActivityFilterType];
                    newEvent.externalSource = @"RunKeeper";
                    
                    [moc insertObject:newEvent];
                }
                [moc save:nil];
                [moc.parentContext performBlock:^{
                    [moc.parentContext save:nil];
                }];
            }
        }
        
        account.runKeeperAccount.lastSyncTimestamp = [NSDate date];
        
        [moc save:nil];
        [moc.parentContext performBlock:^{
            [moc.parentContext save:nil];
        }];
        
        // Tell any listeners that we've completed a successful sync!
        [[NSNotificationCenter defaultCenter] postNotificationName:kRunKeeperDidSyncNotification object:nil];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Helpers
- (NSMutableURLRequest *)createRequestForAccount:(UAAccount *)account withURL:(NSURL *)url
{
    UAAccount *activeAccount = [[UAAccountController sharedInstance] activeAccount];
    
    if(activeAccount)
    {
        NXOAuth2Account *externalAccount = (NXOAuth2Account *)[[UASyncController sharedInstance] externalAccountForServiceIdentifier:kRunKeeperServiceIdentifier
                                                                                                                         withAccount:activeAccount];
        
        if(externalAccount)
        {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setValue:[NSString stringWithFormat:@"Bearer %@", [[externalAccount accessToken] accessToken]] forHTTPHeaderField:@"Authorization"];
            return request;
        }
    }
    
    return nil;
}
@end
