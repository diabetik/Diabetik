//
//  UAInputBaseViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 06/12/2012.
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

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <CoreLocation/CoreLocation.h>

#import "UAUI.h"
#import "UAAppDelegate.h"
#import "UABaseViewController.h"
#import "UAEventController.h"
#import "UATagController.h"
#import "UAMediaController.h"
#import "UATimeReminderViewController.h"

#import "UAInputBaseViewController.h"
#import "UAEventInputViewCell.h"
#import "UAEventInputTextFieldViewCell.h"
#import "UAEventInputTextViewViewCell.h"
#import "TPKeyboardAvoidingScrollView.h"

@class UAInputBaseViewController;
@interface UAInputParentViewController : UABaseViewController <UIActionSheetDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UAEvent *event;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@property (nonatomic, strong) UIPopoverController *popoverVC;
@property (nonatomic, assign, getter=isDisplayingPopover) BOOL displayingPopover;

// Setup
- (id)initWithEventType:(NSInteger)eventType;
- (id)initWithEvent:(UAEvent *)aEvent;
- (id)initWithMedicineAmount:(NSNumber *)amount;

// Logic
- (void)saveEvent:(id)sender;
- (void)deleteEvent:(id)sender;
- (void)discardChanges:(id)sender;
- (void)activateTargetViewController;
- (void)addVC:(UIViewController *)vc;
- (void)removeVC:(UIViewController *)vc;

// UI
- (void)presentAddReminder:(id)sender;
- (void)presentMediaOptions:(id)sender;
- (void)presentGeotagOptions:(id)sender;
- (void)updateNavigationBar;

// UIPopoverController logic
- (void)closeActivePopoverController;

@end
