//
//  UAAccountController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 24/02/2013.
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
#import "UAAppDelegate.h"
#import "UAAccount.h"

@interface UAAccountController : NSObject
@property (readonly, strong, nonatomic) UAAccount *activeAccount;
@property (readonly, strong, nonatomic) NSArray *accounts;

+ (id)sharedInstance;
- (void)setMOC:(NSManagedObjectContext *)aMOC;

// Logic
- (void)cacheAccounts;
- (NSArray *)fetchAllAccountsInContext:(NSManagedObjectContext *)aMOC;

- (UAAccount *)activeAccount;
- (UAAccount *)activeAccountInContext:(NSManagedObjectContext *)moc;
- (void)setActiveAccount:(UAAccount *)theAccount;

@end