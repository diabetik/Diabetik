//
//  UASideMenuViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/12/2012.
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

#import "UAAppDelegate.h"
#import "UAAccountController.h"
#import "UAReminderController.h"
#import "UAMediaController.h"

#import "UACreditsTooltipView.h"
#import "UASideMenuViewController.h"
#import "UASettingsViewController.h"
#import "UARemindersViewController.h"
#import "UAJournalViewController.h"
#import "UATimelineViewController.h"
#import "UAExportViewController.h"
#import "UAInsulinCalculatorViewController.h"

#import "UASideMenuCell.h"
#import "UASideMenuAccountCell.h"
#import "UASideMenuHeaderView.h"

@interface UASideMenuViewController ()
{
    id accountUpdateNotifier;
    id reminderUpdateNotifier;
}
@end

@implementation UASideMenuViewController

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self)
    {
        self.moc = aMOC;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UASideMenuHeaderView *headerView = [[UASideMenuHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 115.0f)];
    
    self.tableView.tableHeaderView = headerView;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Notifications
    accountUpdateNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kAccountsUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];
    }];
    reminderUpdateNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kRemindersUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:accountUpdateNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:reminderUpdateNotifier];
}

#pragma mark - UI
- (void)showCredits
{
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = (UINavigationController *)appDelegate.viewController.contentViewController;
    
    UAModalView *modalView = [[UAModalView alloc] initWithFrame:CGRectMake(0, 0, navigationController.view.frame.size.width, navigationController.view.frame.size.height)];
    modalView.delegate = self;
    [navigationController.view addSubview:modalView];
    UACreditsTooltipView *introductionView = [[UACreditsTooltipView alloc] initWithFrame:CGRectMake(0, 0, modalView.contentView.bounds.size.width, modalView.contentView.bounds.size.height)];
    [[modalView contentView] addSubview:introductionView];
    [modalView present];
}

#pragma mark - UITableViewDataSource methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Accounts", nil);
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"Menu", @"The section header for generic menu items");
    }
    else if(section == 2)
    {
        return NSLocalizedString(@"Reminders", nil);
    }
    
    return @"";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([[[UAReminderController sharedInstance] reminders] count]) return 3;
    
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return [[[UAAccountController sharedInstance] accounts] count];
    }
    else if(section == 1)
    {
        return 5;
    }
    else if(section == 2)
    {
        return [[[UAReminderController sharedInstance] ungroupedReminders] count];
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"UASideMenuCell";
    if(indexPath.section == 0) cellIdentifier = @"UASideMenuAccountCell";
    if(indexPath.section == 2) cellIdentifier = @"UASideMenuReminderCell";
    
    UASideMenuCell *cell = (UASideMenuCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        if(indexPath.section == 0)
        {
            cell = [[UASideMenuAccountCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASideMenuAccountCell"];
        }
        else if(indexPath.section == 2)
        {
            cell = [[UASideMenuCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASideMenuReminderCell"];
        }
        else
        {
            cell = [[UASideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASideMenuCell"];
        }
    }
    
    cell.detailTextLabel.text = nil;
    if(indexPath.section == 0)
    {
        UAAccount *account = [[[UAAccountController sharedInstance] accounts] objectAtIndex:indexPath.row];
        if(account)
        {
            UIImage *avatar = [[UAMediaController sharedInstance] imageWithFilename:account.photoPath];
            if(!avatar)
            {
                avatar = [UIImage imageNamed:@"DefaultAvatar.png"];
            }
            
            cell.textLabel.text = account.name;
            cell.accessoryIcon.image = avatar;
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Journal", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconJournal.png"];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Reminders", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconReminders.png"];
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Export", @"Menu item to take users to the export screen");
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconExport.png"];
        }
        else if(indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"Credits", @"Menu item to show users the application credits");
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconCredits.png"];
        }
        else if(indexPath.row == 4)
        {
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconSettings.png"];
        }
    }
    else if(indexPath.section == 2)
    {
        UAReminder *reminder = [[[UAReminderController sharedInstance] ungroupedReminders] objectAtIndex:indexPath.row];
        if(reminder)
        {
            cell.textLabel.text = reminder.message;
            cell.detailTextLabel.text = [[UAReminderController sharedInstance] detailForReminder:reminder];
            
            switch([reminder.type integerValue])
            {
                case kReminderTypeDate:
                    cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconTimeReminder.png"];
                    break;
                case kReminderTypeRepeating:
                    cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconDateReminder.png"];
                    break;
                case kReminderTypeLocation:
                    cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconLocationReminder.png"];
                    break;
            }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0) return nil;
    
    CGFloat height = [self tableView:aTableView heightForHeaderInSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, height-23.0f, aTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(43.0f, 0.0f, aTableView.frame.size.width, height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    label.text = [[self tableView:aTableView titleForHeaderInSection:section] uppercaseString];
    label.font = [UAFont standardDemiBoldFontWithSize:12.0f];
    
    //[view addSubview:imageView];
    [view addSubview:label];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) return 0.0f;
    
    return 18.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 2)
    {
        return 44.0f;
    }
    
    return 50.0f;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = (UINavigationController *)appDelegate.viewController.contentViewController;
    
    [appDelegate.viewController hideMenuViewController];
    
    if(indexPath.section == 0)
    {
        UAAccount *account = [[[UAAccountController sharedInstance] accounts] objectAtIndex:indexPath.row];
        if(account)
        {
            [[UAAccountController sharedInstance] setActiveAccount:account];
            [aTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [navigationController popToRootViewControllerAnimated:NO];
        }
        else if(indexPath.row == 1)
        {
            if(![[navigationController topViewController] isKindOfClass:[UARemindersViewController class]])
            {
                UARemindersViewController *vc = [[UARemindersViewController alloc] initWithMOC:self.moc];
                [navigationController pushViewController:vc animated:NO];
            }
        }
        else if(indexPath.row == 2)
        {
            if(![[navigationController topViewController] isKindOfClass:[UAExportViewController class]])
            {
                UAExportViewController *vc = [[UAExportViewController alloc] init];
                [navigationController pushViewController:vc animated:NO];
            }
        }
        else if(indexPath.row == 3)
        {
            [self showCredits];
        }
        else if(indexPath.row == 4)
        {
            if(![[navigationController topViewController] isKindOfClass:[UASettingsViewController class]])
            {
                UASettingsViewController *vc = [[UASettingsViewController alloc] initWithMOC:self.moc];
                [navigationController pushViewController:vc animated:NO];
            }
        }
    }
    else if(indexPath.section == 2)
    {
        UAReminder *reminder = [[[UAReminderController sharedInstance] ungroupedReminders] objectAtIndex:indexPath.row];
        if(reminder)
        {
            if([reminder.type integerValue] == kReminderTypeDate || [reminder.type integerValue] == kReminderTypeRepeating)
            {
                UATimeReminderViewController *vc = [[UATimeReminderViewController alloc] initWithReminder:reminder andMOC:self.moc];
                [navigationController pushViewController:vc animated:NO];
            }
            else
            {
                UALocationReminderViewController *vc = [[UALocationReminderViewController alloc] initWithReminder:reminder andMOC:self.moc];
                [navigationController pushViewController:vc animated:NO];
            }
        }
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
}

@end
