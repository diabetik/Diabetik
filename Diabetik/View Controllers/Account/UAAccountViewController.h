//
//  UAAccountViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 01/03/2013.
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
#import "UAAccountController.h"
#import "UADeleteButton.h"
#import "UAAccount.h"

@interface UAAccountViewController : UABaseTableViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UAInputLabelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC;
- (id)initWithAccount:(UAAccount *)account andMOC:(NSManagedObjectContext *)aMOC;

// UI
- (void)changeDOB:(UIDatePicker *)sender;
- (void)changeAvatar:(id)sender;
- (void)changeGender:(UISegmentedControl *)sender;
- (void)triggerDeleteEvent:(id)sender;

@end
