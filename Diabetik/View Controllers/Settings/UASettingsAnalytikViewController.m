//
//  UASettingsAnalytikViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UASettingsAnalytikViewController.h"
#import "UASettingsTextViewCell.h"

@interface UASettingsAnalytikViewController ()
{
    UITextField *usernameTextField, *passwordTextField;
}

- (void)performLogin:(id)sender;
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
        usernameTextField.textAlignment = NSTextAlignmentCenter;
        usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
        passwordTextField.secureTextEntry = YES;
        passwordTextField.textAlignment = NSTextAlignmentCenter;
        passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordTextField.returnKeyType = UIReturnKeyDone;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(performLogin:)];
}

#pragma mark - Logic
- (void)performLogin:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if(usernameTextField.text.length && passwordTextField.text.length)
    {
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"Please provide valid login credentials", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
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
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Credentials", nil);
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
    UASettingsTextViewCell *cell = (UASettingsTextViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
    if (cell == nil)
    {
        cell = [[UASettingsTextViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASettingCell"];
    }
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell.accessoryView = usernameTextField;
        }
        else if(indexPath.row == 1)
        {
            cell.accessoryView = passwordTextField;
        }
    }
    
    return cell;
}
@end
