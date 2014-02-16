//
//  UASettingsAnalytikViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/12/2013.
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

#import "UASettingsAnalytikViewController.h"
#import "UASettingsTextViewCell.h"
#import "UASyncController.h"
#import "MBProgressHUD.h"

#import "UITextView+Extension.h"

@interface UASettingsAnalytikViewController ()
@property (nonatomic, strong) UITextField *usernameTextField, *passwordTextField;
@property (nonatomic, strong) UIView *headerView, *footerView;
@property (nonatomic, strong) UITextView *headerInfoTextView;
@property (nonatomic, assign) BOOL isLoggedIn;

// Logic
- (void)performLogin;

// UI
- (void)layoutHeaderView;

@end

@implementation UASettingsAnalytikViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"Analytik", nil);
        
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _usernameTextField.font = [UAFont standardRegularFontWithSize:16.0f];
        _usernameTextField.placeholder = NSLocalizedString(@"Email", nil);
        _usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _usernameTextField.returnKeyType = UIReturnKeyNext;
        _usernameTextField.delegate = self;
        
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTextField.font = [UAFont standardRegularFontWithSize:16.0f];
        _passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.delegate = self;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.headerView.backgroundColor = [UIColor clearColor];
    
    self.headerInfoTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.headerInfoTextView.text = NSLocalizedString(@"Analytik is a service that provides free personal diabetes analytics.\n\nFind patterns in your blood sugar, better understand your diabetes and support research.\n\nSignup for an account at http://analytikhq.com", nil);
    self.headerInfoTextView.font = [UAFont standardRegularFontWithSize:16.0f];
    self.headerInfoTextView.backgroundColor = [UIColor clearColor];
    self.headerInfoTextView.editable = NO;
    self.headerInfoTextView.scrollEnabled = NO;
    self.headerInfoTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.headerInfoTextView.contentInset = UIEdgeInsetsMake(0, 11.0f, 0, 11.0f);
    [self.headerView addSubview:self.headerInfoTextView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.footerView)
    {
        // Setup our footer-based warning label
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width-40.0f, 0.0f)];
        footerLabel.numberOfLines = 0;
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        footerLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        footerLabel.text = NSLocalizedString(@"Your data will now sync with Analytik automatically", nil);
        [footerLabel sizeToFit];
        
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, footerLabel.frame.size.height+20.0f)];
        footerLabel.frame = CGRectMake(floorf(self.view.frame.size.width/2.0f - footerLabel.frame.size.width/2), 0.0f, footerLabel.frame.size.width, footerLabel.frame.size.height);
        self.footerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.footerView addSubview:footerLabel];
    }
    
    self.isLoggedIn = [[[UASyncController sharedInstance] analytikController] activeAccount] ? YES : NO;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    [self layoutHeaderView];
}
#pragma mark - Logic
- (void)performLogin
{
    [self.view endEditing:YES];
    
    if(self.usernameTextField.text.length && self.passwordTextField.text.length)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        __weak typeof(self) weakSelf = self;
        
        UAAnalytikController *controller = [[UASyncController sharedInstance] analytikController];
        [controller authorizeWithCredentials:@{@"email": self.usernameTextField.text, @"password": self.passwordTextField.text} success:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            strongSelf.isLoggedIn = YES;
            strongSelf.usernameTextField.text = @"";
            strongSelf.passwordTextField.text = @"";
            
            // Force a sync operation
            [[UASyncController sharedInstance] syncAnalytikWithCompletionHandler:nil];
            
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
    [[UASyncController sharedInstance] syncAnalytikWithCompletionHandler:nil];
}
- (void)layoutHeaderView
{
    UIFont *font = [self.headerInfoTextView font];
    CGFloat width = self.view.bounds.size.width;
    CGRect rect = [self.headerInfoTextView.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:font}
                                                             context:nil];
    
    CGRect frame = self.headerInfoTextView.frame;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = rect.size.height + 40.0f;
    
    self.headerInfoTextView.frame = CGRectMake(0.0f, 10.0f, frame.size.width, frame.size.height);
    self.headerView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
}

#pragma mark - Accessors
- (void)setIsLoggedIn:(BOOL)state
{
    _isLoggedIn = state;
    
    if(self.tableView)
    {
        [self layoutHeaderView];
        
        self.tableView.tableHeaderView = state ? nil : self.headerView;
        self.tableView.tableFooterView = state ? self.footerView : nil;
        [self.tableView reloadData];
        [self.view setNeedsLayout];
    }
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:self.usernameTextField])
    {
        [self.passwordTextField becomeFirstResponder];
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
    if(self.isLoggedIn)
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                // Remove our sync timestamp data
                [defaults removeObjectForKey:kAnalytikLastSyncTimestampKey];
                
                // Force a sync operation
                [[UASyncController sharedInstance] syncAnalytikWithCompletionHandler:nil];
            }
            else if(indexPath.row == 1)
            {
                [controller destroyCredentials];
                
                self.isLoggedIn = NO;
            }
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
    if(self.isLoggedIn)
    {
        return 1;
    }
    
    return 2;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isLoggedIn)
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(self.isLoggedIn)
    {
        cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
        if (cell == nil)
        {
            cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASettingCell"];
        }
        cell.accessoryView = nil;
        
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"Resync entries", nil);
            }
            else if(indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"Logout", nil);
            }
        }
    }
    else
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row < 2)
            {
                cell = [aTableView dequeueReusableCellWithIdentifier:@"UALoginCredentialsCell"];
                if (cell == nil)
                {
                    cell = [[UASettingsTextViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UALoginCredentialsCell"];
                }
                
                if(indexPath.row == 0)
                {
                    cell.accessoryView = self.usernameTextField;
                }
                else if(indexPath.row == 1)
                {
                    cell.accessoryView = self.passwordTextField;
                }
            }
            else
            {
                cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
                if (cell == nil)
                {
                    cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASettingCell"];
                }
                cell.textLabel.text = @"Send to staging server";
                
                UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
                [switchControl addTarget:self action:@selector(toggleStagingServer:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = switchControl;
                
                [switchControl setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kAnalytikUseStagingServerKey]];
            }
        }
        else if(indexPath.section == 1)
        {
            cell = [aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
            if (cell == nil)
            {
                cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UASettingCell"];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Login", nil);
            cell.accessoryView = nil;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    return cell;
}
@end
