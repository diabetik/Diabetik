//
//  UAReminderController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 03/03/2013.
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
#import "UAReminderController.h"
#import "UAAppDelegate.h"

@interface UAReminderController ()
{
    NSCalendar *calendar;
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
}
@property (strong, nonatomic) NSManagedObjectContext *moc;

- (void)cacheReminders;
@end

@implementation UAReminderController
@synthesize reminders = _reminders;
@synthesize ungroupedReminders = _ungroupedReminders;
@synthesize moc = _moc;

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
- (void)setMOC:(NSManagedObjectContext *)aMOC
{
    _moc = aMOC;
}

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cacheReminders) name:kRemindersUpdatedNotification object:nil];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
        
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [self deleteExpiredReminders];
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
    NSManagedObjectContext *moc = [(UAAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
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
    
    return nil;
}
- (void)deleteExpiredReminders
{
    NSArray *reminders = [self fetchAllReminders];
    BOOL removedReminders = NO;
    
    if(reminders)
    {
        // Expire any date-based reminders
        for(UAReminder *reminder in [reminders objectAtIndex:kReminderTypeDate])
        {
            if([reminder.date isEarlierThanDate:[NSDate date]])
            {
                NSError *error = nil;
                [self deleteReminderWithID:reminder.guid error:&error];
                
                if(!error)
                {
                    removedReminders = YES;
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
}
- (void)deleteReminderWithID:(NSString *)reminderID error:(NSError **)error
{
    UAReminder *reminder = [self fetchReminderWithID:reminderID];
    if(reminder)
    {
        [self.moc deleteObject:reminder];
        [self.moc save:*&error];
        
        if(!*error)
        {
            [self deleteNotificationsWithID:reminderID];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
        }
    }
}
- (NSString *)detailForReminder:(UAReminder *)aReminder
{
    if([aReminder.type integerValue] == kReminderTypeDate)
    {
        return [dateFormatter stringFromDate:aReminder.date];
    }
    else if([aReminder.type integerValue] == kReminderTypeRepeating)
    {
        NSString *days = [[UAReminderController sharedInstance] formattedRepeatingDaysWithFlags:[aReminder.days integerValue]];
        return [days stringByAppendingFormat:@", %@", [timeFormatter stringFromDate:aReminder.date]];
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
    NSManagedObjectContext *moc = [(UAAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
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
    
    return nil;
}
- (void)deleteReminderRule:(UAReminderRule *)reminderRule error:(NSError **)error
{
    if(reminderRule)
    {
        [self.moc deleteObject:reminderRule];
        [self.moc save:*&error];
        
        if(!*error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
        }
    }
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
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = aReminder.date;
        notification.alertBody = aReminder.message;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = @"notification.caf";
        notification.userInfo = @{@"ID": aReminder.guid, @"type": aReminder.type};
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
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
                NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:aReminder.date];
                dateComponents.weekday = i+1;
                
                NSDate *notificationDate = [calendar dateFromComponents:dateComponents];
                if(notificationDate)
                {
                    if([notificationDate isEarlierThanDate:[NSDate date]])
                    {
                        dateComponents.week++;
                        notificationDate = [calendar dateFromComponents:dateComponents];
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

#pragma mark - Notifications
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

#pragma mark - Helpers
- (UAReminder *)fetchReminderWithID:(NSString *)reminderID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UAReminder"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid = %@", reminderID];
    [request setPredicate:predicate];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [self.moc executeFetchRequest:request error:&error];
    if (objects != nil && [objects count] > 0)
    {
        return (UAReminder *)[objects objectAtIndex:0];
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
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[dateComponents hour]];
    [dateComps setMinute:[dateComponents minute]];
    [dateComps setSecond:0];
    
    NSDate *notificationDate = [calendar dateFromComponents:dateComps];
    
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
