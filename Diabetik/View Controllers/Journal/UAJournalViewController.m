//
//  UAJournalViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/12/2012.
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

#import "UAJournalViewController.h"
#import "UATimelineViewController.h"
#import "UAJournalMonthViewCell.h"
#import "UAIntroductionTooltipView.h"
#import "UAAddEntryModalView.h"

#import "UABGInputViewController.h"
#import "UAMealInputViewController.h"
#import "UAMedicineInputViewController.h"
#import "UAActivityInputViewController.h"
#import "UANoteInputViewController.h"
#import "UAInputParentViewController.h"
#import "UAEventInputViewController.h"

#import "UAEvent.h"
#import "UAReading.h"
#import "UAShortcutButton.h"

@interface UAJournalViewController ()
{
    NSDictionary *readings;
    NSDateFormatter *dateFormatter;
    
    id settingsChangeNotifier;
    
    UAShortcutButton *todayButton, *sevenDayButton, *fourteenDayButton;
    
    double todaysMean, sevenDaysMean, fourteenDaysMean;
    double todaysHighest, sevenDaysHighest, fourteenDaysHighest;
    NSInteger todaysCount, sevenDaysCount, fourteenDaysCount;
}
@end

@implementation UAJournalViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        __weak typeof(self) weakSelf = self;
        
        self.title = NSLocalizedString(@"Journal", @"The title for the applications index screen - which is a physical journal");
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM yyyy"];
        
        // Notifications
        settingsChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kSettingsChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf reloadViewData:note];
        }];
        
        // Menu items
        UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconAdd"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(addEvent:)];
        [self.navigationItem setRightBarButtonItem:addBarButtonItem animated:NO];
    
        UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconListMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(showSideMenu:)];
        [self.navigationItem setLeftBarButtonItem:menuBarButtonItem animated:NO];
        
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:settingsChangeNotifier];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UAJournalMonthViewCell class] forCellReuseIdentifier:@"UAJournalMonthViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UAJournalSpacerViewCell"];
    
    // Setup our table header view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 120.0f)];
    headerView.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    todayButton = [[UAShortcutButton alloc] initWithFrame:CGRectZero];
    [todayButton setTitle:[NSLocalizedString(@"Today", nil) uppercaseString] forState:UIControlStateNormal];
    [todayButton setImage:[UIImage imageNamed:@"JournalShortcutToday"] forState:UIControlStateNormal];
    [todayButton setImage:[UIImage imageNamed:@"JournalShortcutTodaySelected"] forState:UIControlStateHighlighted];
    [todayButton setImage:[UIImage imageNamed:@"JournalShortcutTodaySelected"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [todayButton setTag:0];
    [todayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:todayButton];
    
    sevenDayButton = [[UAShortcutButton alloc] initWithFrame:CGRectZero];
    [sevenDayButton setTitle:[NSLocalizedString(@"Past 7 Days", nil) uppercaseString] forState:UIControlStateNormal];
    [sevenDayButton setImage:[UIImage imageNamed:@"JournalShortcut7Days"] forState:UIControlStateNormal];
    [sevenDayButton setImage:[UIImage imageNamed:@"JournalShortcut7DaysSelected"] forState:UIControlStateHighlighted];
    [sevenDayButton setImage:[UIImage imageNamed:@"JournalShortcut7DaysSelected"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [sevenDayButton setTag:7];
    [sevenDayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:sevenDayButton];
    
    fourteenDayButton = [[UAShortcutButton alloc] initWithFrame:CGRectZero];
    [fourteenDayButton setTitle:[NSLocalizedString(@"Past 14 days", nil) uppercaseString] forState:UIControlStateNormal];
    [fourteenDayButton setImage:[UIImage imageNamed:@"JournalShortcut14Days"] forState:UIControlStateNormal];
    [fourteenDayButton setImage:[UIImage imageNamed:@"JournalShortcut14DaysSelected"] forState:UIControlStateHighlighted];
    [fourteenDayButton setImage:[UIImage imageNamed:@"JournalShortcut14DaysSelected"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
    [fourteenDayButton setTag:14];
    [fourteenDayButton addTarget:self action:@selector(showRelativeTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:fourteenDayButton];
    
    self.tableView.tableHeaderView = headerView;

    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenStarterTooltip])
    {
        [self showTips];
    }
    
    [self reloadViewData:nil];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat buttonWidth = floorf(self.view.frame.size.width/3.0f);
    todayButton.frame = CGRectMake(0.0f, 0.0f, buttonWidth, 119.0f);
    sevenDayButton.frame = CGRectMake(buttonWidth, 0.0f, buttonWidth, 119.0f);
    fourteenDayButton.frame = CGRectMake(buttonWidth*2.0f, 0.0f, buttonWidth, 119.0f);
}

#pragma mark - Logic
- (OrderedDictionary *)fetchReadingData
{
    OrderedDictionary *data = [OrderedDictionary dictionary];
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    NSArray *objects = @[];
    NSError *error = nil;
    if(moc)
    {
        // Save any changes the MOC has waiting in the wings
        if([moc hasChanges])
        {
            NSError *error = nil;
            [moc save:&error];
        }
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAEvent" inManagedObjectContext:moc];
        [request setEntity:entity];
        [request setSortDescriptors:@[sortDescriptor]];
        [request setReturnsObjectsAsFaults:NO];
        
        objects = [moc executeFetchRequest:request error:&error];
    }
    
    // Force objects to be empty if we run into errors
    if(error || !objects) objects = @[];
    
    NSString *title = nil;
    NSDate *currentDate = [NSDate date];
    NSInteger month = 6;
    if([objects count])
    {
        month = [[[NSCalendar currentCalendar] components:NSMonthCalendarUnit
                                                 fromDate:(NSDate *)[[objects lastObject] valueForKey:@"timestamp"]
                                                   toDate:[NSDate date]
                                                  options:0] month];
        month++;
    }
    if(month < 6) month = 6;
    
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
    
    return data;
}
- (void)refreshView
{
    [self.tableView reloadData];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}
- (void)reloadViewData:(NSNotification *)note
{
    [super reloadViewData:note];

    readings = [self fetchReadingData];
    [self refreshView];
}

#pragma mark - UI
- (void)addEvent:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        UAAddEntryModalView *modalView = [[UAAddEntryModalView alloc] initWithFrame:self.navigationController.view.bounds];
        modalView.delegate = self;
        [self.navigationController.view addSubview:modalView];
        [modalView present];
    }
    else
    {
        UAAppDelegate *delegate = (UAAppDelegate*)[[UIApplication sharedApplication] delegate];
        UAAddEntryiPadView *modalView = [UAAddEntryiPadView presentInView:delegate.viewController.view];
        modalView.delegate = self;
    }
}
- (void)showSideMenu:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAAppDelegate *delegate = (UAAppDelegate*)[[UIApplication sharedApplication] delegate];
    [(REFrostedViewController *)delegate.viewController presentMenuViewController];
}
- (void)showRelativeTimeline:(UAShortcutButton *)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap"];
    
    UATimelineViewController *vc = [[UATimelineViewController alloc] initWithRelativeDays:sender.tag];
    vc.title = [sender titleForState:UIControlStateNormal];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)showTips
{
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *targetVC = appDelegate.viewController;
    
    UATooltipViewController *modalView = [[UATooltipViewController alloc] initWithParentVC:targetVC andDelegate:self];
    UAIntroductionTooltipView *tooltipView = [[UAIntroductionTooltipView alloc] initWithFrame:CGRectZero];
    [modalView setContentView:tooltipView];
    [modalView present];
}

#pragma mark - UITableViewDelegate functions
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row%2 == 0)
    {
        [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
        
        indexPath = [NSIndexPath indexPathForRow:indexPath.row/2 inSection:indexPath.section];
        NSString *key = [[readings allKeys] objectAtIndex:indexPath.row];
        if(key)
        {
            NSDictionary *data = [readings objectForKey:key];
            
            UATimelineViewController *vc = [[UATimelineViewController alloc] initWithDateFrom:[data valueForKey:@"min_date"] to:[data valueForKey:@"max_date"]];
            
            vc.title = key;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row%2 == 0)
    {
        return 270.0f;
    }
    
    return 20.0f;
}

#pragma mark - UITableViewDataSource functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(readings)
    {
        return [[readings allKeys] count]*2;
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumberFormatter *valueFormatter = [UAHelper standardNumberFormatter];
    NSNumberFormatter *glucoseFormatter = [UAHelper glucoseNumberFormatter];
    
    if(indexPath.row%2 == 0)
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row/2 inSection:indexPath.section];
        
        UAJournalMonthViewCell *cell = (UAJournalMonthViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAJournalMonthViewCell" forIndexPath:indexPath];
  
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
            [cell setAverageGlucoseValue:[NSNumber numberWithDouble:readingsAvg] withFormatter:glucoseFormatter];
            [cell setDeviationValue:[NSNumber numberWithDouble:readingsDeviation] withFormatter:glucoseFormatter];
        }
        else
        {
            [cell setAverageGlucoseValue:[NSNumber numberWithDouble:0.0] withFormatter:glucoseFormatter];
            [cell setDeviationValue:[NSNumber numberWithDouble:0.0] withFormatter:glucoseFormatter];
        }
        [cell setMealValue:[NSNumber numberWithDouble:totalGrams] withFormatter:valueFormatter];
        [cell setActivityValue:totalMinutes];
        [cell setLowGlucoseValue:[NSNumber numberWithDouble:lowGlucose] withFormatter:glucoseFormatter];
        [cell setHighGlucoseValue:[NSNumber numberWithDouble:highGlucose] withFormatter:glucoseFormatter];
        cell.monthLabel.text = key;
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAJournalSpacerViewCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UATooltipViewControllerDelegate methods
- (void)willDisplayModalView:(UATooltipViewController *)aModalController
{
}
- (void)didDismissModalView:(UATooltipViewController *)aModalController
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenStarterTooltip];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UAAddEntryModalDelegate methods
- (void)addEntryModal:(id)modalView didSelectEntryOption:(NSInteger)buttonIndex
{
    [modalView dismiss];
    
    if(buttonIndex < 5)
    {
        UAInputParentViewController *vc = [[UAInputParentViewController alloc] initWithEventType:buttonIndex];
        if(vc)
        {
            UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:nil];
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
