//
//  UAReminderRepeatViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/03/2013.
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

#import "UAReminderRepeatViewController.h"

@interface UAReminderRepeatViewController ()
{
    int days[8];
}
@end

@implementation UAReminderRepeatViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Repeat", nil);

        days[0] = 1;
    }
    return self;
}
- (id)initWithFlags:(NSInteger)flags
{
    self = [self init];
    if(self)
    {
        days[0] = 0;
        
        if(flags & Everyday) days[0] = 1;
        if(flags & Monday) days[1] = 1;
        if(flags & Tuesday) days[2] = 1;
        if(flags & Wednesday) days[3] = 1;
        if(flags & Thursday) days[4] = 1;
        if(flags & Friday) days[5] = 1;
        if(flags & Saturday) days[6] = 1;
        if(flags & Sunday) days[7] = 1;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(setReminderDays:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
}

#pragma mark - UI
- (void)setReminderDays:(id)sender
{
    NSInteger flags = 0;
    
    // Determine whether we've manually ticked every day
    NSInteger total = 0;
    for(int i = 1; i < 8; i++)
    {
        total += days[i];
    }
    if(total == 7)
    {
        flags |= Everyday;
    }
    else
    {
        if(days[0]) flags |= Everyday;
        if(days[1]) flags |= Monday;
        if(days[2]) flags |= Tuesday;
        if(days[3]) flags |= Wednesday;
        if(days[4]) flags |= Thursday;
        if(days[5]) flags |= Friday;
        if(days[6]) flags |= Saturday;
        if(days[7]) flags |= Sunday;
    }
    
    [self.delegate setReminderDays:flags];
    
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
    [self handleBack:self withSound:NO];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"When you'd like to be reminded", nil);
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
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAReminderCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Day", nil);
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Monday", nil);
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Tuesday", nil);
        }
        else if(indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Wednesday", nil);
        }
        else if(indexPath.row == 4)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Thursday", nil);
        }
        else if(indexPath.row == 5)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Friday", nil);
        }
        else if(indexPath.row == 6)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Saturday", nil);
        }
        else if(indexPath.row == 7)
        {
            cell.textLabel.text = NSLocalizedString(@"Every Sunday", nil);
        }
        
        if(days[indexPath.row])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        int newValue = !days[indexPath.row];
        days[indexPath.row] = newValue;
        
        // Deselect all other days if everyday is selected
        if(newValue && indexPath.row == 0)
        {
            for(int i = 1; i < 8; i++)
            {
                days[i] = 0;
            }
        }
        // Deselect every day if a specific day is selected
        else if(newValue && indexPath.row != 0)
        {
            days[0] = 0;
        }
        
        // If the user hasn't selected a single day we default to every day
        if(!newValue)
        {
            BOOL hasSelectedADay = NO;
            for(int i = 0; i < 8; i++)
            {
                if(days[i])
                {
                    hasSelectedADay = YES;
                    break;
                }
            }
            if(!hasSelectedADay) days[0] = 1;
        }
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
