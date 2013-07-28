//
//  UAJournalViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/12/2012.
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

#import "UAJournalViewController.h"
#import "UATimelineViewController.h"
#import "UAJournalMonthViewCell.h"
#import "UAJournalShortcutViewCell.h"
#import "UAIntroductionTooltipView.h"
#import "UAAddEntryModalView.h"

#import "UABGInputViewController.h"
#import "UAMealInputViewController.h"
#import "UAMedicineInputViewController.h"
#import "UAActivityInputViewController.h"
#import "UANoteInputViewController.h"
#import "UAInputParentViewController.h"

#import "UAEvent.h"
#import "UAReading.h"

@interface UAJournalViewController ()
{
    NSDictionary *readings;
    NSDateFormatter *dateFormatter;
    NSNumberFormatter *valueFormatter;
    
    id settingsChangeNotifier;
    id coredataChangeNotifier;
    
    BOOL needsDataRefresh;
    double todaysMean, sevenDaysMean, fourteenDaysMean;
    double todaysHighest, sevenDaysHighest, fourteenDaysHighest;
    NSInteger todaysCount, sevenDaysCount, fourteenDaysCount;
}
@property (strong, nonatomic) NSManagedObjectContext *moc;

@end

@implementation UAJournalViewController
@synthesize moc = _moc;

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        __weak typeof(self) weakSelf = self;
        
        self.title = NSLocalizedString(@"Journal", @"The title for the applications index screen - which is a physical journal");
        _moc = aMOC;
        needsDataRefresh = YES;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM yyyy"];
        valueFormatter = [[NSNumberFormatter alloc] init];
        [valueFormatter setMaximumFractionDigits:3];
        
        // Notifications
        coredataChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            needsDataRefresh = YES;
        }];
        settingsChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kSignificantSettingsChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            needsDataRefresh = YES;
            [weakSelf refreshView];
        }];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:settingsChangeNotifier];    
    [[NSNotificationCenter defaultCenter] removeObserver:accountSwitchNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:coredataChangeNotifier];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:titleView.frame];
    imageView.image = [UIImage imageNamed:@"IndexNavBarLogo.png"];
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [self refreshView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconAdd.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(addEvent:)];
    [self.navigationItem setRightBarButtonItem:addBarButtonItem animated:NO];
    
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconListMenu.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSideMenu:)];
    [self.navigationItem setLeftBarButtonItem:menuBarButtonItem animated:NO];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenStarterTooltip])
    {
        [self showTips];
    }
}

#pragma mark - Logic
- (OrderedDictionary *)fetchReadingData
{
    // Save any changes the MOC has waiting in the wings
    if([self.moc hasChanges])
    {
        NSError *error = nil;
        [self.moc save:&error];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAEvent" inManagedObjectContext:self.moc];
    [request setEntity:entity];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setReturnsObjectsAsFaults:NO];
    [request setPredicate:[NSPredicate predicateWithFormat:@"account = %@", [[UAAccountController sharedInstance] activeAccount]]];
    
    OrderedDictionary *data = [OrderedDictionary dictionary];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [self.moc executeFetchRequest:request error:&error];
    if(!error && objects)
    {
        NSString *title = nil;
        NSDate *currentDate = [NSDate date];
        
        NSInteger month = 6;
        if([objects count])
        {
            month = [[[NSCalendar currentCalendar] components:NSMonthCalendarUnit
                                                     fromDate:(NSDate *)[[objects lastObject] valueForKey:@"timestamp"]
                                                       toDate:[NSDate date]
                                                      options:0] month];
        }
        if(month < 6) month = 6;
        
        // Past 6 months
        for(NSInteger i = 0; i <= month; i++)
        {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:1];
            [comps setMonth:[currentDate month]-i];
            [comps setHour:0];
            [comps setMinute:0];
            [comps setSecond:0];
            [comps setYear:[currentDate year]];
            
            NSDate *fromDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
            NSDate *toDate = [fromDate dateAtEndOfMonth];
            
            if(fromDate && toDate)
            {
                NSDictionary *stats = [[UAEventController sharedInstance] statisticsForEvents:objects fromDate:fromDate toDate:toDate];
                
                title = [dateFormatter stringFromDate:fromDate];
                [data setObject:stats forKey:title];
            }
        }
    }
    
    return data;
}
- (void)refreshView
{
    if(isVisible)
    {
        if(needsDataRefresh)
        {
            readings = [self fetchReadingData];
            needsDataRefresh = NO;
        }
    
        [self.tableView reloadData];
    }
}
- (void)didSwitchUserAccount
{
    [super didSwitchUserAccount];
    
    needsDataRefresh = YES;
    [self refreshView];
}

#pragma mark - UI
- (void)addEvent:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAAddEntryModalView *modalView = [[UAAddEntryModalView alloc] initWithFrame:self.navigationController.view.bounds];
    modalView.delegate = self;
    [self.navigationController.view addSubview:modalView];
    [modalView present];
}
- (void)showSideMenu:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAAppDelegate *delegate = (UAAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.viewController showLeftPanel:YES];
}
- (void)showTips
{
    UAModalView *modalView = [[UAModalView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    modalView.delegate = self;
    [self.navigationController.view addSubview:modalView];
    
    UAIntroductionTooltipView *introductionView = [[UAIntroductionTooltipView alloc] initWithFrame:CGRectMake(0, 0, modalView.contentView.bounds.size.width, modalView.contentView.bounds.size.height)];
    [[modalView contentView] addSubview:introductionView];
    [modalView present];
}

#pragma mark - UITableViewDelegate functions
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UATimelineViewController *vc = nil;
    if(indexPath.section == 0)
    {
        NSInteger days = 0;
        NSString *title = NSLocalizedString(@"Today", nil);
        if(indexPath.row == 1)
        {
            days = 7;
            title = NSLocalizedString(@"Past 7 days", nil);
        }
        else if(indexPath.row == 2)
        {
            days = 14;
            title = NSLocalizedString(@"Past 14 days", nil);
        }
        vc = [[UATimelineViewController alloc] initWithMOC:self.moc relativeDays:days];
        vc.title = title;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        NSString *key = [[readings allKeys] objectAtIndex:indexPath.row];
        if(key)
        {
            NSDictionary *data = [readings objectForKey:key];
            
            UATimelineViewController *vc = [[UATimelineViewController alloc] initWithMOC:self.moc withDateFrom:[data valueForKey:@"min_date"] to:[data valueForKey:@"max_date"]];
            
            vc.title = key;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 1)
        {
            return 41.0f;
        }
        else
        {
            return 42.0f;
        }
    }
    else
    {
        if(indexPath.row == [[readings allKeys] count]-1)
        {
            return 196.0f;
        }
        else
        {
            return 205.0f;
        }
    }
}
- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - UITableViewDataSource functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
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
        if(readings)
        {
            return [[readings allKeys] count];
        }
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        UAJournalShortcutViewCell *cell = (UAJournalShortcutViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAJournalShortcutViewCell"];
        if (cell == nil)
        {
            cell = [[UAJournalShortcutViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAJournalShortcutViewCell"];
        }
        [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Today", nil);
            cell.imageView.image = [UIImage imageNamed:@"JournalIconToday.png"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"JournalIconTodayPressed.png"];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Past 7 days", nil);
            cell.imageView.image = [UIImage imageNamed:@"JournalIconOneWeek.png"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"JournalIconOneWeekPressed.png"];
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Past 14 days", nil);
            cell.imageView.image = [UIImage imageNamed:@"JournalIconTwoWeeks.png"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"JournalIconTwoWeeksPressed.png"];
        }
        
        return cell;
    }
    else
    {
        UAJournalMonthViewCell *cell = (UAJournalMonthViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAJournalMonthViewCell"];
        if (cell == nil)
        {
            cell = [[UAJournalMonthViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAJournalMonthViewCell"];
        }
        
        NSString *key = [[readings allKeys] objectAtIndex:indexPath.row];
        NSDictionary *stats = [readings objectForKey:key];
       
        NSInteger totalGrams = [[stats valueForKey:@"total_grams"] integerValue];
        NSInteger totalReadings = [[stats valueForKey:@"total_readings"] integerValue];
        NSInteger totalMinutes = [[stats objectForKey:@"total_minutes"] integerValue];
        double readingsAvg = [[stats valueForKey:@"readings_avg"] doubleValue];
        double readingsDeviation = [[stats valueForKey:@"readings_deviation"] doubleValue];
        double lowGlucose = [[stats valueForKey:@"lowest_reading"] doubleValue];
        double highGlucose = [[stats valueForKey:@"highest_reading"] doubleValue];
        
        if(totalReadings)
        {
            [cell setAverageGlucoseValue:[NSNumber numberWithDouble:readingsAvg] withFormatter:valueFormatter];
            [cell setDeviationValue:[NSNumber numberWithDouble:readingsDeviation] withFormatter:valueFormatter];
        }
        else
        {
            [cell setAverageGlucoseValue:[NSNumber numberWithDouble:0.0] withFormatter:valueFormatter];
            [cell setDeviationValue:[NSNumber numberWithDouble:0.0] withFormatter:valueFormatter];
        }
        [cell setMealValue:[NSNumber numberWithDouble:totalGrams] withFormatter:valueFormatter];
        [cell setActivityValue:totalMinutes];
        [cell setLowGlucoseValue:[NSNumber numberWithDouble:lowGlucose] withFormatter:valueFormatter];
        [cell setHighGlucoseValue:[NSNumber numberWithDouble:highGlucose] withFormatter:valueFormatter];
        cell.monthLabel.text = key;
        
        return cell;
    }
}

#pragma mark - UAModalViewDelegate methods
- (void)willDisplayModalView:(UAModalView *)aModal
{
    // Disable swipe gesture
    JASidePanelController *sidePanel = (JASidePanelController *)[self sidePanelController];
    sidePanel.disablePanGesture = YES;
}
- (void)didDismissModalView:(UAModalView *)aModal
{
    // Re-enable swipe gesture
    JASidePanelController *sidePanel = (JASidePanelController *)[self sidePanelController];
    sidePanel.disablePanGesture = NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenStarterTooltip];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UAAddEntryModalDelegate methods
- (void)addEntryModal:(UAAddEntryModalView *)modalView didSelectEntryOption:(NSInteger)buttonIndex
{
    [modalView dismiss];
    
    if(buttonIndex < 5)
    {
        UAInputParentViewController *vc = [[UAInputParentViewController alloc] initWithMOC:self.moc andEventType:buttonIndex];
        if(vc)
        {
            UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:^{
                
            }];
        }
    }
}

#pragma mark - Helpers
- (NSString *)keyForIndexPath:(NSIndexPath *)aIndexPath
{
    NSInteger i = 0;
    for(NSString *key in readings)
    {
        if(i == aIndexPath.row) return key;
        i++;
    }
    
    return nil;
}

@end
