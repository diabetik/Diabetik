//
//  UASideMenuViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/12/2012.
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

#import "UAAppDelegate.h"
#import "UAReminderController.h"
#import "UAMediaController.h"

#import "UASideMenuViewController.h"
#import "UASettingsViewController.h"
#import "UARemindersViewController.h"
#import "UAJournalViewController.h"
#import "UATimelineViewController.h"
#import "UAExportViewController.h"
#import "UAInsulinCalculatorViewController.h"
#import "UATagsViewController.h"

#import "UASideMenuCell.h"

@interface UASideMenuViewController ()
{
    id reminderUpdateNotifier;
}
@end

@implementation UASideMenuViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self)
    {
        // STUB
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 44.0f)];
    self.tableView.opaque = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor clearColor];

    reminderUpdateNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kRemindersUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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
    [[NSNotificationCenter defaultCenter] removeObserver:reminderUpdateNotifier];
}

#pragma mark - UITableViewDataSource methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Menu", @"The section header for generic menu items");
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"Reminders", nil);
    }
    
    return @"";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([[[UAReminderController sharedInstance] reminders] count]) return 2;
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 6;
    }
    else if(section == 1)
    {
        return [[[UAReminderController sharedInstance] ungroupedReminders] count];
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"UASideMenuCell";
    if(indexPath.section == 1) cellIdentifier = @"UASideMenuReminderCell";
    
    UASideMenuCell *cell = (UASideMenuCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        if(indexPath.section == 1)
        {
            cell = [[UASideMenuCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASideMenuReminderCell"];
        }
        else
        {
            cell = [[UASideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASideMenuCell"];
        }
    }
    
    cell.tintColor = nil;
    cell.detailTextLabel.text = nil;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Journal", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconJournal"];
            cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconJournalHighlighted"];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Insulin Calculator", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconCalculator"];
            cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconCalculatorHighlighted"];
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Tags", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconTags"];
            cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconTagsHighlighted"];
        }
        else if(indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"Reminders", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconReminders"];
            cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconRemindersHighlighted"];
        }
        else if(indexPath.row == 4)
        {
            cell.textLabel.text = NSLocalizedString(@"Export", @"Menu item to take users to the export screen");
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconExport"];
            cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconExportHighlighted"];
        }
        else if(indexPath.row == 5)
        {
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconSettings"];
            cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconSettingsHighlighted"];
        }
    }
    else if(indexPath.section == 1)
    {
        UAReminder *reminder = [[[UAReminderController sharedInstance] ungroupedReminders] objectAtIndex:indexPath.row];
        if(reminder)
        {
            cell.textLabel.text = reminder.message;
            cell.detailTextLabel.text = [[UAReminderController sharedInstance] detailForReminder:reminder];
            cell.tintColor = [UIColor colorWithRed:71.0f/255.0f green:179.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
            
            switch([reminder.type integerValue])
            {
                case kReminderTypeDate:
                    cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconTimeReminder"];
                    cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconTimeReminderHighlighted"];
                    break;
                case kReminderTypeRepeating:
                    cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconDateReminder"];
                    cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconDateReminderHighlighted"];
                    break;
                case kReminderTypeLocation:
                    cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconLocationReminder"];
                    cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconLocationReminderHighlighted"];
                    break;
                case kReminderTypeRule:
                    cell.accessoryIcon.image = [UIImage imageNamed:@"ListMenuIconRuleReminder"];
                    cell.accessoryIcon.highlightedImage = [UIImage imageNamed:@"ListMenuIconRuleReminderHighlighted"];
                    break;
                default:
                    cell.accessoryIcon.image = nil;
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
    view.backgroundColor = [UIColor clearColor];
    
    /*
    view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.08f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(43.0f, 0.0f, aTableView.frame.size.width, height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    label.text = [[self tableView:aTableView titleForHeaderInSection:section] uppercaseString];
    label.font = [UAFont standardDemiBoldFontWithSize:12.0f];
    
    //[view addSubview:imageView];
    [view addSubview:label];
     */
    
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
        return 55.0f;
    }
    
    return 50.0f;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = nil;
    BOOL animateViewControllerChange = NO;
    
    navigationController = (UINavigationController *)[(REFrostedViewController *)appDelegate.viewController contentViewController];
    [(REFrostedViewController *)appDelegate.viewController hideMenuViewController];

    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            [navigationController popToRootViewControllerAnimated:animateViewControllerChange];
        }
        else if(indexPath.row == 1)
        {
            if(![[navigationController topViewController] isKindOfClass:[UAInsulinCalculatorViewController class]])
            {
                UAInsulinCalculatorViewController *vc = [[UAInsulinCalculatorViewController alloc] init];
                [navigationController pushViewController:vc animated:animateViewControllerChange];
            }
        }
        else if(indexPath.row == 2)
        {
            if(![[navigationController topViewController] isKindOfClass:[UATagsViewController class]])
            {
                UATagsViewController *vc = [[UATagsViewController alloc] init];
                [navigationController pushViewController:vc animated:animateViewControllerChange];
            }
        }
        else if(indexPath.row == 3)
        {
            if(![[navigationController topViewController] isKindOfClass:[UARemindersViewController class]])
            {
                UARemindersViewController *vc = [[UARemindersViewController alloc] init];
                [navigationController pushViewController:vc animated:animateViewControllerChange];
            }
        }
        else if(indexPath.row == 4)
        {
            if(![[navigationController topViewController] isKindOfClass:[UAExportViewController class]])
            {
                UAExportViewController *vc = [[UAExportViewController alloc] init];
                [navigationController pushViewController:vc animated:animateViewControllerChange];
            }
        }
        else if(indexPath.row == 5)
        {
            if(![[navigationController topViewController] isKindOfClass:[UASettingsViewController class]])
            {
                UASettingsViewController *vc = [[UASettingsViewController alloc] init];
                [navigationController pushViewController:vc animated:animateViewControllerChange];
            }
        }
    }
    else if(indexPath.section == 1)
    {
        UAReminder *reminder = [[[UAReminderController sharedInstance] ungroupedReminders] objectAtIndex:indexPath.row];
        if(reminder)
        {
            if([reminder.type integerValue] == kReminderTypeDate || [reminder.type integerValue] == kReminderTypeRepeating)
            {
                UATimeReminderViewController *vc = [[UATimeReminderViewController alloc] initWithReminder:reminder];
                [navigationController pushViewController:vc animated:animateViewControllerChange];
            }
            else
            {
                UALocationReminderViewController *vc = [[UALocationReminderViewController alloc] initWithReminder:reminder];
                [navigationController pushViewController:vc animated:animateViewControllerChange];
            }
        }
    }
}

@end
