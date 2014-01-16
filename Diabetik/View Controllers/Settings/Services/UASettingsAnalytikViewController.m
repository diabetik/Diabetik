//
//  UASettingsAnalytikViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/12/2013.
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

#import "UASettingsAnalytikViewController.h"
#import "UASettingsTextViewCell.h"
#import "UASyncController.h"
#import "MBProgressHUD.h"

@interface UASettingsAnalytikViewController ()
{
    UITextField *usernameTextField, *passwordTextField;
    
    BOOL isLoggedIn;
}

// Logic
- (void)performLogin;

@end

@implementation UASettingsAnalytikViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Analytik", nil);
        
        usernameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        usernameTextField.placeholder = NSLocalizedString(@"Email", nil);
        usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
        usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        usernameTextField.returnKeyType = UIReturnKeyNext;
        usernameTextField.delegate = self;
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
        passwordTextField.secureTextEntry = YES;
        passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordTextField.returnKeyType = UIReturnKeyDone;
        passwordTextField.delegate = self;
        
        isLoggedIn = [[[UASyncController sharedInstance] analytikController] activeAccount] ? YES : NO;
    }
    return self;
}

#pragma mark - Logic
- (void)performLogin
{
    [self.view endEditing:YES];
    
    if(usernameTextField.text.length && passwordTextField.text.length)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        UAAnalytikController *controller = [[UASyncController sharedInstance] analytikController];
        [controller authorizeWithCredentials:@{@"email": usernameTextField.text, @"password": passwordTextField.text} success:^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            isLoggedIn = YES;
            [self.tableView reloadData];
            
            usernameTextField.text = @"";
            passwordTextField.text = @"";
            
            // Force a sync operation
            [[UASyncController sharedInstance] sync];
            
        } failure:^(NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"Please provide valid login credentials", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UI
- (void)toggleStagingServer:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Remove our sync timestamp data
    [defaults removeObjectForKey:kAnalytikLastSyncTimestampKey];
    
    BOOL value = [defaults boolForKey:kAnalytikUseStagingServerKey];
    [defaults setBool:!value forKey:kAnalytikUseStagingServerKey];
    [defaults synchronize];
    
    // Force a sync operation
    [[UASyncController sharedInstance] sync];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:usernameTextField])
    {
        [passwordTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self performLogin];
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UAAnalytikController *controller = [[UASyncController sharedInstance] analytikController];
    if(isLoggedIn)
    {
        if(indexPath.section == 0 && indexPath.row == 1)
        {
            [controller destroyCredentials];
            
            isLoggedIn = NO;
            [aTableView reloadData];
        }
    }
    else
    {
        if(indexPath.section == 1 && indexPath.row == 0)
        {
            [self performLogin];
        }
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    if(isLoggedIn)
    {
        return 1;
    }
    
    return 2;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(isLoggedIn)
    {
        return 2;
    }
    else
    {
        if(section == 0)
        {
            return 2;
        }
    }
    
    return 1;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(isLoggedIn)
    {
        if(section == 0)
        {
            return NSLocalizedString(@"Options", nil);
        }
    }
    else
    {
        if(section == 0)
        {
            return NSLocalizedString(@"Credentials", nil);
        }
    }
    
    return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 40.0f;
    }
    
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    UAGenericTableHeaderView *header = [[UAGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(isLoggedIn)
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
                if (cell == nil)
                {
                    cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASettingCell"];
                }
                cell.textLabel.text = NSLocalizedString(@"Send to staging server", nil);
                
                UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
                [switchControl addTarget:self action:@selector(toggleStagingServer:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = switchControl;
                
                [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kAnalytikUseStagingServerKey]];
            }
            else if(indexPath.row == 1)
            {
                cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
                if (cell == nil)
                {
                    cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASettingCell"];
                }

                cell.textLabel.text = NSLocalizedString(@"Logout", nil);
            }
        }
    }
    else
    {
        if(indexPath.section == 0)
        {
            cell = [aTableView dequeueReusableCellWithIdentifier:@"UALoginCredentialsCell"];
            if (cell == nil)
            {
                cell = [[UASettingsTextViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UALoginCredentialsCell"];
            }
            
            if(indexPath.row == 0)
            {
                cell.accessoryView = usernameTextField;
            }
            else if(indexPath.row == 1)
            {
                cell.accessoryView = passwordTextField;
            }
        }
        else if(indexPath.section == 1)
        {
            cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
            if (cell == nil)
            {
                cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASettingCell"];
            }
            
            cell.textLabel.text = @"Login";
        }
    }
    
    return cell;
}
@end
