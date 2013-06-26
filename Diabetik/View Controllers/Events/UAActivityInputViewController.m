//
//  UAActivityInputViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 05/12/2012.
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
    
    UAActivity *activity;
}
@end

@implementation UAActivityInputViewController

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithMOC:aMOC];
    if (self) {
        self.title = NSLocalizedString(@"Add Activity", nil);
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)aEvent andMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithEvent:aEvent andMOC:aMOC];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit Activity", nil);
        
        activity = (UAActivity *)aEvent;
        name = activity.name;
        minutes = [NSString stringWithFormat:@"%.0f", [activity.minutes doubleValue]];
    }
    
    return self;
}

#pragma mark - Logic
- (NSError *)validationError
{
    if(name && [name length])
    {
        if([self.date compare:[NSDate date]] == NSOrderedAscending)
        {
            UAAccount *activeAccount = [[UAAccountController sharedInstance] activeAccountInContext:self.moc];
            if(!activeAccount)
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:NSLocalizedString(@"We were unable to save your activity. Please try again!", nil) forKey:NSLocalizedDescriptionKey];
                return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
            }
        }
        else
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

    UAAccount *activeAccount = [[UAAccountController sharedInstance] activeAccountInContext:self.moc];
    if(activeAccount)
    {
        if(!activity)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAActivity" inManagedObjectContext:self.moc];
            activity = (UAActivity *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.moc];
            activity.filterType = [NSNumber numberWithInteger:ActivityFilterType];
            activity.account = activeAccount;
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
        
        [self.moc save:&*error];
        return activity;
    }
    
    return nil;
}

// UI
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
    [cell setDrawsBorder:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row == 0)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Activity", nil);
        textField.text = name;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.delegate = self;
        textField.inputView = nil;
        
        UAKeyboardAccessoryView *accessoryView = [[UAKeyboardAccessoryView alloc] initWithBackingView:parentVC.keyboardBackingView];
        self.autocompleteBar.frame = CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width - parentVC.keyboardBackingView.controlContainer.frame.size.width, accessoryView.frame.size.height);
        [accessoryView.contentView addSubview:self.autocompleteBar];
        textField.inputAccessoryView = accessoryView;
        
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
        textField.inputView = nil;
        
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
        textField.inputView = nil;
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker setDate:self.date];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    }
    else if(indexPath.row == 3)
    {
        UANotesTextView *textView = (UANotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textViewHeight = textView.contentSize.height;
        
        UAKeyboardAccessoryView *accessoryView = [[UAKeyboardAccessoryView alloc] initWithBackingView:parentVC.keyboardBackingView];
        self.autocompleteTagBar.frame = CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width - parentVC.keyboardBackingView.controlContainer.frame.size.width, accessoryView.frame.size.height);
        [accessoryView.contentView addSubview:self.autocompleteTagBar];
        textView.inputAccessoryView = accessoryView;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    
    cell.control.tag = indexPath.row;
}

#pragma mark - Social helpers
- (NSString *)facebookSocialMessageText
{
    if(minutes && [minutes length] && name && [name length])
    {
        return [NSString stringWithFormat:NSLocalizedString(@"I just spent %@ minutes %@ and tracked it with Diabetik", nil), minutes, name];
    }
    
    return [super twitterSocialMessageText];
}
- (NSString *)twitterSocialMessageText
{
    if(minutes && [minutes length] && name && [name length])
    {
        return [NSString stringWithFormat:NSLocalizedString(@"I just spent %@ minutes %@ and tracked it with @diabetikapp", nil), minutes, name];
    }
    
    return [super twitterSocialMessageText];
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
        CGSize size = [notes sizeWithFont:[UAFont standardDemiBoldFontWithSize:16.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width-85.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        height = textViewHeight > 0 ? textViewHeight : size.height + 80.0f;
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
    if([theAutocompleteBar isEqual:self.autocompleteBar])
    {
        return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:ActivityFilterType];
    }
    else
    {
        return [[UATagController sharedInstance] fetchAllTagsForAccount:[[UAAccountController sharedInstance] activeAccount]];
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
    
    if(textField.tag == 0)
    {
        [self.autocompleteBar showSuggestionsForInput:[textField text]];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    
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
        [self.autocompleteBar showSuggestionsForInput:fullText];
    }
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        [self.autocompleteBar showSuggestionsForInput:nil];
    }
    
    return YES;
}

@end
