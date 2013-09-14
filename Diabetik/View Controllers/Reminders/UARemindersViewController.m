//
//  UARemindersViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/03/2013.
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

#import "UARemindersViewController.h"
#import "UARemindersTooltipView.h"
#import "JASidePanelController.h"

@interface UARemindersViewController ()
{
    id reminderUpdateNotifier;
    UAAlertMessageView *noRemindersView;
}
@property (nonatomic, strong) NSArray *reminders;
@property (nonatomic, strong) NSArray *rules;

@end

@implementation UARemindersViewController
@synthesize moc = _moc;
@synthesize reminders = _reminders;
@synthesize rules = _rules;

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Reminders", nil);
        _moc = aMOC;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconAdd.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(addReminder:)];
    [self.navigationItem setRightBarButtonItem:addBarButtonItem animated:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    reminderUpdateNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kRemindersUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.reminders = [[UAReminderController sharedInstance] reminders];
        [weakSelf.tableView reloadData];
    }];
    _rules = [[UAReminderController sharedInstance] fetchAllReminderRules];
    
    if(!noRemindersView)
    {
        // No entry label
        noRemindersView = [[UAAlertMessageView alloc] initWithFrame:CGRectZero
                                                           andTitle:NSLocalizedString(@"No Reminders", nil)
                                                         andMessage:NSLocalizedString(@"You currently don't have any reminders setup. To add one, tap the + icon.", nil)];
        [self.view addSubview:noRemindersView];
    }
    
    _reminders = [[UAReminderController sharedInstance] reminders];
    if((_reminders && [_reminders count]) || (_rules && [_rules count]))
    {
        [noRemindersView setHidden:YES];
    }
    else
    {
        [noRemindersView setHidden:NO];
    }
    
    [self.tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenReminderTooltip])
    {
        [self showTips];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:reminderUpdateNotifier];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    noRemindersView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height-self.topLayoutGuide.length);
}

#pragma mark - UI
- (void)addReminder:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Date reminder", nil), NSLocalizedString(@"Location reminder", nil), NSLocalizedString(@"Rule-based reminder", nil), nil];
    [actionSheet showInView:self.view];
}
- (void)showTips
{
    UAModalView *modalView = [[UAModalView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    modalView.delegate = self;
    [self.navigationController.view addSubview:modalView];
    
    UARemindersTooltipView *tooltipView = [[UARemindersTooltipView alloc] initWithFrame:CGRectMake(0, 0, modalView.contentView.bounds.size.width, modalView.contentView.bounds.size.height)];
    [[modalView contentView] addSubview:tooltipView];
    [modalView present];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    NSInteger sections = 0;
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeRepeating] count]) sections ++;
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeDate] count]) sections ++;
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeLocation] count]) sections ++;
    if(_rules && [_rules count]) sections ++;
    
    return sections;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger adjustedSection = [self adjustedSectionForSection:section];
    if(adjustedSection == kReminderTypeRule)
    {
        if(!_rules) return 0;
        return [_rules count];
    }
    else
    {
        if(!_reminders) return 0;
        return [[_reminders objectAtIndex:adjustedSection] count];
    }
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger adjustedSection = [self adjustedSectionForSection:section];
    if(adjustedSection == kReminderTypeRepeating) return NSLocalizedString(@"Repeating reminders", nil);
    if(adjustedSection == kReminderTypeDate) return NSLocalizedString(@"One-time reminders", nil);
    if(adjustedSection == kReminderTypeLocation) return NSLocalizedString(@"Location-based reminders", nil);
    if(adjustedSection == kReminderTypeRule) return NSLocalizedString(@"Rule-based reminders", nil);
    
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
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAReminderCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UAReminderCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
    
    NSInteger adjustedSection = [self adjustedSectionForSection:indexPath.section];
    if(adjustedSection == kReminderTypeDate)
    {
        UAReminder *reminder = (UAReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        cell.textLabel.text = reminder.message;
        cell.detailTextLabel.text = [[UAReminderController sharedInstance] detailForReminder:reminder];
    }
    else if(adjustedSection == kReminderTypeRepeating)
    {
        UAReminder *reminder = (UAReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        cell.textLabel.text = reminder.message;
        cell.detailTextLabel.text = [[UAReminderController sharedInstance] detailForReminder:reminder];
    }
    else if(adjustedSection == kReminderTypeLocation)
    {
        UAReminder *reminder = (UAReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        cell.textLabel.text = reminder.message;
        cell.detailTextLabel.text = [[UAReminderController sharedInstance] detailForReminder:reminder];
    }
    else if(adjustedSection == kReminderTypeRule)
    {
        UAReminderRule *rule = (UAReminderRule *)[_rules objectAtIndex:indexPath.row];
        cell.textLabel.text = rule.name;
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger adjustedSection = [self adjustedSectionForSection:indexPath.section];
    if(adjustedSection == kReminderTypeRule)
    {
        UAReminderRule *rule = (UAReminderRule *)[_rules objectAtIndex:indexPath.row];
        
        UARuleReminderViewController *vc = [[UARuleReminderViewController alloc] initWithReminderRule:rule andMOC:self.moc];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(adjustedSection == kReminderTypeDate || adjustedSection == kReminderTypeRepeating)
    {
        UAReminder *reminder = (UAReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];
        
        UATimeReminderViewController *vc = [[UATimeReminderViewController alloc] initWithReminder:reminder andMOC:self.moc];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UAReminder *reminder = (UAReminder *)[[_reminders objectAtIndex:adjustedSection] objectAtIndex:indexPath.row];

        UALocationReminderViewController *vc = [[UALocationReminderViewController alloc] initWithReminder:reminder andMOC:self.moc];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        UATimeReminderViewController *vc = [[UATimeReminderViewController alloc] initWithMOC:self.moc];
        UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:^{
            // STUB
        }];
    }
    else if(buttonIndex == 1)
    {
        UALocationReminderViewController *vc = [[UALocationReminderViewController alloc] initWithMOC:self.moc];
        UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:^{
            // STUB
        }];
    }
    else if(buttonIndex == 2)
    {
        UARuleReminderViewController *vc = [[UARuleReminderViewController alloc] initWithMOC:self.moc];
        UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:^{
            // STUB
        }];
    }
}

#pragma mark - UAModalViewDelegate methods
- (void)willDisplayModalView:(UAModalView *)aModal
{
    /*
    // Disable swipe gesture
    JASidePanelController *sidePanel = (JASidePanelController *)[self sidePanelController];
    sidePanel.disablePanGesture = YES;
    */
}
- (void)didDismissModalView:(UAModalView *)aModal
{
    /*
    // Re-enable swipe gesture
    JASidePanelController *sidePanel = (JASidePanelController *)[self sidePanelController];
    sidePanel.disablePanGesture = NO;
    */
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenReminderTooltip];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Helpers
- (NSInteger)adjustedSectionForSection:(NSInteger)section
{
    NSMutableArray *sections = [NSMutableArray array];
    
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeRepeating] count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeRepeating]];
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeLocation] count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeLocation]];
    if(_reminders && [[_reminders objectAtIndex:kReminderTypeDate] count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeDate]];
    if(_rules && [_rules count]) [sections addObject:[NSNumber numberWithInteger:kReminderTypeRule]];
    
    if([sections count])
    {
        return [[sections objectAtIndex:section] integerValue];
    }
    
    return 0;
}
@end
