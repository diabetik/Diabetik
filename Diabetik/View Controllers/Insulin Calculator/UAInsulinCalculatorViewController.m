//
//  UAInsulinCalculatorViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 28/06/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
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

#import "UAInsulinCalculatorViewController.h"
#import "UAEventController.h"

#import "UAMeal.h"
#import "UAReading.h"

#import "UAInsulinCalculatorTitleView.h"
#import "UAInsulinCalculatorTextFieldViewCell.h"

@interface UAInsulinCalculatorViewController ()
{
    NSArray *latestEvents;
    NSNumberFormatter *valueFormatter;
    NSIndexPath *activeIndexPath;
    UAInsulinCalculatorTitleView *titleView;
    
    UILabel *totalLabel;
    UIToolbar *toolbar;
    
    NSMutableDictionary *selectedMeals;
    NSNumber *totalCarbs;
    NSNumber *currentGlucose, *targetGlucose;
    NSNumber *correctiveFactor, *carbohydrateRatio;
}

// Logic
- (void)setupView;
- (void)recalculate;

@end

@implementation UAInsulinCalculatorViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        selectedMeals = [NSMutableDictionary dictionary];

        valueFormatter = [[NSNumberFormatter alloc] init];
        [valueFormatter setMaximumFractionDigits:3];
        
        [self setupView];
    }
    return self;
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
    
    titleView = [[UAInsulinCalculatorTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 44.0f)];
    self.navigationItem.titleView = titleView;
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(addReminder:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    toolbar.frame = CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f);
    self.tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - toolbar.frame.size.height);
}

#pragma mark - Logic
- (void)setupView
{
    latestEvents = nil;    
    [selectedMeals removeAllObjects];
    
    // Set some default values
    if([UAHelper userBGUnit] == BGTrackingUnitMMO)
    {
        targetGlucose = @0;
        correctiveFactor = @10;
    }
    else
    {
        targetGlucose = @0;
        correctiveFactor = @100;
    }
    currentGlucose = @0;
    totalCarbs = @0;
    carbohydrateRatio = @10;
    
    // Fetch our latest glucose reading to try to pre-determine glucose reading
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType == %d && timestamp >= %@", ReadingFilterType, [NSDate dateWithHoursBeforeNow:24]];
    if(predicate)
    {
        // Take our latest blood glucose reading
        NSArray *previousGlucoseReadings = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate inContext:[[UACoreDataController sharedInstance] managedObjectContext]];
        if(previousGlucoseReadings)
        {
            UAReading *reading = (UAReading *)[previousGlucoseReadings objectAtIndex:0];
            currentGlucose = [reading value];
        }
    }
    
    // Fetch a list of previous meals over the past 24 hours
    predicate = [NSPredicate predicateWithFormat:@"filterType == %d && timestamp >= %@", MealFilterType, [NSDate dateWithHoursBeforeNow:24]];
    if(predicate)
    {
        latestEvents = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate inContext:[[UACoreDataController sharedInstance] managedObjectContext]];
    }
    
    // Update our UI
    [[self tableView] reloadData];
}
- (void)recalculate
{
    // Determine if the user's selecting existing meals or entering carbs manually
    double newTotalCarbs = 0.0;
    if([[selectedMeals allKeys] count])
    {
        for(NSString *guid in selectedMeals)
        {
            UAMeal *meal = (UAMeal *)[selectedMeals objectForKey:guid];
            newTotalCarbs += [[meal grams] doubleValue];
        }
    }
    else
    {
        newTotalCarbs = [totalCarbs doubleValue];
    }
    
    totalCarbs = [NSNumber numberWithDouble:newTotalCarbs];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    
    double insulinForCorrection = ([currentGlucose doubleValue] - [targetGlucose doubleValue]) / [correctiveFactor doubleValue];
    double insulinForCarbs = [totalCarbs doubleValue]/[carbohydrateRatio doubleValue];
    double insulinTotal = insulinForCarbs + insulinForCorrection;
    
    [titleView setSubtitle:[NSString stringWithFormat:@"%@ + %@ = %@", [valueFormatter stringFromNumber:[NSNumber numberWithDouble:insulinForCorrection]], [valueFormatter stringFromNumber:[NSNumber numberWithDouble:insulinForCarbs]], [valueFormatter stringFromNumber:[NSNumber numberWithDouble:insulinTotal]]]];
    NSLog(@"cor: %f carbs: %f total: %f", insulinForCorrection, insulinForCarbs, insulinTotal);
}

#pragma mark - UI
- (void)showDetails:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"About Insulin Calculation", nil)
                                                        message:NSLocalizedString(@"Calculations use the following formula:\n\n((currentBG-targetBG)/correctiveFactor) + (carbohydrates/carbohydrateRatio)\n\nIf in doubt, consult your doctor", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if(indexPath.section == 2 && indexPath.row > 0)
    {
        UAEvent *event = [latestEvents objectAtIndex:indexPath.row-1];
        if([selectedMeals objectForKey:event.guid])
        {
            [selectedMeals removeObjectForKey:event.guid];
        }
        else
        {
            [selectedMeals setObject:event forKey:event.guid];
        }
        
        // If we just unticked our last meal, go ahead and reset our total carbs value to 0
        if(![[selectedMeals allKeys] count])
        {
            totalCarbs = [NSNumber numberWithDouble:0.0];
        }
        
        [aTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];

        // Attempt a recalculation
        [self recalculate];
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
    }
    else if(section == 1)
    {
        return 2;
    }
    else if(section == 2)
    {
        return 1+[latestEvents count];
    }
    
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"Blood glucose", nil);
    if(section == 1) return NSLocalizedString(@"Factors", nil);
    if(section == 2) return NSLocalizedString(@"Carbohydrates", nil);
    
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
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = nil;
    
    if(indexPath.section == 0)
    {
        cell = (UAInsulinCalculatorTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UACalculatorInputCell"];
        if (!cell)
        {
            cell = [[UAInsulinCalculatorTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UACalculatorInputCell"];
        }
        [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Current blood glucose", nil);
            
            NSLog(@"%@ %@", currentGlucose, [valueFormatter stringFromNumber:currentGlucose]);
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:currentGlucose];
            textField.tag = 0;
            textField.delegate = self;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Target blood glucose", nil);
            
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:targetGlucose];
            textField.tag = 1;
            textField.delegate = self;
        }
    }
    else if(indexPath.section == 1)
    {
        cell = (UAInsulinCalculatorTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UACalculatorInputCell"];
        if (!cell)
        {
            cell = [[UAInsulinCalculatorTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UACalculatorInputCell"];
        }
        [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Carbohydrate Ratio", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"1u insulin for every X grams", nil);
            
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:carbohydrateRatio];
            textField.tag = 3;
            textField.delegate = self;
        }
        else if(indexPath.row == 1)
        {
            NSString *unit = ([UAHelper userBGUnit] == BGTrackingUnitMG) ? @"mg/dL" : @"mmoI/L";
            
            cell.textLabel.text = NSLocalizedString(@"Correction Factor", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"1u insulin for every X %@", nil), unit];
            
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:correctiveFactor];
            textField.tag = 4;
            textField.delegate = self;
        }
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell = (UAInsulinCalculatorTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UACalculatorInputCell"];
            if (!cell)
            {
                cell = [[UAInsulinCalculatorTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UACalculatorInputCell"];
            }
            [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"Total carbohydrates", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Enter or select below", nil);
            
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:totalCarbs];
            textField.tag = 2;
            textField.delegate = self;
        }
        else
        {
            cell = [aTableView dequeueReusableCellWithIdentifier:@"UACalculatorCell"];
            if (!cell)
            {
                cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UACalculatorCell"];
            }
            [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            UAEvent *event = [latestEvents objectAtIndex:indexPath.row-1];
            if([event isKindOfClass:[UAMeal class]])
            {
                UAMeal *meal = (UAMeal *)event;
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@g)", meal.name, [valueFormatter stringFromNumber:meal.grams]];
            }
            else
            {
                cell.textLabel.text = event.name;
            }
            
            if([selectedMeals objectForKey:event.guid])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.textLabel.alpha = 1;
            }
            else
            {
                cell.textLabel.alpha = 0.4;
            }
        }
    }
    
    return cell;
}

- (void)keyboardWillBeShown:(NSNotification *)aNotification
{
    [super keyboardWillBeShown:aNotification];
    
    [self.tableView scrollToRowAtIndexPath:activeIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Add a tappable overlay view
    UIView *dismissableView = [self dismissableView];
    if([dismissableView superview]) [dismissableView removeFromSuperview];
    
    [self.view addSubview:dismissableView];
    
    id cell = textField.superview.superview;
    if([cell isKindOfClass:[UITableViewCell class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)cell];
        if(indexPath)
        {
            activeIndexPath = indexPath;
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Remove our tappable overlay view
    UIView *dismissableView = [self dismissableView];
    if([dismissableView superview]) [dismissableView removeFromSuperview];
    
    if(textField.tag == 0)
    {
        currentGlucose = [valueFormatter numberFromString:textField.text];
    }
    else if(textField.tag == 1)
    {
        targetGlucose = [valueFormatter numberFromString:textField.text];
    }
    else if(textField.tag == 2)
    {
        totalCarbs = [valueFormatter numberFromString:textField.text];
        
        [selectedMeals removeAllObjects];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if(textField.tag == 3)
    {
        carbohydrateRatio = [valueFormatter numberFromString:textField.text];
    }
    else if(textField.tag == 4)
    {
        correctiveFactor = [valueFormatter numberFromString:textField.text];
    }
    
    activeIndexPath = nil;
    [self recalculate];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
