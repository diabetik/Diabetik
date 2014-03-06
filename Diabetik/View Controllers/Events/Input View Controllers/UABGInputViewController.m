//
//  UABGInputViewController.m
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

#import "UABGInputViewController.h"

#define kDatePickerViewTag 1
#define kToolbarViewTag 2
#define kValueInputControlTag 3
#define kDateInputControlTag 4
#define kIconTag 5

@interface UABGInputViewController ()
{
    NSString *value;
    NSString *mgValue;
    NSString *mmoValue;
}
@end

@implementation UABGInputViewController

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Add a Reading", @"Add blood glucose reading");
        value = @"";
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit Reading", @"Edit blood glucose reading");
        
        NSNumberFormatter *valueFormatter = [UAHelper glucoseNumberFormatter];
        UAReading *reading = (UAReading *)[self event];
        if(reading)
        {
            mmoValue = [valueFormatter stringFromNumber:reading.mmoValue];
            mgValue = [valueFormatter stringFromNumber:reading.mgValue];
            
            NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
            if(unitSetting == BGTrackingUnitMG)
            {
                value = mgValue;
            }
            else
            {
                value = mmoValue;
            }
        }
    }
    
    return self;
}

#pragma mark - Logic
- (NSError *)validationError
{
    if(value && [value length])
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
        // Convert our input into the right units
        NSNumberFormatter *valueFormatter = [UAHelper glucoseNumberFormatter];
        NSInteger unitSetting = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
        if(unitSetting == BGTrackingUnitMG)
        {
            mgValue = value;
            
            double convertedValue = [[valueFormatter numberFromString:mgValue] doubleValue] * 0.0555;
            mmoValue = [NSString stringWithFormat:@"%f", convertedValue];
        }
        else
        {
            mmoValue = value;
            
            double convertedValue = round([[valueFormatter numberFromString:mmoValue] doubleValue] * 18.0182);
            mgValue = [NSString stringWithFormat:@"%f", convertedValue];
        }

        UAReading *reading = (UAReading *)[self event];
        if(!reading)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAReading" inManagedObjectContext:moc];
            reading = (UAReading *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            reading.filterType = [NSNumber numberWithInteger:ReadingFilterType];
            reading.name = NSLocalizedString(@"Blood glucose level", nil);
        }
        reading.mmoValue = [NSNumber numberWithDouble:[[valueFormatter numberFromString:mmoValue] doubleValue]];
        reading.mgValue = [NSNumber numberWithDouble:[[valueFormatter numberFromString:mgValue] doubleValue]];
        reading.timestamp = self.date;
        
        if(!notes.length) notes = nil;
        reading.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:reading.lat] || ![self.lon isEqual:reading.lon])
        {
            reading.lat = self.lat;
            reading.lon = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:reading.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(reading.photoPath)
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:reading.photoPath success:nil failure:nil];
            }
            
            reading.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[UATagController sharedInstance] fetchTagsInString:notes];
        [[UATagController sharedInstance] assignTags:tags toEvent:reading];
        
        [moc save:&*error];
        
        return reading;
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
    [cell resetCell];
    
    if(indexPath.row == 0)
    {
        NSString *placeholder = [NSString stringWithFormat:@"%@ (mg/dL)", NSLocalizedString(@"BG level", @"Blood glucose level")];
        NSInteger units = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
        if(units != BGTrackingUnitMG)
        {
            placeholder = [NSString stringWithFormat:@"%@ (mmoI/L)", NSLocalizedString(@"BG level", @"Blood glucose level")];
        }
        
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = placeholder;
        textField.text = value;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Value", nil)];
    }
    else if(indexPath.row == 1)
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
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    }
    else if(indexPath.row == 2)
    {
        UAEventNotesTextView *textView = (UAEventNotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textView.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        /*
        UAKeyboardAccessoryView *accessoryView = [[UAKeyboardAccessoryView alloc] initWithBackingView:parentVC.keyboardBackingView];
        self.autocompleteTagBar.frame = accessoryView.contentView.bounds;
        [accessoryView.contentView addSubview:self.autocompleteTagBar];
        textView.inputAccessoryView = accessoryView;
        */
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    
    cell.control.tag = indexPath.row;
}

#pragma mark - UI
- (UIImage *)navigationBarBackgroundImage
{
    return [UIImage imageNamed:@"ReadingNavBarBG"];
}
- (UIColor *)tintColor
{
    return [UIColor colorWithRed:254.0f/255.0f green:96.0f/255.0f blue:111.0f/255.0f alpha:1.0f];
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
        dummyNotesTextView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width-88.0f, 0.0f);
        dummyNotesTextView.text = notes;
        height = [dummyNotesTextView height];
    }
    else if(indexPath.row == 3)
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
        return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:ReadingFilterType];
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
        value = textField.text;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 1)
    {
        return NO;
    }
    
    return YES;
}

@end
