//
//  UAActivityInputViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 05/12/2012.
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

#import "UAActivityInputViewController.h"

#define kDatePickerViewTag 1
#define kToolbarViewTag 2
#define kNameInputControlTag 3
#define kMinutesInputControlTag 4
#define kDateInputControlTag 5
#define kIconTag 6

@interface UAActivityInputViewController ()
{
    NSString *name;
    NSString *minutes;
}
@end

@implementation UAActivityInputViewController

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Add Activity", nil);
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit Activity", nil);
        
        UAActivity *activity = (UAActivity *)[self event];
        if(activity)
        {
            name = activity.name;
            minutes = [NSString stringWithFormat:@"%.0f", [activity.minutes doubleValue]];
        }
    }
    
    return self;
}

#pragma mark - Logic
- (NSError *)validationError
{
    if(name && [name length])
    {
        if([self.date compare:[NSDate date]] != NSOrderedAscending)
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:NSLocalizedString(@"You cannot enter an event in the future", nil) forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
        }
    }
    else
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please complete all required fields", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    
    return nil;
}
- (UAEvent *)saveEvent:(NSError **)error
{
    [self.view endEditing:YES];

    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        UAActivity *activity = (UAActivity *)[self event];
        if(!activity)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAActivity" inManagedObjectContext:moc];
            activity = (UAActivity *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            activity.filterType = [NSNumber numberWithInteger:ActivityFilterType];
        }
        activity.name = name;
        activity.timestamp = self.date;
        activity.minutes = [NSNumber numberWithDouble:[minutes doubleValue]];
        
        if(!notes.length) notes = nil;
        activity.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:activity.lat] || ![self.lon isEqual:activity.lon])
        {
            activity.lat = self.lat;
            activity.lon = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:activity.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(activity.photoPath)
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:activity.photoPath success:nil failure:nil];
            }
            
            activity.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[UATagController sharedInstance] fetchTagsInString:notes];
        [[UATagController sharedInstance] assignTags:tags toEvent:activity];
        
        [moc save:&*error];
        return activity;
    }
    else
    {
        if(error)
        {
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    return nil;
}

#pragma mark - UI
- (void)changeDate:(id)sender
{
    self.date = [sender date];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell)
    {
        UITextField *textField = (UITextField *)cell.control;
        [textField setText:[dateFormatter stringFromDate:self.date]];
    }
}
- (void)configureAppearanceForTableViewCell:(UAEventInputViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell resetCell];
    
    if(indexPath.row == 0)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Activity", @"Activity (physical exercise)");
        textField.text = name;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Name", nil)];
    }
    else if(indexPath.row == 1)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Minutes", nil);
        textField.text = minutes;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Time", nil)];
    }
    else if(indexPath.row == 2)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Date", nil);
        textField.text = [dateFormatter stringFromDate:self.date];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker setDate:self.date];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    }
    else if(indexPath.row == 3)
    {
        UAEventNotesTextView *textView = (UAEventNotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textView.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    
    cell.control.tag = indexPath.row;
}
- (UIImage *)navigationBarBackgroundImage
{
    return [UIImage imageNamed:@"ActivityNavBarBG"];
}
- (UIColor *)tintColor
{
    return [UIColor colorWithRed:127.0f/255.0f green:192.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAEventInputViewCell *cell = nil;
    if(indexPath.row == 3)
    {
        cell = (UAEventInputTextViewViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAEventInputTextViewViewCell"];
        if (!cell)
        {
            cell = [[UAEventInputTextViewViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAEventInputTextViewViewCell"];
        }
    }
    else
    {
        cell = (UAEventInputTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAEventTextFieldViewCell"];
        if (!cell)
        {
            cell = [[UAEventInputTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAEventTextFieldViewCell"];
        }
    }
    
    [self configureAppearanceForTableViewCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0.0;
    if(indexPath.row == 3)
    {
        dummyNotesTextView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width-88.0f, 0.0f);
        dummyNotesTextView.text = notes;
        height = [dummyNotesTextView height];
    }
    else if(indexPath.row == 4)
    {
        height = 170.0f;
    }
    
    if(height < 44.0f) height = 44.0f;
    return height;
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)theAutocompleteBar
{
    if(self.activeControlIndexPath.row == 0)
    {
        return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:ActivityFilterType];
    }
    else
    {
        return [[UATagController sharedInstance] fetchAllTags];
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        name = textField.text;
    }
    else if(textField.tag == 1)
    {
        minutes = textField.text;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 2)
    {
        return NO;
    }
    else if(textField.tag == 0)
    {
        NSString *fullText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:fullText];
    }
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    }
    
    return YES;
}

@end
