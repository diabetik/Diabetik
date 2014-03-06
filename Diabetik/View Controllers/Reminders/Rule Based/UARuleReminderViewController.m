//
//  UARuleReminderViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/05/2013.
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

#import "UARuleReminderViewController.h"
#import "UAEventController.h"
#import "UATagController.h"
#import "UAReminderController.h"

#import "UACategoryInputView.h"

@interface UARuleReminderViewController ()
{
    NSString *ruleTitle;
    NSString *triggerClassName;
    NSString *triggerEventName;
    NSString *triggerTag;
    NSInteger triggerIntervalType;
    double triggerInterval;
    BOOL triggerForAll;
    
    UAReminderRule *existingRule;
    UAAutocompleteBar *nameAutocompleteBar, *tagAutocompleteBar;
}

// UI
- (void)addTrigger:(id)sender;
- (void)toggleEntryTriggers:(id)sender;

@end

@implementation UARuleReminderViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Rule-based Reminder", nil);
    
        ruleTitle = nil;
        triggerClassName = @"UAMedicine";
        triggerEventName = nil;
        triggerTag = nil;
        triggerIntervalType = kMinuteIntervalType;
        triggerInterval = 15;
        triggerForAll = YES;
        
        nameAutocompleteBar = [[UAAutocompleteBar alloc] initWithFrame:CGRectMake(0, 0, 235, 44)];
        nameAutocompleteBar.delegate = self;
        
        tagAutocompleteBar = [[UAAutocompleteBar alloc] initWithFrame:CGRectMake(0, 0, 235, 44)];
        tagAutocompleteBar.delegate = self;
    }
    return self;
}
- (id)initWithReminderRule:(UAReminderRule *)rule
{
    self = [self init];
    if(self)
    {
        ruleTitle = rule.name;
        triggerInterval = [rule.intervalAmount doubleValue];
        triggerIntervalType = [rule.intervalType integerValue];
        
        self.title = NSLocalizedString(@"Edit Reminder", nil);
        self.reminderRule = rule;
        
        UAReminderRule *reminderRule = [self reminderRule];
        if(reminderRule)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:reminderRule.predicate];
            if(predicate)
            {
                [self configureFromPredicate:predicate];
            }
        }
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UAGenericTableViewCell class] forCellReuseIdentifier:@"UAReminderCell"];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(addTrigger:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)addTrigger:(id)sender
{
    [self.view endEditing:YES];
    
    BOOL completedRequiredFields = YES;
    if(triggerInterval <= 0) completedRequiredFields = NO;
    if(!ruleTitle || !ruleTitle.length) completedRequiredFields = NO;
    if(!triggerForAll && ((!triggerEventName || triggerEventName.length == 0) && (!triggerTag || triggerTag.length == 0))) completedRequiredFields = NO;
    
    if(completedRequiredFields)
    {
        NSString *predicateFormat = [NSString stringWithFormat:@"className == '%@'", triggerClassName];
        if(triggerEventName && triggerEventName.length > 0)
        {
            predicateFormat = [predicateFormat stringByAppendingFormat:@" && name ==[cd] '%@'", triggerEventName];
        }
        if(triggerTag && triggerTag.length > 0)
        {
            predicateFormat = [predicateFormat stringByAppendingFormat:@" && ANY tags.nameLC = '%@'", [triggerTag lowercaseString]];
        }
        
        NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            UAReminderRule *newReminderRule = [self reminderRule];
            if(!newReminderRule)
            {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAReminderRule" inManagedObjectContext:moc];
                newReminderRule = (UAReminderRule *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            }
            newReminderRule.name = ruleTitle;
            newReminderRule.predicate = predicateFormat;
            newReminderRule.intervalType = [NSNumber numberWithInteger:triggerIntervalType];
            newReminderRule.intervalAmount = [NSNumber numberWithDouble:triggerInterval];
            
            NSError *error = nil;
            [moc save:&error];
            
            if(error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"We were unable to save your reminder rule for the following reason: %@", nil), [error localizedDescription]]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            else
            {
                [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
                [self handleBack:self withSound:NO];
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"Please complete all required fields", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)toggleEntryTriggers:(id)sender
{
    triggerForAll = !triggerForAll;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Logic
- (void)configureFromPredicate:(NSPredicate *)predicate
{
    if([predicate isKindOfClass:[NSCompoundPredicate class]])
    {
        NSCompoundPredicate *compoundPredicate = (NSCompoundPredicate *)predicate;
        for(NSPredicate *subpredicate in compoundPredicate.subpredicates)
        {
            [self configureFromPredicate:subpredicate];
        }
    }
    else if([predicate isKindOfClass:[NSComparisonPredicate class]])
    {
        NSComparisonPredicate *comparisonPredicate = (NSComparisonPredicate *)predicate;
        [self configureFromComparisonPredicate:comparisonPredicate];
    }
    else
    {
        NSLog(@"Unknown predicate type: %@", [predicate class]);
    }

}
- (void)configureFromComparisonPredicate:(NSComparisonPredicate *)predicate
{
    id value = nil;
    if(predicate.rightExpression.expressionType == NSConstantValueExpressionType)
    {
        value = predicate.rightExpression.constantValue;
    }
    else if(predicate.rightExpression.expressionType == NSKeyPathExpressionType)
    {
        value = predicate.rightExpression.keyPath;
    }
    else if(predicate.rightExpression.expressionType == NSVariableExpressionType)
    {
        value = predicate.rightExpression.variable;
    }
    
    if(value)
    {
        if([predicate.leftExpression.keyPath isEqualToString:@"className"])
        {
            triggerClassName = value;
        }
        else if([predicate.leftExpression.keyPath isEqualToString:@"name"])
        {
            triggerEventName = value;
            triggerForAll = NO;
        }
        else if([predicate.leftExpression.keyPath isEqualToString:@"tags.nameLC"])
        {
            triggerTag = value;
            triggerForAll = NO;
        }
    }
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        switch(indexPath.row)
        {
            case 0:
                triggerClassName = @"UAMedicine";
                break;
            case 1:
                triggerClassName = @"UAActivity";
                break;
            case 2:
                triggerClassName = @"UAMeal";
                break;
        }
        
        [nameAutocompleteBar showSuggestionsForInput:nil];
        [aTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        triggerForAll = !triggerForAll;
        triggerEventName = nil;
        
        [aTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
    }
    else if(section == 1)
    {
        if(triggerForAll) return 1;
        return 3;
    }
    else if(section == 2)
    {
        return 2;
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAReminderCell"];
    cell.textLabel.font = [UAFont standardRegularFontWithSize:16.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:114.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
    
    if(indexPath.section == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.accessoryView = nil;
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Medication", nil);
            cell.accessoryType = [triggerClassName isEqualToString:@"UAMedicine"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Activity", nil);
            cell.accessoryType = [triggerClassName isEqualToString:@"UAActivity"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Food", nil);
            cell.accessoryType = [triggerClassName isEqualToString:@"UAMeal"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;            
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Trigger for all entries", nil);
            cell.accessoryView = nil;

            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
            [switchControl addTarget:self action:@selector(toggleEntryTriggers:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = switchControl;
            
            [switchControl setOn:triggerForAll];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Name", @"The name of an entry");
            
            NSString *placeholder = @"";
            if([triggerClassName isEqualToString:@"UAMedicine"])
            {
                placeholder = NSLocalizedString(@"Medicine name", nil);
            }
            else if([triggerClassName isEqualToString:@"UAMeal"])
            {
                placeholder = NSLocalizedString(@"Meal name", nil);
            }
            else if([triggerClassName isEqualToString:@"UAActivity"])
            {
                placeholder = NSLocalizedString(@"Activity name", nil);
            }
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            textField.delegate = self;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.text = triggerEventName;
            textField.placeholder = placeholder;
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.adjustsFontSizeToFitWidth = NO;
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.textAlignment = NSTextAlignmentRight;
            textField.font = [UAFont standardMediumFontWithSize:16.0f];
            textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.tag = 0;
            
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [nameAutocompleteBar removeFromSuperview];
            
            UIInputView *accessoryView = [[UIInputView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f) inputViewStyle:UIInputViewStyleDefault];
            nameAutocompleteBar.frame = CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width, accessoryView.frame.size.height);
            [accessoryView addSubview:nameAutocompleteBar];
            textField.inputAccessoryView = accessoryView;
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Tag", nil);
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            textField.delegate = self;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.text = triggerTag;
            textField.placeholder = @"A specific entry tag";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.adjustsFontSizeToFitWidth = NO;
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.textAlignment = NSTextAlignmentRight;
            textField.font = [UAFont standardMediumFontWithSize:16.0f];
            textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.tag = 1;
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [tagAutocompleteBar removeFromSuperview];
            
            UIInputView *accessoryView = [[UIInputView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f) inputViewStyle:UIInputViewStyleDefault];
            tagAutocompleteBar.frame = CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width, accessoryView.frame.size.height);
            [accessoryView addSubview:tagAutocompleteBar];
            textField.inputAccessoryView = accessoryView;
        }
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Alert", @"The message shown as part of a reminder");
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
            textField.delegate = self;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.text = ruleTitle;
            textField.placeholder = NSLocalizedString(@"Description", nil);
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.adjustsFontSizeToFitWidth = NO;
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.textAlignment = NSTextAlignmentRight;
            textField.font = [UAFont standardMediumFontWithSize:16.0f];
            textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
            textField.autocorrectionType = UITextAutocorrectionTypeDefault;
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.tag = 2;
            textField.inputAccessoryView = nil;
            
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"After", @"The amount of time to wait after an event occurs before alerting the user");
            
            UACategoryInputView *categoryInputView = [[UACategoryInputView alloc] initWithCategories:@[NSLocalizedString(@"minutes", nil), NSLocalizedString(@"hours", nil), NSLocalizedString(@"days", nil)]];
            categoryInputView.delegate = self;
            [categoryInputView setSelectedIndex:triggerIntervalType];
            
            categoryInputView.textField.textAlignment = NSTextAlignmentRight;
            categoryInputView.textField.text = [NSString stringWithFormat:@"%.0f", triggerInterval];
            categoryInputView.textField.placeholder = @"";
            categoryInputView.textField.keyboardType = UIKeyboardTypeDecimalPad;
            categoryInputView.textField.tag = 3;
            categoryInputView.textField.delegate = self;
            cell.accessoryView = categoryInputView;
        }
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Remind me after adding", @"Remind me after adding [a specific entry type]");
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"Matching these conditions", @"Remind me after adding [a specific entry type] matching [these conditions]");
    }
    else if(section == 2)
    {
        return NSLocalizedString(@"With these settings", @"Remind me after adding [a specific entry type] matching [these conditions] with [these settings]");
    }
    
    return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    UAGenericTableHeaderView *header = [[UAGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newValue = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[[textField superview] superview] superview]];

    if(indexPath.section == 1 && indexPath.row == 1)
    {
        [nameAutocompleteBar showSuggestionsForInput:newValue];
    }
    else if(indexPath.section == 1 && indexPath.row == 2)
    {
        [tagAutocompleteBar showSuggestionsForInput:newValue];
    }
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [nameAutocompleteBar showSuggestionsForInput:nil];
    [nameAutocompleteBar fetchSuggestions];
    [tagAutocompleteBar showSuggestionsForInput:nil];
    [tagAutocompleteBar fetchSuggestions];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview.superview.superview];
    self.activeControlIndexPath = indexPath;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        triggerEventName = [textField text];
    }
    else if(textField.tag == 1)
    {
        triggerTag = [textField text];
    }
    else if(textField.tag == 2)
    {
        ruleTitle = [textField text];
    }
    else if(textField.tag == 3)
    {
        triggerInterval = [[textField text] integerValue];
    }
    
    self.activeControlIndexPath = nil;
}

#pragma mark - UACategoryInputViewDelegate methods
- (void)categoryInputView:(UACategoryInputView *)categoryInputView didSelectOption:(NSUInteger)index
{
    triggerIntervalType = index;
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)theAutocompleteBar
{
    if([theAutocompleteBar isEqual:nameAutocompleteBar])
    {
        if([triggerClassName isEqualToString:@"UAMedicine"])
        {
            return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:MedicineFilterType];
        }
        if([triggerClassName isEqualToString:@"UAMeal"])
        {
            return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:MealFilterType];
        }
        if([triggerClassName isEqualToString:@"UAActivity"])
        {
            return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:ActivityFilterType];
        }
    }
    else if([theAutocompleteBar isEqual:tagAutocompleteBar])
    {
        return [[UATagController sharedInstance] fetchAllTags];
    }
    
    return nil;
}
- (void)autocompleteBar:(UAAutocompleteBar *)autocompleteBar didSelectSuggestion:(NSString *)suggestion
{
    [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    UITextField *textField = (UITextField *)cell.accessoryControl;
    textField.text = suggestion;
}

@end
