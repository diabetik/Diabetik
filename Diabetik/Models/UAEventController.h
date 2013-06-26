//
//  UAEventController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2013.
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
#import "UAEvent.h"
#import "UAMedicine.h"

@class UAAccount;
@interface UAEventController : NSObject

+ (id)sharedInstance;
- (void)setMOC:(NSManagedObjectContext *)aMOC;

// Events
- (void)attemptSmartInputWithExistingEntries:(NSMutableArray *)existingEntries success:(void (^)(UAMedicine*))successBlock failure:(void (^)(void))failureBlock;
- (NSArray *)fetchEventsMatchingSearch:(NSString *)string withPredicate:(NSPredicate *)basePredicate;
- (UAEvent *)fetchEventForAccount:(UAAccount *)account withExternalUUID:(NSString *)uuid inContext:(NSManagedObjectContext *)moc;
- (NSDictionary *)statisticsForEvents:(NSArray *)events fromDate:(NSDate *)minDate toDate:(NSDate *)maxDate;
- (NSArray *)fetchKey:(NSString *)key forEventsWithFilterType:(EventFilterType)filterType;

// Helpers
- (NSString *)medicineTypeHR:(NSInteger)type;

@end
