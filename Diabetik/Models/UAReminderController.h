//
//  UAReminderController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 03/03/2013.
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
#import "UAReminder.h"
#import "UAReminderRule.h"

// TODO: Convert these to enums
#define kReminderTypeRepeating 0
#define kReminderTypeLocation 1
#define kReminderTypeDate 2
#define kReminderTypeRule 3

#define kMinuteIntervalType 0
#define kHourIntervalType 1
#define kDayIntervalType 2

#define kReminderTriggerArriving 0
#define kReminderTriggerDeparting 1
#define kReminderTriggerBoth 2

@interface UAReminderController : NSObject
@property (readonly, strong, nonatomic) NSArray *reminders;
@property (readonly, strong, nonatomic) NSArray *ungroupedReminders;

// Setup
+ (id)sharedInstance;

// Reminders
- (NSArray *)fetchAllReminders;
- (void)deleteExpiredReminders;
- (BOOL)deleteReminderWithID:(NSString *)reminderID error:(NSError **)error;
- (NSString *)detailForReminder:(UAReminder *)aReminder;
- (void)updateRemindersBasedOnCoreDataNotification:(NSNotification *)note;

// Rules
- (NSArray *)fetchAllReminderRules;
- (BOOL)deleteReminderRule:(UAReminderRule *)reminderRule error:(NSError **)error;

// Notifications
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;
- (void)setNotificationsForReminder:(UAReminder *)aReminder;
- (void)deleteNotificationsWithID:(NSString *)reminderID;

// Helpers
- (UAReminder *)fetchReminderWithID:(NSString *)reminderID;
- (NSArray *)notificationsWithID:(NSString *)reminderID;
- (NSString *)generateReminderID;
- (NSDate *)generateNotificationDateWithDate:(NSDate *)date;
- (NSString *)formattedRepeatingDaysWithFlags:(NSInteger)flags;

@end
