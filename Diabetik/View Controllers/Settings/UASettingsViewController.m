//
//  UASettingsViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/12/2012.
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
#import "UAAccountViewController.h"

#import "UASettingsViewController.h"
#import "UASettingsGlucoseViewController.h"
#import "UASettingsDropboxViewController.h"
#import "UASettingsRunKeeperViewController.h"
#import "UASettingsBackupViewController.h"
#import "UASettingsLicensesViewController.h"

#import "UAHelper.h"
#import "UAReading.h"

#define kMedicationReminderAlertTag 1
#define kGeofenceReminderSwitchTag 0
#define kUseSmartInputTag 1

@implementation UASettingsViewController
@synthesize moc = _moc;

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Settings", @"Settings title");
        _moc = aMOC;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.tableView.indexPathForSelectedRow)
    {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsChangedNotification object:nil];
}

#pragma mark - UI
- (void)toggleSmartInput:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kUseSmartInputKey];
}
- (void)toggleSounds:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kUseSoundsKey];
    [[VKRSAppSoundPlayer sharedInstance] setSoundsEnabled:[sender isOn]];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 4;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
    }
    else if(section == 1)
    {
        return [[[UAAccountController sharedInstance] accounts] count]+1;
    }
    else if(section == 3)
    {
        return 1;
    }
    
    return 3;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"General", @"General settings section title");
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"Accounts", nil);
    }
    else if(section == 2)
    {
        return NSLocalizedString(@"Backup & Sync", @"Backup & sync settings section title");
    }
    else if(section == 3)
    {
        return NSLocalizedString(@"Other", @"Settings section for miscellaneous information");
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
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASettingCell"];
    }
    [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
    
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Smart input", @"A settings switch to control the Smart Input feature");
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
            switchControl.tag = kUseSmartInputTag;
            [switchControl addTarget:self action:@selector(toggleSmartInput:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = switchControl;
            
            [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUseSmartInputKey]];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Sounds", @"A settings switch to control application sounds");
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
            switchControl.tag = kUseSmartInputTag;
            [switchControl addTarget:self action:@selector(toggleSounds:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = switchControl;
            
            [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUseSoundsKey]];
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Glucose settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if(indexPath.section == 1)
    {
        cell.accessoryView = nil;
        if(indexPath.row == [self tableView:aTableView numberOfRowsInSection:indexPath.section]-1)
        {
            cell.textLabel.text = NSLocalizedString(@"Add account", nil);
        }
        else
        {
            UAAccount *account = [[[UAAccountController sharedInstance] accounts] objectAtIndex:indexPath.row];
            if(account)
            {
                cell.textLabel.text = account.name;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"diabetik-small-icon.png"];
            cell.textLabel.text = NSLocalizedString(@"Backup settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if(indexPath.row == 1)
        {
            cell.imageView.image = [UIImage imageNamed:@"dropbox-small-icon.png"];
            cell.textLabel.text = NSLocalizedString(@"Dropbox settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 2)
        {
            cell.imageView.image = [UIImage imageNamed:@"runkeeper-small-icon.png"];
            cell.textLabel.text = NSLocalizedString(@"RunKeeper settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Licenses", @"An option to view third-party software licenses used throughout the application");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 2)
        {
            UASettingsGlucoseViewController *vc = [[UASettingsGlucoseViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == [self tableView:aTableView numberOfRowsInSection:indexPath.section]-1)
        {
            UAAccountViewController *vc = [[UAAccountViewController alloc] initWithMOC:self.moc];
            UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nvc animated:YES completion:^{
                // STUB
            }];
        }
        else
        {
            UAAccount *account = [[[UAAccountController sharedInstance] accounts] objectAtIndex:indexPath.row];
            if(account)
            {
                UAAccountViewController *vc = [[UAAccountViewController alloc] initWithAccount:account andMOC:self.moc];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            UASettingsBackupViewController *vc = [[UASettingsBackupViewController alloc] initWithMOC:self.moc];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 1)
        {
            UASettingsDropboxViewController *vc = [[UASettingsDropboxViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 2)
        {
            UASettingsRunKeeperViewController *vc = [[UASettingsRunKeeperViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            UASettingsLicensesViewController *vc = [[UASettingsLicensesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
