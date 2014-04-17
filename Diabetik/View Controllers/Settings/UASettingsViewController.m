//
//  UASettingsViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/12/2012.
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

#import <UAAppReviewManager/UAAppReviewManager.h>
#import "UAAppDelegate.h"

#import "UASettingsViewController.h"
#import "UASettingsEntryViewController.h"
#import "UASettingsGlucoseViewController.h"
#import "UASettingsTimelineViewController.h"
#import "UASettingsDropboxViewController.h"
#import "UASettingsAnalytikViewController.h"
#import "UASettingsBackupViewController.h"
#import "UASettingsLicensesViewController.h"

#import "UACreditsTooltipView.h"

#import "UASettingsViewCell.h"
#import "UAHelper.h"
#import "UAReading.h"

@interface UASettingsViewController ()

// UI
- (void)toggleSounds:(UISwitch *)sender;

@end

@implementation UASettingsViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Settings", @"Settings title");
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
- (void)toggleSounds:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kUseSoundsKey];
    [[VKRSAppSoundPlayer sharedInstance] setSoundsEnabled:[sender isOn]];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 4;
    }
    else if(section == 2)
    {
        return 4;
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
        return NSLocalizedString(@"Backup & Sync", @"Backup & sync settings section title");
    }
    else if(section == 2)
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
    UASettingsViewCell *cell = (UASettingsViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
    if (cell == nil)
    {
        cell = [[UASettingsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASettingCell"];
    }
    
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Sounds", @"A settings switch to control application sounds");
            
            UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
            [switchControl addTarget:self action:@selector(toggleSounds:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = switchControl;
            
            [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUseSoundsKey]];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Timeline settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Entry settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"Glucose settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"diabetikSmallIcon"];
            cell.textLabel.text = NSLocalizedString(@"Backup settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 1)
        {
            cell.imageView.image = [UIImage imageNamed:@"dropboxSmallIcon"];
            cell.textLabel.text = NSLocalizedString(@"Dropbox settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 2)
        {
            cell.imageView.image = [UIImage imageNamed:@"analytikSmallIcon"];
            cell.textLabel.text = NSLocalizedString(@"Analytik settings", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Need help? Contact support!", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ 😊", NSLocalizedString(@"Rate Diabetik in the App Store", nil)];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Credits", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == 3)
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
        if(indexPath.row == 1)
        {
            UASettingsTimelineViewController *vc = [[UASettingsTimelineViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        if(indexPath.row == 2)
        {
            UASettingsEntryViewController *vc = [[UASettingsEntryViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 3)
        {
            UASettingsGlucoseViewController *vc = [[UASettingsGlucoseViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 1)
    {
        /*
        if(indexPath.row == 0)
        {
            UASettingsiCloudViewController *vc = [[UASettingsiCloudViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        */
        if(indexPath.row == 0)
        {
            UASettingsBackupViewController *vc = [[UASettingsBackupViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 1)
        {
            UASettingsDropboxViewController *vc = [[UASettingsDropboxViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 2)
        {
            UASettingsAnalytikViewController *vc = [[UASettingsAnalytikViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 2)
    {
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if(indexPath.row == 0)
        {
            if([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
                [mailController setMailComposeDelegate:self];
                [mailController setModalPresentationStyle:UIModalPresentationFormSheet];
                [mailController setSubject:@"Diabetik Support"];
                [mailController setToRecipients:@[@"support@diabetikapp.com"]];
                [mailController setMessageBody:[NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"I need help with Diabetik! Here's the problem:", @"A default message shown to users when contacting support for help")] isHTML:NO];
                if(mailController)
                {
                    [self presentViewController:mailController animated:YES completion:nil];
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:NSLocalizedString(@"This device hasn't been setup to send emails.", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
        else if(indexPath.row == 1)
        {
            [UAAppReviewManager rateApp];
        }
        else if(indexPath.row == 2)
        {
            UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
            UIViewController *targetVC = appDelegate.viewController;
            
            UATooltipViewController *modalView = [[UATooltipViewController alloc] initWithParentVC:targetVC andDelegate:nil];
            UACreditsTooltipView *introductionView = [[UACreditsTooltipView alloc] initWithFrame:CGRectZero];
            [modalView setContentView:introductionView];
            [modalView present];
        }
        else if(indexPath.row == 3)
        {
            UASettingsLicensesViewController *vc = [[UASettingsLicensesViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row >= 1 && indexPath.row <= 3)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - MFMailComposeViewDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Support email sent", nil)
                                                            message:NSLocalizedString(@"We've received your support request and will try to reply as soon as possible", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
