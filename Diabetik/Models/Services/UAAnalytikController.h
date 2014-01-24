//
//  UAAnalytikController.h
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

#import <Foundation/Foundation.h>

@interface UAAnalytikController : NSObject

// Logic
- (void)authorizeWithCredentials:(NSDictionary *)credentials
                         success:(void (^)(void))successBlock
                         failure:(void (^)(NSError *))failureBlock;
- (void)syncFromDate:(NSDate *)fromDate
             success:(void (^)(void))successBlock
             failure:(void (^)(NSError *))failureBlock;
- (void)destroyCredentials;

// Accessors
- (BOOL)needsToSyncFromDate:(NSDate *)date;

// Helpers
- (NSDictionary *)activeAccount;

@end
