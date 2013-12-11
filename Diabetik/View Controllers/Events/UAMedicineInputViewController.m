//
//  UAMedicineInputViewController.m
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

#import "NSDate+Extension.h"
#import "NSString+Extension.h"

#import "UAInsulinCalculatorViewController.h"
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
@synthesize medicine = _medicine;
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
- (id)initWithEvent:(UAEvent *)aEvent
{
    self = [super initWithEvent:aEvent];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit Medicine", nil);
        
        NSNumberFormatter *valueFormatter = [UAHelper glucoseNumberFormatter];
        
        _medicine = (UAMedicine *)aEvent;
        _type = [self.medicine.type integerValue];
        _name = self.medicine.name;
        _amount = [valueFormatter stringFromNumber:self.medicine.amount];
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    if(!self.medicine && isFirstLoad)
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
                    if(!medicineVC.medicine)
                    {
                        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAMedicine" inManagedObjectContext:self.moc];
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
                weakSelf.name = [event name];
                weakSelf.type = [[event type] integerValue];
                usingSmartInput = YES;
                
                UAEventInputViewCell *cell = (UAEventInputViewCell *)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                weakSelf.previouslyActiveControlIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [cell.control becomeFirstResponder];
                
            } failure:^{
                UAEventInputViewCell *cell = (UAEventInputViewCell *)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell.control becomeFirstResponder];
            }];
        }
    }
    
    [super viewWillAppear:animated];
}
- (void)didBecomeActive:(BOOL)editing
{
    [parentVC updateKeyboardButtons];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:usingSmartInput ? 1 : 0 inSection:0];
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    // Select our first input field
    if(editing)
    {
        [cell.control becomeFirstResponder];
    }
    
    self.previouslyActiveControlIndexPath = indexPath;
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
    
    NSNumberFormatter *valueFormatter = [UAHelper glucoseNumberFormatter];

    if(!self.medicine)
    {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAMedicine" inManagedObjectContext:self.moc];
        self.medicine = (UAMedicine *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.moc];
        self.medicine.filterType = [NSNumber numberWithInteger:MedicineFilterType];
    }
    self.medicine.amount = [valueFormatter numberFromString:self.amount];
    self.medicine.name = self.name;
    self.medicine.timestamp = self.date;
    self.medicine.type = [NSNumber numberWithInt:self.type];
    
    if(!notes.length) notes = nil;
    self.medicine.notes = notes;
    
    // Save our geotag data
    if(![self.lat isEqual:self.medicine.lat] || ![self.lon isEqual:self.medicine.lon])
    {
        self.medicine.lat = self.lat;
        self.medicine.lon = self.lon;
    }
    
    // Save our photo
    if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:self.medicine.photoPath])
    {
        // If a photo already exists for this entry remove it now
        if(self.medicine.photoPath)
        {
            [[UAMediaController sharedInstance] deleteImageWithFilename:self.medicine.photoPath success:nil failure:nil];
        }
        
        self.medicine.photoPath = self.currentPhotoPath;
    }
    
    NSArray *tags = [[UATagController sharedInstance] fetchTagsInString:notes];
    [[UATagController sharedInstance] assignTags:tags toEvent:self.medicine];
    
    [self.moc save:&*error];
    return self.medicine;
}
- (void)selectType:(UIButton *)sender
{
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
    [cell setDrawsBorder:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row == 0)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Medication", nil);
        textField.text = self.name;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
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
        textField.placeholder = NSLocalizedString(@"Amount taken", nil);
        textField.text = self.amount;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.inputView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Amount", nil)];
        
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
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        textField.inputAccessoryView = nil;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    }
    else if(indexPath.row == 3)
    {
        UANotesTextView *textView = (UANotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textViewHeight = textView.intrinsicContentSize.height;
        
        UAKeyboardAccessoryView *accessoryView = [[UAKeyboardAccessoryView alloc] initWithBackingView:parentVC.keyboardBackingView];
        self.autocompleteTagBar.frame = CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width - parentVC.keyboardBackingView.controlContainer.frame.size.width, accessoryView.frame.size.height);
        [accessoryView.contentView addSubview:self.autocompleteTagBar];
        textView.inputAccessoryView = accessoryView;
        
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
        height = textViewHeight;
    }
    
    if(height < 44.0f) height = 44.0f;
    return height;
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)theAutocompleteBar
{
    if([theAutocompleteBar isEqual:self.autocompleteBar])
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
        [self.autocompleteBar showSuggestionsForInput:[textField text]];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];

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
        [self.autocompleteBar showSuggestionsForInput:newValue];
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
