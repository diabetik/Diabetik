//
//  UASettingsBackupViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 23/05/2013.
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

#import <Dropbox/Dropbox.h>
#import "UASettingsBackupViewController.h"
#import "UABackupController.h"
#import "MBProgressHUD.h"

@interface UASettingsBackupViewController ()
{
    UABackupController *backupController;
    id dropboxLinkNotifier;
}

// UI
- (void)toggleAutomaticBackup:(id)sender;

@end

@implementation UASettingsBackupViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Backup/Restore", nil);
        
        __weak typeof(self) weakSelf = self;
        backupController = [[UABackupController alloc] init];
        dropboxLinkNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kDropboxLinkNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width-40.0f, 0.0f)];
    warningLabel.numberOfLines = 0;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.font = [UAFont standardRegularFontWithSize:14.0f];
    warningLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    warningLabel.text = NSLocalizedString(@"Restoring from backup will never delete existing data. If identical records are found the existing version will be overwritten. We advise backup restoration only be used when absolutely necessary.", nil);
    [warningLabel sizeToFit];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, warningLabel.frame.size.height+20.0f)];
    warningLabel.frame = CGRectMake(floorf(self.view.frame.size.width/2.0f - warningLabel.frame.size.width/2), 0.0f, warningLabel.frame.size.width, warningLabel.frame.size.height);
    [footerView addSubview:warningLabel];
    
    self.tableView.tableFooterView = footerView;
    [self.tableView reloadData];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:dropboxLinkNotifier];
}

#pragma mark - UI
- (void)toggleAutomaticBackup:(id)sender
{
    BOOL automaticBackupEnabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticBackupEnabledKey];
    [[NSUserDefaults standardUserDefaults] setBool:automaticBackupEnabled forKey:kAutomaticBackupEnabledKey];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)toggleWWANBackup:(id)sender
{
    BOOL wwanBackupEnabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kWWANAutomaticBackupEnabledKey];
    [[NSUserDefaults standardUserDefaults] setBool:wwanBackupEnabled forKey:kWWANAutomaticBackupEnabledKey];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    if(![[DBAccountManager sharedManager] linkedAccount])
    {
        return 1;
    }
    
    return 2;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        if(![[DBAccountManager sharedManager] linkedAccount])
        {
            return 1;
        }
        else
        {
            return 2;
        }
    }
    
    BOOL automaticBackupsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticBackupEnabledKey];
    return automaticBackupsEnabled ? 5 : 1;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Backup", nil);
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"Backup options", nil);
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
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.accessoryView = nil;
    cell.accessoryType = nil;
    cell.tag = 0;
    
    if(indexPath.section == 0)
    {
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        if(!account)
        {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Setup Dropbox backup", nil);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.detailTextLabel.text = nil;
            }
        }
        else
        {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Perform manual backup", nil);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.detailTextLabel.text = nil;
            }
            else if(indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Restore from backup", nil);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.detailTextLabel.text = nil;
            }
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Enable automatic backup", nil);
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
            [switchControl addTarget:self action:@selector(toggleAutomaticBackup:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = switchControl;
            
            [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticBackupEnabledKey]];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Backup over 3G", nil);
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
            [switchControl addTarget:self action:@selector(toggleWWANBackup:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = switchControl;
            
            [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kWWANAutomaticBackupEnabledKey]];
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Backup on close", nil);
            cell.tag = BackupOnClose;
            if([[NSUserDefaults standardUserDefaults] integerForKey:kAutomaticBackupFrequencyKey] == BackupOnClose)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else if(indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"Backup once a day", nil);
            cell.tag = BackupOnceADay;
            if([[NSUserDefaults standardUserDefaults] integerForKey:kAutomaticBackupFrequencyKey] == BackupOnceADay)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else if(indexPath.row == 4)
        {
            cell.textLabel.text = NSLocalizedString(@"Backup once a week", nil);
            cell.tag = BackupOnceAWeek;
            if([[NSUserDefaults standardUserDefaults] integerForKey:kAutomaticBackupFrequencyKey] == BackupOnceAWeek)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    
    return cell;
}

#pragma mar - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(![[DBAccountManager sharedManager] linkedAccount])
    {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
    else
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [backupController backupToDropbox:^(NSError *error) {
        
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    if(error)
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                            message:[NSString stringWithFormat:NSLocalizedString(@"It wasn't possible to export your backup to Dropbox. The following error occurred: %@", nil), [error localizedDescription]]
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    else
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Export successful", nil)
                                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Your backup has been exported successfully", nil)]
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                }];
            }
            else if(indexPath.row == 1)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore from backup", nil)
                                                                    message:NSLocalizedString(@"Are you sure you'd like to restore from a previous backup? This cannot be undone.", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                          otherButtonTitles:NSLocalizedString(@"Restore", nil), nil];
                [alertView show];
            }
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row > 0)
            {
                UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
                if(cell)
                {
                    [[NSUserDefaults standardUserDefaults] setInteger:cell.tag forKey:kAutomaticBackupFrequencyKey];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [backupController restoreFromBackup:^(NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if(!error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore successful", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"Your backup was restored successfully", nil)]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:NSLocalizedString(@"It wasn't possible to restore your backup from Dropbox. The following error occurred: %@", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}
@end
