//
//  UACategoryInputView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/02/2014.
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

#import "UACategoryInputView.h"

@interface UACategoryInputView ()
@property (nonatomic, strong) NSArray *categories;

// Logic
- (void)didTapSelectorButton:(UACategorySelectorButton *)button;
@end

@implementation UACategoryInputView

#pragma mark - Setup
- (id)initWithCategories:(NSArray *)theCategories
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _categories = theCategories;
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.adjustsFontSizeToFitWidth = NO;
        _textField.font = [UAFont standardMediumFontWithSize:16.0f];
        _textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        _textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        
        _selectorButton = [[UACategorySelectorButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 28.0f)];
        [_selectorButton addTarget:self action:@selector(didTapSelectorButton:) forControlEvents:UIControlEventTouchUpInside];
        self.selectedIndex = 0;
        
        [self addSubview:_textField];
        [self addSubview:_selectorButton];
    }
    return self;
}

#pragma mark - Logic
- (void)didTapSelectorButton:(UACategorySelectorButton *)button
{
    UAActionSheet *actionSheet = [[UAActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.acceptsFirstResponder = NO;
    
    for(NSString *category in self.categories)
    {
        [actionSheet addButtonWithTitle:category];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet setCancelButtonIndex:[self.categories count]];
    [actionSheet showInView:self];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat spacing = 10.0f;
    self.textField.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width - (self.selectorButton.bounds.size.width + spacing), self.bounds.size.height);
    self.selectorButton.frame = CGRectMake(self.textField.frame.origin.x + self.textField.frame.size.width + spacing, 0.0f, self.selectorButton.bounds.size.width, self.bounds.size.height);
}

#pragma mark - Accessors
- (void)setSelectedIndex:(NSUInteger)index
{
    _selectedIndex = index;
    
    [self.selectorButton setTitle:self.categories[index]];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != [actionSheet cancelButtonIndex])
    {
        self.selectedIndex = buttonIndex;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(categoryInputView:didSelectOption:)])
        {
            [self.delegate categoryInputView:self didSelectOption:buttonIndex];
        }
    }
}

@end
