//
//  UARuleReminderViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 02/05/2013.
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

#import "UABaseViewController.h"
#import "UAReminderRule.h"

@interface UARuleReminderViewController : UABaseTableViewController <UITextFieldDelegate, UIAlertViewDelegate, UAAutocompleteBarDelegate>

// Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC;
- (id)initWithReminderRule:(UAReminderRule *)rule andMOC:(NSManagedObjectContext *)aMOC;

// Logic
- (void)deleteReminderRule;

// UI
- (void)addTrigger:(id)sender;
- (void)selectIntervalType:(UIButton *)sender;

@end
