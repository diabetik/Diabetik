//
//  UANoteInputViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 24/02/2013.
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

#import "UANoteInputViewController.h"

@interface UANoteInputViewController ()
{
    UANote *note;
    NSString *title;
}
@end

@implementation UANoteInputViewController

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithMOC:aMOC];
    if (self)
    {
        self.title = NSLocalizedString(@"Add a Note", nil);
        title = NSLocalizedString(@"Note", nil);
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)aEvent andMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithEvent:aEvent andMOC:aMOC];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit Note", nil);
        
        note = (UANote *)aEvent;
        title = note.name;
    }
    
    return self;
}

#pragma mark - Logic
- (NSError *)validationError
{
    if(notes && [notes length])
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

    if(!title || ![title length])
    {
        title = NSLocalizedString(@"Note", nil);
    }
    
    if(!note)
    {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UANote" inManagedObjectContext:self.moc];
        note = (UANote *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.moc];
        note.filterType = [NSNumber numberWithInteger:NoteFilterType];
    }
    note.name = title;
    note.timestamp = self.date;
    
    if(!notes.length) notes = nil;
    note.notes = notes;
    
    // Save our geotag data
    if(![self.lat isEqual:note.lat] || ![self.lon isEqual:note.lon])
    {
        note.lat = self.lat;
        note.lon = self.lon;
    }
    
    // Save our photo
    if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:note.photoPath])
    {
        // If a photo already exists for this entry remove it now
        if(note.photoPath)
        {
            [[UAMediaController sharedInstance] deleteImageWithFilename:note.photoPath success:nil failure:nil];
        }
        
        note.photoPath = self.currentPhotoPath;
    }
    
    NSArray *tags = [[UATagController sharedInstance] fetchTagsInString:notes];
    [[UATagController sharedInstance] assignTags:tags toEvent:note];
    
    [self.moc save:&*error];
    return note;
}

#pragma mark - UI
- (void)changeDate:(id)sender
{
    self.date = [sender date];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
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
        textField.placeholder = NSLocalizedString(@"Title", nil);
        textField.text = title;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.delegate = self;
        textField.inputView = nil;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Title", nil)];
        [cell setDrawsBorder:YES];
    }
    else if(indexPath.row == 1)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Date", nil);
        textField.text = [dateFormatter stringFromDate:self.date];
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.delegate = self;
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
        [cell setDrawsBorder:YES];
    }
    else if(indexPath.row == 2)
    {
        UANotesTextView *textView = (UANotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textViewHeight = textView.contentSize.height;
        
        UAKeyboardAccessoryView *accessoryView = [[UAKeyboardAccessoryView alloc] initWithBackingView:parentVC.keyboardBackingView];
        self.autocompleteTagBar.frame = CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width - parentVC.keyboardBackingView.controlContainer.frame.size.width, accessoryView.frame.size.height);
        [accessoryView.contentView addSubview:self.autocompleteTagBar];
        textView.inputAccessoryView = accessoryView;
        
        [cell setDrawsBorder:NO];
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
    }
    cell.control.tag = indexPath.row;
}

#pragma mark - UI
- (UIColor *)barTintColor
{
    return [UIColor colorWithRed:126.0f/255.0f green:113.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAEventInputViewCell *cell = nil;
    if(indexPath.row == 2)
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
    if(indexPath.row == 2)
    {
        height = textViewHeight;
    }
    
    if(height < 44.0f) height = 44.0f;
    return height;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    
    if(textField.tag == 0)
    {
        title = textField.text;
    }
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)theAutocompleteBar
{
    return [[UATagController sharedInstance] fetchAllTags];
}

@end
