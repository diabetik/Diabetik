//
//  UASyncController.h
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

#import <Foundation/Foundation.h>
#import "UARunKeeperClient.h"
#import "UAAccount.h"

@class UARunKeeperClient;
@interface UASyncController : NSObject
@property (nonatomic, retain) NSOperationQueue *networkOperationQueue;
@property (nonatomic, retain) UARunKeeperClient *runKeeper;

+ (id)sharedInstance;

// Logic
- (void)requestExternalSyncByForce:(BOOL)force;
- (id)externalAccountForServiceIdentifier:(NSString *)serviceIdentifier withAccount:(UAAccount *)account;

@end
