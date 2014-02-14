//
//  UASettingsEntryViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 06/12/2013.
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

#import "UASettingsEntryViewController.h"

@interface UASettingsEntryViewController ()

// UI
- (void)toggleSmartInput:(UISwitch *)sender;
- (void)toggleAutoGeotagging:(UISwitch *)sender;

@end

@implementation UASettingsEntryViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Entry", nil);
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UI
- (void)toggleSmartInput:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kUseSmartInputKey];
}
- (void)toggleAutoGeotagging:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kAutomaticallyGeotagEvents];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASettingCell"];
    }
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"Smart input", @"A settings switch to control the Smart Input feature");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl addTarget:self action:@selector(toggleSmartInput:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
        
        [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kUseSmartInputKey]];
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Auto-geotag events", @"A setting asking whether or not to automatically geotag events");
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl addTarget:self action:@selector(toggleAutoGeotagging:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = switchControl;
        
        [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallyGeotagEvents]];
    }

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
