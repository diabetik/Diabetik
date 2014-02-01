//
//  UAKeyboardShortcutAccessoryView.h
//  Diabetik
//
//  Created by Nial Giacomelli on 31/01/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
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


