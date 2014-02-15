//
//  UAReminderController.m
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

#import "NSDate+Extension.h"
#import "UAReminderController.h"
#import "UAAppDelegate.h"

@interface UAReminderController ()
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

- (void)cacheReminders;
@end

@implementation UAReminderController
@synthesize reminders = _reminders;
@synthesize ungroupedReminders = _ungroupedReminders;

@synthesize calendar = _calendar;
@synthesize dateFormatter = _dateFormatter;
@synthesize timeFormatter = _timeFormatter;

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cacheReminders)
                                                     name:kRemindersUpdatedNotification
                                                   object:nil];
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateRemindersBasedOnCoreDataNotification:)
                                                     name:USMStoreDidImportChangesNotification
                                                   object:nil];
         */
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf cacheReminders];
                [strongSelf deleteExpiredReminders];
            });
        });
    }
    
    return self;
}

#pragma mark - Reminders
- (void)cacheReminders
{
    _reminders = [self fetchAllReminders];
    
    // Stash an ungrouped cache for good measure
    NSMutableArray *reminders = [NSMutableArray array];
    if([self reminders])
    {
        [reminders addObjectsFromArray:[_reminders objectAtIndex:kReminderTypeDate]];
        [reminders addObjectsFromArray:[_reminders objectAtIndex:kReminderTypeRepeating]];
        [reminders addObjectsFromArray:[_reminders objectAtIndex:kReminderTypeLocation]];
    }
    _ungroupedReminders = [NSArray arrayWithArray:reminders];
}
- (NSArray *)fetchAllReminders
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAReminder" inManagedObjectContext:moc];
        [request setEntity:entity];
        NSSortDescriptor *sortPredicate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        [request setSortDescriptors:@[sortPredicate]];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            NSMutableArray *dateReminders = [NSMutableArray array];
            NSMutableArray *repeatingReminders = [NSMutableArray array];
            NSMutableArray *locationReminders = [NSMutableArray array];
            
            for(UAReminder *reminder in objects)
            {
                if([reminder.type integerValue] == kReminderTypeDate)
                {
                    [dateReminders addObject:reminder];
                }
                else if([reminder.type integerValue] == kReminderTypeRepeating)
                {
                    [repeatingReminders addObject:reminder];
                }
                else if([reminder.type integerValue] == kReminderTypeLocation)
                {
                    [locationReminders addObject:reminder];
                }
            }
            
            return @[repeatingReminders, locationReminders, dateReminders];
        }
    }
    
    return nil;
}
- (void)updateRemindersBasedOnCoreDataNotification:(NSNotification *)note
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSDictionary *userInfo = [note userInfo];
        if(userInfo)
        {
            BOOL reminderUpdatesPerformed = NO;
            for(NSString *key in userInfo)
            {
                // Deleted notifications
                if([key isEqualToString:NSDeletedObjectsKey])
                {
                    for(NSManagedObjectID *objectID in userInfo[key])
                    {
                        UAManagedObject *managedObject = (UAManagedObject *)[moc objectWithID:objectID];
                        if(managedObject && [managedObject isKindOfClass:[UAReminder class]])
                        {
                            reminderUpdatesPerformed = YES;
                        }
                    }
                }
                // Inserted/updated notifications
                else if([key isEqualToString:NSUpdatedObjectsKey] || [key isEqualToString:NSInsertedObjectsKey])
                {
                    for(NSManagedObjectID *objectID in userInfo[key])
                    {
                        UAManagedObject *managedObject = (UAManagedObject *)[moc objectWithID:objectID];
                        if(managedObject && [managedObject isKindOfClass:[UAReminder class]])
                        {
                            [self setNotificationsForReminder:(UAReminder *)managedObject];
                            
                            reminderUpdatesPerformed = YES;
                        }
                    }
                }
            }
            
            if(reminderUpdatesPerformed)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
            }
        }
    }
}
- (void)deleteExpiredReminders
{
    NSArray *reminders = [self fetchAllReminders];
    if(reminders)
    {
        // Expire any date-based reminders
        for(UAReminder *reminder in [reminders objectAtIndex:kReminderTypeDate])
        {
            if([reminder.date isEarlierThanDate:[NSDate date]])
            {
                NSError *error = nil;
                [self deleteReminderWithID:reminder.guid error:&error];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
}
- (BOOL)deleteReminderWithID:(NSString *)reminderID error:(NSError **)error
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        UAReminder *reminder = [self fetchReminderWithID:reminderID];
        if(reminder)
        {
            [moc deleteObject:reminder];
            [moc save:*&error];
            
            if(!*error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                return YES;
            }
        }
    }
    
    return NO;
}
- (NSString *)detailForReminder:(UAReminder *)aReminder
{
    if([aReminder.type integerValue] == kReminderTypeDate)
    {
        return [self.dateFormatter stringFromDate:aReminder.date];
    }
    else if([aReminder.type integerValue] == kReminderTypeRepeating)
    {
        NSString *days = [[UAReminderController sharedInstance] formattedRepeatingDaysWithFlags:[aReminder.days integerValue]];
        return [days stringByAppendingFormat:@", %@", [self.timeFormatter stringFromDate:aReminder.date]];
    }
    else if([aReminder.type integerValue] == kReminderTypeLocation)
    {
        return aReminder.locationName;
    }
    
    return nil;
}

#pragma mark - Rules
- (NSArray *)fetchAllReminderRules
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAReminderRule" inManagedObjectContext:moc];
        [request setEntity:entity];
        
        NSSortDescriptor *sortPredicate = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[sortPredicate]];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            return objects;
        }
    }
    
    return nil;
}
- (BOOL)deleteReminderRule:(UAReminderRule *)reminderRule error:(NSError **)error
{
    if(reminderRule)
    {
        NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            [moc deleteObject:reminderRule];
            [moc save:*&error];
            
            if(!*error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Notifications
- (void)setNotificationsForReminder:(UAReminder *)aReminder
{
    // Cancel all existing registered notifications
    NSArray *notifications = [self notificationsWithID:[aReminder guid]];
    if([notifications count])
    {
        for(UILocalNotification *notification in notifications)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    // Generate a date-based notification
    if([aReminder.type integerValue] == kReminderTypeDate)
    {
        // Make sure this date hasn't already passed
        if([aReminder.date isLaterThanDate:[NSDate date]])
        {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = aReminder.date;
            notification.alertBody = aReminder.message;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = @"notification.caf";
            notification.userInfo = @{@"ID": aReminder.guid, @"type": aReminder.type};
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    else
    {
        int days[7] = {0};
        NSInteger dayFlags = [aReminder.days integerValue];
        if(dayFlags & Everyday)
        {
            for(int i = 0; i < 7;i ++)
            {
                days[i] = 1;
            }
        }
        else
        {
            if(dayFlags & Sunday) days[0] = 1;
            if(dayFlags & Monday) days[1] = 1;
            if(dayFlags & Tuesday) days[2] = 1;
            if(dayFlags & Wednesday) days[3] = 1;
            if(dayFlags & Thursday) days[4] = 1;
            if(dayFlags & Friday) days[5] = 1;
            if(dayFlags & Saturday) days[6] = 1;
        }
        
        for(int i = 0; i < 7; i++)
        {
            if(days[i])
            {
                NSDateComponents *dateComponents = [self.calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:aReminder.date];
                dateComponents.weekday = i+1;
                
                NSDate *notificationDate = [self.calendar dateFromComponents:dateComponents];
                if(notificationDate)
                {
                    if([notificationDate isEarlierThanDate:[NSDate date]])
                    {
                        dateComponents.week++;
                        notificationDate = [self.calendar dateFromComponents:dateComponents];
                    }
                    
                    if(notificationDate) 
                    {
                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                        notification.fireDate = notificationDate;
                        notification.alertBody = aReminder.message;
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        notification.timeZone = [NSTimeZone defaultTimeZone];
                        notification.repeatInterval = NSWeekCalendarUnit;
                        notification.soundName = @"notification.caf";
                        notification.userInfo = @{@"ID": aReminder.guid, @"type": aReminder.type};
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    }
                }
            }
        }
    }
}
- (void)deleteNotificationsWithID:(NSString *)reminderID
{
    NSArray *notifications = [self notificationsWithID:reminderID];
    if([notifications count])
    {
        for(UILocalNotification *notification in notifications)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}
- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state != UIApplicationStateInactive)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Scheduled Reminder", nil)
                                                        message:notification.alertBody
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Thanks", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self deleteExpiredReminders];
}

#pragma mark - Accessors
- (NSDateFormatter *)dateFormatter
{
    if(!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    return _dateFormatter;
}
- (NSDateFormatter *)timeFormatter
{
    if(!_timeFormatter)
    {
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    return _timeFormatter;
}
- (NSCalendar *)calendar
{
    if(!_calendar)
    {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    return _calendar;
}

#pragma mark - Helpers
- (UAReminder *)fetchReminderWithID:(NSString *)reminderID
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UAReminder"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid = %@", reminderID];
        [request setPredicate:predicate];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            return (UAReminder *)[objects objectAtIndex:0];
        }
    }
    
    return nil;
}
- (NSArray *)notificationsWithID:(NSString *)reminderID
{
    NSMutableArray *notifications = [NSMutableArray array];
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];

    for (UILocalNotification *notification in localNotifications)
    {
        NSString *notificationID = [notification.userInfo objectForKey:@"ID"];
        if([notificationID isEqualToString:reminderID])
        {
            [notifications addObject:notification];
        }
    }
    
    return [NSArray arrayWithArray:notifications];
}
- (NSString *)generateReminderID
{
    return [NSString stringWithFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]];
}
- (NSDate *)generateNotificationDateWithDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[dateComponents hour]];
    [dateComps setMinute:[dateComponents minute]];
    [dateComps setSecond:0];
    
    NSDate *notificationDate = [self.calendar dateFromComponents:dateComps];
    
    return notificationDate;
}
- (NSString *)formattedRepeatingDaysWithFlags:(NSInteger)flags
{
    NSString *string = @"";
    if(flags & Everyday)
    {
        string = NSLocalizedString(@"Every day", nil);
    }
    else
    {
        if(flags & Monday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Mon", nil)];
        if(flags & Tuesday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Tues", nil)];
        if(flags & Wednesday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Wed", nil)];
        if(flags & Thursday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Thurs", nil)];
        if(flags & Friday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Fri", nil)];
        if(flags & Saturday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Sat", nil)];
        if(flags & Sunday) string = [string stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Sun", nil)];
        
        if([string length])
        {
            string = [string substringToIndex:[string length]-2];
        }
    }
    
    return string;
}

@end
