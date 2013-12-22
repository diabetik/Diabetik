//
//  UAReminderBaseViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 13/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
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
