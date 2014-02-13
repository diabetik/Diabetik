//
//  UAKeyboardShortcutAccessoryView.h
//  Diabetik
//
//  Created by Nial Giacomelli on 31/01/2014.
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
#import "UAKeyboardShortcutButton.h"

@class UAKeyboardShortcutAccessoryView;
@protocol UAKeyboardShortcutDelegate <NSObject>
- (void)keyboardShortcut:(UAKeyboardShortcutAccessoryView *)shortcutView didPressButton:(UAKeyboardShortcutButton *)button;
@end

@interface UAKeyboardShortcutAccessoryView : UIView <UAAutocompleteBarDelegate>
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UAAutocompleteBar *autocompleteBar;
@property (nonatomic, assign) BOOL showingAutocompleteBar;
@property (nonatomic, weak) id<UAKeyboardShortcutDelegate, UAAutocompleteBarDelegate> delegate;

@property (nonatomic, strong) UAKeyboardShortcutButton *tagButton;
@property (nonatomic, strong) UAKeyboardShortcutButton *photoButton;
@property (nonatomic, strong) UAKeyboardShortcutButton *shareButton;
@property (nonatomic, strong) UAKeyboardShortcutButton *locationButton;
@property (nonatomic, strong) UAKeyboardShortcutButton *reminderButton;
@property (nonatomic, strong) UAKeyboardShortcutButton *deleteButton;

// Logic
- (void)showAutocompleteSuggestionsForInput:(NSString *)text;

@end


