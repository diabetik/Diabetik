//
//  UAReminderBaseViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 13/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UABaseViewController.h"
#import "UAReminder.h"
#import "UAReminderRule.h"

@interface UAReminderBaseViewController : UABaseTableViewController
@property (nonatomic, strong) UAReminder *reminder;
@property (nonatomic, strong) NSManagedObjectID *reminderOID;
@property (nonatomic, strong) UAReminderRule *reminderRule;
@property (nonatomic, strong) NSManagedObjectID *reminderRuleOID;

@end
