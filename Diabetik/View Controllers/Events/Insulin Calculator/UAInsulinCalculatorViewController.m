//
//  UAInsulinCalculatorViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 28/06/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UAInsulinCalculatorViewController.h"
#import "UAAccountController.h"
#import "UAEventController.h"

#import "UAMeal.h"
#import "UAReading.h"

@interface UAInsulinCalculatorViewController ()
{
    NSArray *latestEvents;
    
    NSMutableDictionary *selectedMeals;
    NSNumber *currentGlucose, *targetGlucose;
    NSNumber *correctiveFactor, *carbohydrateRatio;
}

// Logic
- (void)recalculate;

@end

@implementation UAInsulinCalculatorViewController
@synthesize moc = _moc;

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC andAccount:(UAAccount *)anAccount
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _moc = aMOC;
        selectedMeals = [NSMutableDictionary dictionary];
        
        // Set some default values
        targetGlucose = [UAHelper convertBGValue:[NSNumber numberWithDouble:8.3] fromUnit:BGTrackingUnitMMO toUnit:[UAHelper userBGUnit]];
        correctiveFactor = [NSNumber numberWithDouble:100.0];
        carbohydrateRatio = [NSNumber numberWithDouble:20.0];
        
        // Fetch our latest glucose reading to try to pre-determine glucose reading
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account == %@ && filterType == %d && timestamp >= %@", anAccount, ReadingFilterType, [NSDate dateWithHoursBeforeNow:24]];
        if(predicate)
        {
            // Take our latest blood glucose reading
            NSArray *previousGlucoseReadings = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate inContext:_moc];
            if(previousGlucoseReadings)
            {
                UAReading *reading = (UAReading *)[previousGlucoseReadings objectAtIndex:0];
                currentGlucose = [reading value];
            }
        }
        else
        {
            // If we can't find our current glucose reading, default it to 0
            currentGlucose = [NSNumber numberWithDouble:0.0];
        }
        
        // Fetch a list of previous meals and medicine usage over the past 24 hours
        predicate = [NSPredicate predicateWithFormat:@"account == %@ && (filterType == %d || filterType == %d) && timestamp >= %@", anAccount, MealFilterType, MedicineFilterType, [NSDate dateWithHoursBeforeNow:24]];
        if(predicate)
        {
            latestEvents = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate inContext:_moc];
        }
    }
    return self;
}

#pragma mark - Logic
- (void)recalculate
{
    double totalGrams = 0.0;
    for(NSString *uuid in selectedMeals)
    {
        UAMeal *meal = (UAMeal *)[selectedMeals objectForKey:uuid];
        totalGrams += [[meal grams] doubleValue];
    }
    
    NSLog(@"Total grams: %f", totalGrams);
    
    double insulinForCorrection = ([currentGlucose doubleValue] - [targetGlucose doubleValue]) / [correctiveFactor doubleValue];
    double insulinForCarbs = totalGrams/[carbohydrateRatio doubleValue];
    double insulinTotal = insulinForCarbs + insulinForCorrection;
    
    NSLog(@"cor: %f carbs: %f total: %f", insulinForCorrection, insulinForCarbs, insulinTotal);
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1)
    {
        UAEvent *event = [latestEvents objectAtIndex:indexPath.row];
        if([selectedMeals objectForKey:event.uuid])
        {
            [selectedMeals removeObjectForKey:event.uuid];
        }
        else
        {
            [selectedMeals setObject:event forKey:event.uuid];
        }
        
        [aTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

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
    if(section == 0 || section == 2)
    {
        return 2;
    }
    else
    {
        return [latestEvents count];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"General", nil);
    if(section == 1) return NSLocalizedString(@"Carbohydrates", nil);
    if(section == 2) return NSLocalizedString(@"Factors", nil);
    
    return @"";
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingsCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASettingsCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(indexPath.section == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Current blood glucose", nil);
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Target blood glucose", nil);        
        }
    }
    else if(indexPath.section == 1)
    {
        UAEvent *event = [latestEvents objectAtIndex:indexPath.row];
        cell.textLabel.text = event.name;
        
        if([selectedMeals objectForKey:event.uuid])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if(indexPath.section == 2)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Carbohydrate factor", nil);
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Corrective factor", nil);
        }
    }
    
    return cell;
}

@end
