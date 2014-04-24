//
//  UABaseViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 11/12/2012.
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
#import "GAI.h"
#import "TPKeyboardAvoidingTableView.h"

#import "UAUI.h"
#import "UAHelper.h"

@interface UABaseViewController : GAITrackedViewController <UIGestureRecognizerDelegate>
{
    BOOL isVisible;
    BOOL isFirstLoad;
    
    UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer;
}
@property (nonatomic, strong) UIView *activeField;
@property (nonatomic, strong) NSIndexPath *activeControlIndexPath;

// Logic
- (void)reloadViewData:(NSNotification *)note;
- (void)handleBack:(id)sender withSound:(BOOL)playSound;
- (void)handleBack:(id)sender;
- (BOOL)isPresentedModally;
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender;

// Keyboard notifications
- (void)keyboardWillBeShown:(NSNotification *)aNotification;
- (void)keyboardWasShown:(NSNotification *)aNotification;
- (void)keyboardWillBeHidden:(NSNotification *)aNotification;
- (void)keyboardWasHidden:(NSNotification *)aNotification;

// Notifications
- (void)coreDataDidChange:(NSNotification *)note;
- (void)iCloudDataDidChange:(NSNotification *)note;

// Helpers
- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification *)notification;

// Helpers
- (UIView *)dismissableView;

@end

@interface UABaseTableViewController : UABaseViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableViewStyle tableStyle;
}
@property (nonatomic, strong) UITableView *tableView;

// Setup
- (id)initWithStyle:(UITableViewStyle)style;

@end
