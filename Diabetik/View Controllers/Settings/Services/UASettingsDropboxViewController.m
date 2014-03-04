//
//  UASettingsDropboxViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 31/03/2013.
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
#import "UAAppDelegate.h"
#import "UASettingsDropboxViewController.h"

@interface UASettingsDropboxViewController ()
{
    id linkNotifier;
}
@end

@implementation UASettingsDropboxViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Dropbox Settings", nil);
        
        __weak typeof(self) weakSelf = self;
        linkNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kDropboxLinkNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:linkNotifier];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Dropbox", nil);
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
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASettingCell"];
    }
    
    if(indexPath.section == 0)
    {
        if(![[DBAccountManager sharedManager] linkedAccount])
        {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Link with Dropbox", nil);
            }
        }
        else
        {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Unlink Dropbox account", nil);
            }
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        if(!account)
        {
            if(indexPath.row == 0)
            {
                [[DBAccountManager sharedManager] linkFromController:self];
            }
        }
        else
        {
            if(indexPath.row == 0)
            {
                [account unlink];
                [aTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}
@end
