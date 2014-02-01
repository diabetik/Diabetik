//
//  UAMedicineInputViewController.m
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

#import "NSDate+Extension.h"
#import "NSString+Extension.h"

#import "UAMedicineInputViewController.h"
#import "UAAppDelegate.h"

#define kDatePickerViewTag 1
#define kToolbarViewTag 2
#define kNameInputControlTag 3
#define kAmountInputControlTag 4
#define kDateInputControlTag 5
#define kIconTag 6

@interface UAMedicineInputViewController ()
@end

@implementation UAMedicineInputViewController
@synthesize type = _type;
@synthesize name = _name;
@synthesize amount = _amount;

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Add Medicine", nil);
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit Medicine", nil);
        
        NSNumberFormatter *valueFormatter = [UAHelper standardNumberFormatter];
        
        UAMedicine *medicine = (UAMedicine *)theEvent;
        if(medicine)
        {
            _type = [medicine.type integerValue];
            _name = medicine.name;
            _amount = [valueFormatter stringFromNumber:medicine.amount];
        }
    }
    
    return self;
}
- (id)initWithAmount:(NSNumber *)amount
{
    self = [self init];
    if(self)
    {
        _amount = [amount stringValue];
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    
    if(![self event] && moc && isFirstLoad)
    {
        if([[NSUserDefaults standardUserDefaults] boolForKey:kUseSmartInputKey])
        {
            // Because the user may have other entry screens open we need to
            // create temporary UAMedicine objects so that
            // they can be factored into the Smart Input calculation
            NSMutableArray *unsavedEntries = [NSMutableArray array];
            for(UAInputBaseViewController *vc in parentVC.viewControllers)
            {
                if([vc isKindOfClass:[self class]] && vc != self)
                {
                    UAMedicineInputViewController *medicineVC = (UAMedicineInputViewController *)vc;
                    if(![medicineVC event])
                    {
                        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAMedicine" inManagedObjectContext:moc];
                        UAMedicine *entry = [[UAMedicine alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
                        entry.name = medicineVC.name;
                        entry.type = [NSNumber numberWithInteger:medicineVC.type];
                        entry.timestamp = medicineVC.date;
                        [unsavedEntries addObject:entry];
                    }
                }
            }
            
            // Perform a Smart Input calculation
            __weak typeof(self) weakSelf = self;
            [[UAEventController sharedInstance] attemptSmartInputWithExistingEntries:unsavedEntries success:^(UAMedicine *event) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                strongSelf.name = [event name];
                strongSelf.type = [[event type] integerValue];
                usingSmartInput = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                                withRowAnimation:UITableViewRowAnimationNone];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    UAEventInputViewCell *cell = (UAEventInputViewCell *)[strongSelf.tableView cellForRowAtIndexPath:indexPath];
                    [cell.control becomeFirstResponder];
                });
                
            } failure:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                    UAEventInputViewCell *cell = (UAEventInputViewCell *)[strongSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [cell.control becomeFirstResponder];
                });
            }];
        }
    }
    
    [super viewWillAppear:animated];
}
- (void)didBecomeActive:(BOOL)editing
{
    if(!self.activeControlIndexPath)
    {
        self.activeControlIndexPath = [NSIndexPath indexPathForRow:usingSmartInput ? 1 : 0 inSection:0];
    }
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    [cell.control becomeFirstResponder];
    
    self.activeView = YES;
}
- (NSError *)validationError
{
    if(self.amount && [self.amount length] && self.name && [self.name length])
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
        NSNumberFormatter *valueFormatter = [UAHelper standardNumberFormatter];

        UAMedicine *medicine = (UAMedicine *)[self event];
        if(!medicine)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAMedicine" inManagedObjectContext:moc];
            medicine = (UAMedicine *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            medicine.filterType = [NSNumber numberWithInteger:MedicineFilterType];
        }
        medicine.amount = [valueFormatter numberFromString:self.amount];
        medicine.name = self.name;
        medicine.timestamp = self.date;
        medicine.type = [NSNumber numberWithInt:self.type];
        
        if(!notes.length) notes = nil;
        medicine.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:medicine.lat] || ![self.lon isEqual:medicine.lon])
        {
            medicine.lat = self.lat;
            medicine.lon = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:medicine.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(medicine.photoPath)
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:medicine.photoPath success:nil failure:nil];
            }
            
            medicine.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[UATagController sharedInstance] fetchTagsInString:notes];
        [[UATagController sharedInstance] assignTags:tags toEvent:medicine];
        
        [moc save:&*error];
        
        return medicine;
    }
    else
    {
        *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
    }
    
    return nil;
}
- (void)selectType:(UIButton *)sender
{
    /*
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell)
    {
        UAKeyboardAccessoryView *accessoryView = (UAKeyboardAccessoryView *)cell.control.inputAccessoryView;
        NSArray *controls = [(UASuggestionBar *)[accessoryView.contentView.subviews objectAtIndex:0] suggestions];
        for(id control in controls)
        {
            if([control isKindOfClass:[UAAutocompleteBarButton class]])
            {
                [(UAAutocompleteBarButton *)control setSelected:NO];
            }
        }
    }
    
    [sender setSelected:YES];
    self.type = sender.tag;
    */
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
        textField.placeholder = NSLocalizedString(@"Medication", nil);
        textField.text = self.name;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Name", nil)];
    }
    else if(indexPath.row == 1)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Amount taken", nil);
        textField.text = self.amount;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Amount", nil)];
        /*
        UAKeyboardAccessoryView *accessoryView = [[UAKeyboardAccessoryView alloc] initWithBackingView:parentVC.keyboardBackingView];
        
        UASuggestionBar *suggestionBar = [[UASuggestionBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width - parentVC.keyboardBackingView.controlContainer.frame.size.width, accessoryView.frame.size.height)];
        [accessoryView.contentView addSubview:suggestionBar];
        
        UAAutocompleteBarButton *units = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(0.0f, 12.0f, 0.0f, 27.0f)];
        [units setTitle:NSLocalizedString(@"units", nil) forState:UIControlStateNormal];
        [units addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        [units setTag:kMedicineTypeUnits];
        
        UAAutocompleteBarButton *mg = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(0.0f, 12.0f, 0.0f, 27.0f)];
        [mg setTitle:NSLocalizedString(@"mg", nil) forState:UIControlStateNormal];
        [mg addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        [mg setTag:kMedicineTypeMG];
        
        UAAutocompleteBarButton *pills = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(0.0f, 12.0f, 0.0f, 27.0f)];
        [pills setTitle:NSLocalizedString(@"pills", nil) forState:UIControlStateNormal];
        [pills addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        [pills setTag:kMedicineTypePills];
        
        UAAutocompleteBarButton *puffs = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(0.0f, 12.0f, 0.0f, 27.0f)];
        [puffs setTitle:NSLocalizedString(@"puffs", nil) forState:UIControlStateNormal];
        [puffs addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        [puffs setTag:kMedicineTypePuffs];
        
        [suggestionBar addSuggestions:@[units, mg, pills, puffs]];
        
        UAAutocompleteBarButton *button = nil;
        if(self.type == kMedicineTypeUnits)
        {
            button = units;
        }
        else if(self.type == kMedicineTypeMG)
        {
            button = mg;
        }
        else if(self.type == kMedicineTypePills)
        {
            button = pills;
        }
        else if(self.type == kMedicineTypePuffs)
        {
            button = puffs;
        }
        [button setSelected:YES];
        
        textField.inputAccessoryView = accessoryView;
         */
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
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    }
    else if(indexPath.row == 3)
    {
        UANotesTextView *textView = (UANotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textView.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    
    cell.control.tag = indexPath.row;
}

#pragma mark - UI
- (UIColor *)barTintColor
{
    return [UIColor colorWithRed:192.0f/255.0f green:138.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

#pragma mark - Social helpers
- (NSString *)facebookSocialMessageText
{
    if(self.name && [self.name length] && self.amount && [self.amount length])
    {
        NSString *typeHR = [[UAEventController sharedInstance] medicineTypeHR:self.type];
        return [NSString stringWithFormat:NSLocalizedString(@"I just took %@ %@ of %@ and recorded it with Diabetik", nil), self.amount, typeHR, self.name];
    }
    
    return [super twitterSocialMessageText];
}
- (NSString *)twitterSocialMessageText
{
    if(self.name && [self.name length] && self.amount && [self.amount length])
    {
        NSString *typeHR = [[UAEventController sharedInstance] medicineTypeHR:self.type];
        return [NSString stringWithFormat:NSLocalizedString(@"I just took %@ %@ of %@ and recorded it with @diabetikapp", nil), self.amount, typeHR, self.name];
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
        dummyNotesTextView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width-88.0f, 0.0f);
        dummyNotesTextView.text = notes;
        height = [dummyNotesTextView height];
    }
    
    if(height < 44.0f) height = 44.0f;
    return height;
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)theAutocompleteBar
{
    if(self.activeControlIndexPath.row == 0)
    {
        return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:MedicineFilterType];
    }
    else
    {
        return [[UATagController sharedInstance] fetchAllTags];
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
    
    if(textField.tag == 0)
    {
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:[textField text]];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        self.name = textField.text;
    }
    else if(textField.tag == 1)
    {
        self.amount = textField.text;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newValue = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField.tag == 2)
    {
        return NO;
    }
    else if(textField.tag == 0)
    {
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:newValue];
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
