//
//  UASettingsAnalytikViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
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
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
        passwordTextField.secureTextEntry = YES;
        passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordTextField.returnKeyType = UIReturnKeyDone;
        
        isLoggedIn = [[[UASyncController sharedInstance] analytikController] activeAccount] ? YES : NO;
    }
    return self;
}

#pragma mark - Logic
- (void)performLogin
{
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

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UAAnalytikController *controller = [[UASyncController sharedInstance] analytikController];
    if(isLoggedIn)
    {
        if(indexPath.section == 0 && indexPath.row == 0)
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
        return 1;
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
        cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
        if (cell == nil)
        {
            cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASettingCell"];
        }

        cell.textLabel.text = NSLocalizedString(@"Logout", nil);
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
