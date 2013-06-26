//
//  UASettingsRunKeeperViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 31/03/2013.
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

#import <Dropbox/Dropbox.h>
#import "UAAppDelegate.h"
#import "UASettingsRunKeeperViewController.h"
#import "MBProgressHUD.h"

@interface UASettingsRunKeeperViewController ()
{
    NXOAuth2Account *externalAccount;
    NSDateFormatter *dateFormatter;
    
    id linkNotificaton;
    id linkFailNotification;
    id syncNotification;
    UILabel *lastSyncLabel;
}
@end

@implementation UASettingsRunKeeperViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"RunKeeper Settings", nil);
        
        externalAccount = nil;
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        __weak typeof(self) weakSelf = self;
        linkNotificaton = [[NSNotificationCenter defaultCenter] addObserverForName:kRunKeeperLinkNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf fetchLinkedAccount];
            [weakSelf.tableView reloadData];
            
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        }];
        linkFailNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRunKeeperLinkFailedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        }];
        syncNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRunKeeperDidSyncNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateSyncInformation];
                
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            });
        }];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchLinkedAccount];
    [self.tableView reloadData];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:linkNotificaton];
    [[NSNotificationCenter defaultCenter] removeObserver:linkFailNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:syncNotification];
}

#pragma mark - Logic
- (void)fetchLinkedAccount
{
    UAAccount *activeAccount = [[UAAccountController sharedInstance] activeAccount];
    externalAccount = [[UASyncController sharedInstance] externalAccountForServiceIdentifier:kRunKeeperServiceIdentifier withAccount:activeAccount];

    [self updateSyncInformation];
}
- (void)updateSyncInformation
{
    UAAccount *activeAccount = [[UAAccountController sharedInstance] activeAccount];

    if(activeAccount && externalAccount)
    {
        lastSyncLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width-20.0f, 0.0f)];
        lastSyncLabel.numberOfLines = 0;
        lastSyncLabel.textAlignment = NSTextAlignmentCenter;
        lastSyncLabel.backgroundColor = [UIColor clearColor];
        lastSyncLabel.font = [UAFont standardDemiBoldFontWithSize:14.0f];
        lastSyncLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        lastSyncLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        lastSyncLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
        
        if(activeAccount.runKeeperAccount.lastSyncTimestamp)
        {
            lastSyncLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Last sync performed on", @"A label showing the date a sync operation was last performed on"), [dateFormatter stringFromDate:activeAccount.runKeeperAccount.lastSyncTimestamp]];
        }
        else
        {
            lastSyncLabel.text = NSLocalizedString(@"You have yet to perform a sync with RunKeeper", nil);
        }
        [lastSyncLabel sizeToFit];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, lastSyncLabel.frame.size.height)];
        lastSyncLabel.frame = CGRectMake(floorf(self.view.frame.size.width/2.0f - lastSyncLabel.frame.size.width/2), 0.0f, lastSyncLabel.frame.size.width, lastSyncLabel.frame.size.height);
        [footerView addSubview:lastSyncLabel];
        
        self.tableView.tableFooterView = footerView;
    }
    else
    {
        self.tableView.tableFooterView = nil;
    }
}
- (void)performManualSync
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[UASyncController sharedInstance] runKeeper] performSyncByForce:YES];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    if(externalAccount)
    {
        return 2;
    }
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(externalAccount)
    {
        if(section == 0)
        {
            return NSLocalizedString(@"Account options", nil);
        }
        else if(section == 1)
        {
            return NSLocalizedString(@"Unlink your account", @"An option to disconnect your third-party account from Diabetik");
        }
    }
    else
    {
        if(section == 0)
        {
            return NSLocalizedString(@"Link your account", @"An option to connect your third-party account from Diabetik");
        }
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
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            if(externalAccount)
            {
                cell.textLabel.text = NSLocalizedString(@"Perform manual sync", nil);
                cell.detailTextLabel.text = nil;
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Link with RunKeeper", nil);
                cell.detailTextLabel.text = nil;
            }
        }
    }
    else if(indexPath.section == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Unlink your RunKeeper account", nil);
        cell.detailTextLabel.text = nil;
    }

    return cell;
}

#pragma mar - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            if(externalAccount)
            {
                [self performManualSync];
            }
            else
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[[UASyncController sharedInstance] runKeeper] connect];
            }
        }
    }
    else if(indexPath.section == 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unlink account", nil)
                                                            message:NSLocalizedString(@"Are you sure you want to unlink your RunKeeper account?", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Yep", nil), nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [[[UASyncController sharedInstance] runKeeper] removeAccount:externalAccount];
        [self fetchLinkedAccount];
        externalAccount = nil;

        [self.tableView reloadData];
    }
}

@end
