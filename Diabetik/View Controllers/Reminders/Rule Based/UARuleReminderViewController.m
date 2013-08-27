//
//  UARuleReminderViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/05/2013.
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

#import "UARuleReminderViewController.h"
#import "UAEventController.h"
#import "UAReminderController.h"

@interface UARuleReminderViewController ()
{
    NSString *ruleTitle;
    NSString *triggerClassName;
    NSString *triggerEventName;
    NSInteger triggerIntervalType;
    double triggerInterval;
    BOOL triggerForAll;
    
    UAReminderRule *existingRule;
    
    UAAutocompleteBar *autocompleteBar;
}
@end

@implementation UARuleReminderViewController
@synthesize moc = _moc;

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Rule-based Reminder", nil);
        _moc = aMOC;
        
        ruleTitle = nil;
        triggerClassName = @"UAMedicine";
        triggerEventName = nil;
        triggerIntervalType = kMinuteIntervalType;
        triggerInterval = 15;
        triggerForAll = YES;
        
        autocompleteBar = [[UAAutocompleteBar alloc] initWithFrame:CGRectMake(0, 0, 235, 44)];
        autocompleteBar.showTagButton = NO;
        autocompleteBar.delegate = self;
    }
    return self;
}
- (id)initWithReminderRule:(UAReminderRule *)rule andMOC:(NSManagedObjectContext *)aMOC
{
    self = [self initWithMOC:aMOC];
    if(self)
    {
        ruleTitle = rule.name;
        triggerInterval = [rule.intervalAmount doubleValue];
        triggerIntervalType = [rule.intervalType integerValue];
        
        self.title = NSLocalizedString(@"Edit Reminder", nil);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:rule.predicate];
        if(predicate)
        {
            [self configureFromPredicate:predicate];
        }
        
        existingRule = rule;
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setup our delete button
    if(existingRule)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 74.0f)];
        UADeleteButton *deleteButton = [[UADeleteButton alloc] initWithFrame:CGRectMake(11, 15, self.tableView.frame.size.width-22.0f, 44.0f)];
        [deleteButton setTitle:NSLocalizedString(@"Delete Reminder", nil) forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(triggerDeleteEvent:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:deleteButton];
        
        self.tableView.tableFooterView = footerView;
    }
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
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
    if(!triggerForAll && (!triggerEventName || triggerEventName.length == 0)) completedRequiredFields = NO;
    
    if(completedRequiredFields)
    {
        NSString *predicateFormat = [NSString stringWithFormat:@"className == '%@'", triggerClassName];
        if(triggerEventName && triggerEventName.length > 0)
        {
            predicateFormat = [predicateFormat stringByAppendingFormat:@" && name ==[cd] '%@'", triggerEventName];
        }
        
        UAReminderRule *newReminderRule = existingRule;
        if(!newReminderRule)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAReminderRule" inManagedObjectContext:self.moc];
            newReminderRule = (UAReminderRule *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.moc];
        }
        newReminderRule.name = ruleTitle;
        newReminderRule.predicate = predicateFormat;
        newReminderRule.intervalType = [NSNumber numberWithInteger:triggerIntervalType];
        newReminderRule.intervalAmount = [NSNumber numberWithDouble:triggerInterval];
        
        NSError *error = nil;
        [self.moc save:&error];
        
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
- (void)triggerDeleteEvent:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Reminder Rule", nil)
                                                        message:NSLocalizedString(@"Are you sure you'd like to delete this reminder rule?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [alertView show];
}

#pragma mark - Logic
- (void)deleteReminderRule
{
    NSError *error = nil;
    [[UAReminderController sharedInstance] deleteReminderRule:existingRule error:&error];
    
    if(!error)
    {
        [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
        [self handleBack:self withSound:NO];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"We were unable to delete your reminder rule for the following reason: %@", [error localizedDescription])
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
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
    }
}
- (void)selectIntervalType:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    if(indexPath)
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if(cell)
        {
            UIView *accessoryView = [(UITextField *)cell.accessoryControl inputAccessoryView];
            for(id control in [(UASuggestionBar *)accessoryView suggestions])
            {
                if([control isKindOfClass:[UAAutocompleteBarButton class]])
                {
                    [(UAAutocompleteBarButton *)control setSelected:NO];
                }
            }
        }
        
        [sender setSelected:YES];
        triggerIntervalType = sender.tag;
    }
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
        
        [autocompleteBar showSuggestionsForInput:nil];
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        triggerForAll = !triggerForAll;
        triggerEventName = nil;
    }
    
    [tableView reloadData];
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
        return 2;
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
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UAReminderCell"];
    }
    [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
    
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
            cell.textLabel.text = NSLocalizedString(@"Meal", nil);
            cell.accessoryType = [triggerClassName isEqualToString:@"UAMeal"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;            
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Trigger for all entries of this type", nil);
            cell.accessoryView = nil;
            cell.accessoryType = triggerForAll ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
            textField.textColor = [UIColor colorWithRed:114.0f/255.0f green:118.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
            textField.font = [UAFont standardDemiBoldFontWithSize:16.0f];
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.tag = 0;
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [autocompleteBar removeFromSuperview];            
            UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
            accessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GenericAccessoryViewBackground.png"]];
            autocompleteBar.frame = CGRectMake(0.0f, 0.0f, accessoryView.frame.size.width, accessoryView.frame.size.height);
            [accessoryView addSubview:autocompleteBar];
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
            textField.textColor = [UIColor colorWithRed:114.0f/255.0f green:118.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
            textField.font = [UAFont standardDemiBoldFontWithSize:16.0f];
            textField.autocorrectionType = UITextAutocorrectionTypeDefault;
            textField.tag = 1;
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
            accessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GenericAccessoryViewBackground.png"]];
            textField.inputAccessoryView = accessoryView;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"After", @"The amount of time to wait after an event occurs before alerting the user");
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            textField.delegate = self;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.text = [NSString stringWithFormat:@"%.0f", triggerInterval];
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.clearButtonMode = UITextFieldViewModeNever;
            textField.adjustsFontSizeToFitWidth = NO;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.textAlignment = NSTextAlignmentRight;
            textField.textColor = [UIColor colorWithRed:114.0f/255.0f green:118.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
            textField.font = [UAFont standardDemiBoldFontWithSize:16.0f];
            textField.tag = 2;
            cell.accessoryView = textField;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
           // UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
           // accessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GenericAccessoryViewBackground.png"]];
            
            UASuggestionBar *suggestionBar = [[UASuggestionBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
            suggestionBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GenericAccessoryViewBackground.png"]];
            
            UAAutocompleteBarButton *minutes = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 70.0f, 29.0f)];
            [minutes setTitle:NSLocalizedString(@"Minutes", nil) forState:UIControlStateNormal];
            [minutes addTarget:self action:@selector(selectIntervalType:) forControlEvents:UIControlEventTouchUpInside];
            [minutes setTag:kMinuteIntervalType];
            
            UAAutocompleteBarButton *hours = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(83.0f, 10.0f, 60.0f, 29.0f)];
            [hours setTitle:NSLocalizedString(@"Hours", nil) forState:UIControlStateNormal];
            [hours addTarget:self action:@selector(selectIntervalType:) forControlEvents:UIControlEventTouchUpInside];
            [hours setTag:kHourIntervalType];
            
            UAAutocompleteBarButton *days = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(146.0f, 10.0f, 50.0f, 29.0f)];
            [days setTitle:NSLocalizedString(@"Days", nil) forState:UIControlStateNormal];
            [days addTarget:self action:@selector(selectIntervalType:) forControlEvents:UIControlEventTouchUpInside];
            [days setTag:kDayIntervalType];
            
            [suggestionBar addSuggestions:@[minutes, hours, days]];
            
            UAAutocompleteBarButton *button = nil;
            if(triggerIntervalType == kMinuteIntervalType)
            {
                button = minutes;
            }
            else if(triggerIntervalType == kHourIntervalType)
            {
                button = hours;
            }
            else if(triggerIntervalType == kDayIntervalType)
            {
                button = days;
            }
            [button setSelected:YES];
            
            textField.inputAccessoryView = suggestionBar;
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];

    if(indexPath.section == 1 && indexPath.row == 1)
    {
        [autocompleteBar showSuggestionsForInput:newValue];
    }
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [autocompleteBar showSuggestionsForInput:nil];
    [autocompleteBar fetchSuggestions];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textField.superview.superview];
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
        ruleTitle = [textField text];
    }
    else if(textField.tag == 2)
    {
        triggerInterval = [[textField text] integerValue];
    }
    
    self.activeControlIndexPath = nil;
}
- (void)keyboardWillBeShown:(NSNotification *)aNotification
{
    [super keyboardWillBeShown:aNotification];
    
    [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)theAutocompleteBar
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
    
    return nil;
}
- (void)didSelectAutocompleteSuggestion:(NSString *)suggestion
{
    [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    UITextField *textField = (UITextField *)cell.accessoryControl;
    textField.text = suggestion;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self deleteReminderRule];
    }
}

@end
