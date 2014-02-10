//
//  UAAutocompleteBar.h
//  Diabetik
//
//  Created by Nial Giacomelli on 27/12/2012.
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
#import "UAAppDelegate.h"

@class UAAutocompleteBar;
@protocol UAAutocompleteBarDelegate <NSObject>

@required
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)autocompleteBar;
- (void)autocompleteBar:(UAAutocompleteBar *)autocompleteBar didSelectSuggestion:(NSString *)suggestion;

@optional
- (void)addTagCaret;

@end

@interface UAAutocompleteBar : UIView
{
    UIScrollView *scrollView;
    NSMutableArray *buttons;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *suggestions;
@property (nonatomic, assign) BOOL shouldFetchSuggestions;

// Setup
- (id)initWithFrame:(CGRect)frame;

// Logic
- (void)fetchSuggestions;
- (BOOL)showSuggestionsForInput:(NSString *)input;

@end
