//
//  UARunKeeperClient.h
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

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"
#import "AFNetworking.h"

#import "UASyncController.h"
#import "UAAccount.h"
#import "UARunKeeperAccount.h"

@protocol UARunKeeperClientDelegate <NSObject>
@end

@interface UARunKeeperClient : NSObject
@property (nonatomic, assign) id<UARunKeeperClientDelegate> delegate;

// Logic
- (void)connect;
- (void)removeAccount:(NXOAuth2Account *)account;
- (void)performSyncByForce:(BOOL)force;
- (void)performRequest:(NSString *)endpoint
               success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
               failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
- (void)fetchLatestActivitiesForAccount:(UAAccount *)account inContext:(NSManagedObjectContext *)moc;

// Helpers
- (NSMutableURLRequest *)createRequestForAccount:(UAAccount *)account withURL:(NSURL *)url;

@end
