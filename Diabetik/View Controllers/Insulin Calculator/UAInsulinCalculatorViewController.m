//
//  UAInsulinCalculatorViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 28/06/2013.
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

#import "UAEventController.h"
#import "UAMeal.h"
#import "UAReading.h"

#import "UAInsulinCalculatorViewController.h"
#import "UAInputParentViewController.h"

#import "UAInsulinCalculatorTitleView.h"
#import "UAInsulinCalculatorTextFieldViewCell.h"
#import "UAInsulinCalculatorTooltipView.h"

@interface UAInsulinCalculatorViewController ()
{
    NSArray *latestEvents;
    NSNumberFormatter *valueFormatter;
    NSDateFormatter *dateFormatter;
    UIBarButtonItem *rightBarButtonItem;
    NSIndexPath *activeIndexPath;
    UAInsulinCalculatorTitleView *titleView;
    
    UILabel *totalLabel;
    UIToolbar *toolbar;
    
    NSMutableDictionary *selectedMeals;
    NSNumber *totalCarbs;
    NSNumber *currentGlucose, *targetGlucose;
    NSNumber *correctiveFactor, *carbohydrateRatio;
    NSNumber *calculatedInsulin;
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
        calculatedInsulin = nil;

        valueFormatter = [[NSNumberFormatter alloc] init];
        [valueFormatter setMaximumFractionDigits:3];
        [valueFormatter setPaddingCharacter:@"0"];
        [valueFormatter setMinimumIntegerDigits:1];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
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
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconAdd"] style:UIBarButtonItemStyleBordered target:self action:@selector(addEntry:)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:NO];
    
    // Setup our title
    titleView = [[UAInsulinCalculatorTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 44.0f)];
    self.navigationItem.titleView = titleView;
    
    // Setup our footer-based warning label
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width-40.0f, 0.0f)];
    warningLabel.numberOfLines = 0;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.font = [UAFont standardRegularFontWithSize:14.0f];
    warningLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    warningLabel.text = NSLocalizedString(@"Calculations use the following formula:\n\n((currentBG-targetBG)/correctiveFactor) + (carbohydrates/carbohydrateRatio)", nil);
    [warningLabel sizeToFit];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, warningLabel.frame.size.height+20.0f)];
    warningLabel.frame = CGRectMake(floorf(self.view.frame.size.width/2.0f - warningLabel.frame.size.width/2), 0.0f, warningLabel.frame.size.width, warningLabel.frame.size.height);
    footerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [footerView addSubview:warningLabel];
    self.tableView.tableFooterView = footerView;
    
    [self recalculate];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenInsulinCalculatorTooltip])
    {
        [self showTips];
    }
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
    NSNumber *targetBG = [[NSUserDefaults standardUserDefaults] valueForKey:kTargetBGKey];
    NSNumber *storedCarbohydrateRatio = [[NSUserDefaults standardUserDefaults] valueForKey:kCarbohydrateRatioKey];
    NSNumber *storedCorrectiveFactor = [[NSUserDefaults standardUserDefaults] valueForKey:kCorrectiveFactorKey];
    if([UAHelper userBGUnit] == BGTrackingUnitMMO)
    {
        targetGlucose = targetBG ? targetBG : @6.5;
        correctiveFactor = storedCorrectiveFactor ? storedCorrectiveFactor : @10;
    }
    else
    {
        targetGlucose = targetBG ? targetBG : @117;
        correctiveFactor = storedCorrectiveFactor ? storedCorrectiveFactor : @100;
    }
    carbohydrateRatio = storedCarbohydrateRatio ? storedCarbohydrateRatio : @10;
    currentGlucose = nil;
    totalCarbs = nil;
    
    // Fetch our latest glucose reading to try to pre-determine glucose reading
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType == %d && timestamp >= %@", ReadingFilterType, [NSDate dateWithHoursBeforeNow:24]];
    if(predicate)
    {
        // Take our latest blood glucose reading
        NSArray *previousGlucoseReadings = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate
                                                                                        sortDescriptors:nil
                                                                                              inContext:[[UACoreDataController sharedInstance] managedObjectContext]];
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
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        
        latestEvents = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate sortDescriptors:@[sortDescriptor] inContext:[[UACoreDataController sharedInstance] managedObjectContext]];
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
    if([totalCarbs doubleValue] > 0 && insulinTotal >= 0)
    {
        [titleView setSubtitle:[NSString stringWithFormat:@"%@ + %@ = %@", [valueFormatter stringFromNumber:[NSNumber numberWithDouble:insulinForCorrection]], [valueFormatter stringFromNumber:[NSNumber numberWithDouble:insulinForCarbs]], [valueFormatter stringFromNumber:[NSNumber numberWithDouble:insulinTotal]]]];
        
        calculatedInsulin = @(insulinTotal);
        [rightBarButtonItem setEnabled:YES];
    }
    else
    {
        [rightBarButtonItem setEnabled:NO];
        [titleView setSubtitle:nil];
        calculatedInsulin = nil;
    }
}
- (void)showTips
{
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *targetVC = appDelegate.viewController;
    
    UATooltipViewController *modalView = [[UATooltipViewController alloc] initWithParentVC:targetVC andDelegate:self];
    UAInsulinCalculatorTooltipView *tooltipView = [[UAInsulinCalculatorTooltipView alloc] initWithFrame:CGRectZero];
    [modalView setContentView:tooltipView];
    [modalView present];
}


#pragma mark - UI
- (void)addEntry:(id)sender
{
    if(calculatedInsulin)
    {
        UAInputParentViewController *vc = [[UAInputParentViewController alloc] initWithMedicineAmount:calculatedInsulin];
        UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"Please complete all required fields", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row > 1)
    {
        UAEvent *event = [latestEvents objectAtIndex:indexPath.row-2];
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
        
        // Attempt a recalculation
        [self recalculate];
        
        [aTableView reloadRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        UAInsulinCalculatorTextFieldViewCell *cell = (UAInsulinCalculatorTextFieldViewCell *)[aTableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.accessoryControl)
        {
            UITextField *textField = (UITextField *)cell.accessoryControl;
            [textField becomeFirstResponder];
        }
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
    }
    else if(section == 1)
    {
        return 2+[latestEvents count];
    }
    
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"Constants", nil);
    if(section == 1) return NSLocalizedString(@"Input", nil);
    
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Target blood glucose", nil);
            cell.detailTextLabel.text = nil;
            
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:targetGlucose];
            textField.tag = 1;
            textField.delegate = self;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Carbohydrate Ratio", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"1u insulin for every X grams", nil);
            
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:carbohydrateRatio];
            textField.tag = 3;
            textField.delegate = self;
        }
        else if(indexPath.row == 2)
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
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = (UAInsulinCalculatorTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UACalculatorInputCell"];
            if (!cell)
            {
                cell = [[UAInsulinCalculatorTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UACalculatorInputCell"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"Current blood glucose", nil);
            cell.detailTextLabel.text = nil;
            
            UITextField *textField = (UITextField *)cell.accessoryControl;
            textField.text = [valueFormatter stringFromNumber:currentGlucose];
            textField.tag = 0;
            textField.delegate = self;
        }
        else if(indexPath.row == 1)
        {
            cell = (UAInsulinCalculatorTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UACalculatorInputCell"];
            if (!cell)
            {
                cell = [[UAInsulinCalculatorTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UACalculatorInputCell"];
            }
            
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
                cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UACalculatorCell"];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            UAMeal *meal = (UAMeal *)[latestEvents objectAtIndex:indexPath.row-2];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@g)", meal.name, [valueFormatter stringFromNumber:meal.grams]];
            cell.detailTextLabel.text = [dateFormatter stringFromDate:meal.timestamp];
            cell.imageView.image = [UIImage imageNamed:@"TimelineIconMeal"];
            
            if([selectedMeals objectForKey:meal.guid])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.textLabel.alpha = 1;
                cell.detailTextLabel.alpha = 1;
            }
            else
            {
                cell.textLabel.alpha = 0.6;
                cell.detailTextLabel.alpha = 0.6;
            }
        }
    }
    
    return cell;
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
        
        if(targetGlucose)
        {
            [[NSUserDefaults standardUserDefaults] setValue:targetGlucose forKey:kTargetBGKey];
        }
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
        
        if(carbohydrateRatio)
        {
            [[NSUserDefaults standardUserDefaults] setValue:carbohydrateRatio forKey:kCarbohydrateRatioKey];
        }
    }
    else if(textField.tag == 4)
    {
        correctiveFactor = [valueFormatter numberFromString:textField.text];
        
        if(correctiveFactor)
        {
            [[NSUserDefaults standardUserDefaults] setValue:correctiveFactor forKey:kCorrectiveFactorKey];
        }
    }
    
    activeIndexPath = nil;
    [self recalculate];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UATooltipViewControllerDelegate methods
- (void)willDisplayModalView:(UATooltipViewController *)aModalController
{
    // STUB
}
- (void)didDismissModalView:(UATooltipViewController *)aModalController
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenInsulinCalculatorTooltip];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
