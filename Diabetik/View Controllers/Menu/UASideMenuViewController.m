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

@interface UASideMenuViewController ()
{
    id accountUpdateNotifier;
    id reminderUpdateNotifier;
    
    UIView *overscrollView;
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
    
    overscrollView = nil;
    self.view.backgroundColor = [UIColor colorWithRed:69.0f/255.0f green:69.0f/255.0f blue:69.0f/255.0f alpha:1.0f];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.0f)];
    self.tableView.tableHeaderView = headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
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
    
    // Overscroll view
    if(!overscrollView)
    {
        CGRect frame = self.tableView.bounds;
        frame.origin.y = -frame.size.height;
        overscrollView = [[UIView alloc] initWithFrame:frame];
        [overscrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        overscrollView.backgroundColor = [UIColor colorWithRed:69.0f/255.0f green:69.0f/255.0f blue:69.0f/255.0f alpha:1.0f];
        [self.tableView addSubview:overscrollView];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:accountUpdateNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:reminderUpdateNotifier];
}

#pragma mark - UI
- (void)showCredits
{
    UIView *parentView = self.sidePanelController.centerPanel.view;
    
    UAModalView *modalView = [[UAModalView alloc] initWithFrame:CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height)];
    modalView.delegate = self;
    [parentView addSubview:modalView];
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
    cell.accessoryIcon.contentMode = UIViewContentModeCenter|UIViewContentModeLeft;
    if (cell == nil)
    {
        if(indexPath.section == 0)
        {
            cell = [[UASideMenuAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASideMenuAccountCell"];
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
    
    cell.rightAccessoryIcon.image = nil;
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
            
            if([[[UAAccountController sharedInstance] activeAccount] isEqual:account])
            {
                cell.rightAccessoryIcon.image = [UIImage imageNamed:@"ListMenuIconActiveAccount.png"];
            }
            else
            {
                cell.rightAccessoryIcon.image = nil;
            }
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
    
    [cell showBottomBorder:!(indexPath.row == [self tableView:aTableView numberOfRowsInSection:indexPath.section]-1)];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:aTableView heightForHeaderInSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, height-23.0f, aTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor colorWithRed:69.0f/255.0f green:69.0f/255.0f blue:69.0f/255.0f alpha:1.0f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, height-27.0f, aTableView.frame.size.width, 23.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = [[self tableView:aTableView titleForHeaderInSection:section] uppercaseString];
    label.font = [UAFont standardDemiBoldFontWithSize:12.0f];
    
    //[view addSubview:imageView];
    [view addSubview:label];
    
    /*
    if(section > 0)
    {
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, view.bounds.size.width, 0.5f)];
        topBorder.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
        topBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [view addSubview:topBorder];
    }
     */
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height-0.5f, view.bounds.size.width, 0.5f)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:bottomBorder];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 44.5f;
    }
    return 32.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 2)
    {
        return 44.0f;
    }
    
    return 66.0f;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
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
        [[self sidePanelController] showCenterPanel:YES];
        
        if(indexPath.row == 0)
        {
            UANavigationController *nvc = (UANavigationController *)[[self sidePanelController] centerPanel];
            [nvc popToRootViewControllerAnimated:NO];
        }
        else if(indexPath.row == 1)
        {
            UANavigationController *nvc = (UANavigationController *)[[self sidePanelController] centerPanel];
            if(![[nvc topViewController] isKindOfClass:[UARemindersViewController class]])
            {
                UARemindersViewController *vc = [[UARemindersViewController alloc] initWithMOC:self.moc];
                [nvc pushViewController:vc animated:NO];
            }
        }
        else if(indexPath.row == 2)
        {
            UANavigationController *nvc = (UANavigationController *)[[self sidePanelController] centerPanel];
            if(![[nvc topViewController] isKindOfClass:[UAExportViewController class]])
            {
                UAExportViewController *vc = [[UAExportViewController alloc] init];
                [nvc pushViewController:vc animated:NO];
            }
        }
        else if(indexPath.row == 3)
        {
            [self showCredits];
        }
        else if(indexPath.row == 4)
        {
            UANavigationController *nvc = (UANavigationController *)[[self sidePanelController] centerPanel];
            if(![[nvc topViewController] isKindOfClass:[UASettingsViewController class]])
            {
                UASettingsViewController *vc = [[UASettingsViewController alloc] initWithMOC:self.moc];
                [nvc pushViewController:vc animated:NO];
            }
        }
    }
    else if(indexPath.section == 2)
    {
        UAReminder *reminder = [[[UAReminderController sharedInstance] ungroupedReminders] objectAtIndex:indexPath.row];
        if(reminder)
        {
            UANavigationController *nvc = (UANavigationController *)[[self sidePanelController] centerPanel];
            if([reminder.type integerValue] == kReminderTypeDate || [reminder.type integerValue] == kReminderTypeRepeating)
            {
                UATimeReminderViewController *vc = [[UATimeReminderViewController alloc] initWithReminder:reminder andMOC:self.moc];
                [nvc pushViewController:vc animated:NO];
            }
            else
            {
                UALocationReminderViewController *vc = [[UALocationReminderViewController alloc] initWithReminder:reminder andMOC:self.moc];
                [nvc pushViewController:vc animated:NO];
            }
            [[self sidePanelController] showCenterPanel:YES];
        }
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
}

@end
