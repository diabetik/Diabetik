//
//  UATimeReminderViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 02/03/2013.
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

#import <UIKit/UIKit.h>
#import "UAUI.h"

#import "UAInputLabel.h"
#import "UAReminderRepeatViewController.h"
#import "UAReminderController.h"

@interface UATimeReminderViewController : UABaseTableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UAReminderRepeatDelegate, UAInputLabelDelegate>

// Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC;
- (id)initWithMOC:(NSManagedObjectContext *)aMOC andDate:(NSDate *)aDate;
- (id)initWithReminder:(UAReminder *)theReminder andMOC:(NSManagedObjectContext *)aMOC;

// Logic
- (void)addReminder:(id)sender;

// UI
- (void)changeDate:(UIDatePicker *)sender;
- (void)changeTime:(UIDatePicker *)sender;
- (void)changeType:(UISegmentedControl *)sender;

@end
