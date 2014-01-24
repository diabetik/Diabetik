//
//  UAReminderBaseViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 13/12/2013.
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

#import "UAReminderBaseViewController.h"

@interface UAReminderBaseViewController ()

@end

@implementation UAReminderBaseViewController
@synthesize reminderOID = _reminderOID;

#pragma mark - Setup
- (id)initWithReminder:(UAReminder *)theReminder
{
    self = [super init];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit reminder", nil);
        
        self.reminder = theReminder;
    }
    
    return self;
}

#pragma mark - Logic
- (void)reloadViewData:(NSNotification *)note
{
    [super reloadViewData:note];
    
    NSDictionary *userInfo = [note userInfo];
    if(userInfo && userInfo[NSDeletedObjectsKey])
    {
        for(NSManagedObjectID *objectID in userInfo[NSDeletedObjectsKey])
        {
            if(self.reminderOID && [objectID isEqual:self.reminderOID])
            {
                [self handleBack:self withSound:NO];
                return;
            }
        }
    }
}

#pragma mark - Accessors
- (UAReminder *)reminder
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(!moc) return nil;
    if(!self.reminderOID) return nil;
    
    NSError *error = nil;
    UAReminder *reminder = (UAReminder *)[moc existingObjectWithID:self.reminderOID error:&error];
    if (!reminder)
    {
        self.reminderOID = nil;
    }
    
    return reminder;
}
- (void)setReminder:(UAReminder *)theReminder
{
    NSError *error = nil;
    if(theReminder.objectID.isTemporaryID && ![theReminder.managedObjectContext obtainPermanentIDsForObjects:@[theReminder] error:&error])
    {
        self.reminderOID = nil;
    }
    else
    {
        self.reminderOID = theReminder.objectID;
    }
}
- (UAReminderRule *)reminderRule
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(!moc) return nil;
    if(!self.reminderRuleOID) return nil;
    
    NSError *error = nil;
    UAReminderRule *reminderRule = (UAReminderRule *)[moc existingObjectWithID:self.reminderRuleOID error:&error];
    if (!reminderRule)
    {
        self.reminderRuleOID = nil;
    }
    
    return reminderRule;
}
- (void)setReminderRule:(UAReminderRule *)theReminderRule
{
    NSError *error = nil;
    if(theReminderRule.objectID.isTemporaryID && ![theReminderRule.managedObjectContext obtainPermanentIDsForObjects:@[theReminderRule] error:&error])
    {
        self.reminderRuleOID = nil;
    }
    else
    {
        self.reminderRuleOID = theReminderRule.objectID;
    }
}
@end
