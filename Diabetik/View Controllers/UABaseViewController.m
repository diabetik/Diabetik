//
//  UABaseViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 11/12/2012.
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

#import "UABaseViewController.h"
#import "UAKeyboardController.h"

@interface UABaseViewController ()
@end

@implementation UABaseViewController
@synthesize moc = _moc;

#pragma mark - Setup
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isVisible = NO;
        isFirstLoad = YES;
        
        __weak typeof(self) weakSelf = self;
        accountSwitchNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kAccountsSwitchedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf didSwitchUserAccount];
        }];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:accountSwitchNotifier];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TimelineBackground.png"]];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isVisible = YES;
    
    if(!self.navigationItem.leftBarButtonItem && [self.navigationController.viewControllers count] > 1)
    {
        UIImage *backButtonBG = [[UIImage imageNamed:@"NavBarBtnBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 3)];
        UIImage *backButtonHighlightedBG = [[UIImage imageNamed:@"NavBarBtnBackPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 3)];
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
        [backButton setBackgroundImage:backButtonBG forState:UIControlStateNormal];
        [backButton setBackgroundImage:backButtonHighlightedBG forState:UIControlStateHighlighted];
        [backButton setImage:[UIImage imageNamed:@"NavBarIconBack.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [backButton setAdjustsImageWhenHighlighted:NO];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isVisible = NO;
    isFirstLoad = NO;
}

#pragma mark - Logic
- (void)handleBack:(id)sender withSound:(BOOL)playSound
{
    if([self isPresentedModally] && [self.navigationController.viewControllers count] <= 1)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            // STUB
        }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(playSound)
    {
        [[VKRSAppSoundPlayer sharedInstance] playSound:@"pop-view"];
    }
}
- (void)handleBack:(id)sender
{
    [self handleBack:sender withSound:YES];
}
- (void)setTitle:(NSString *)title
{
    [super setTitle:[title uppercaseString]];
}
- (BOOL)isPresentedModally
{
    BOOL isModal = ((self.parentViewController && self.parentViewController.modalViewController == self) ||
                    //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                    ( self.navigationController && self.navigationController.parentViewController && self.navigationController.parentViewController.modalViewController == self.navigationController) ||
                    //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                    [[[self tabBarController] parentViewController] isKindOfClass:[UITabBarController class]]);
    
    if (!isModal && [self respondsToSelector:@selector(presentingViewController)]) {
        
        isModal = ((self.presentingViewController && self.presentingViewController.modalViewController == self) ||
                   //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                   (self.navigationController && self.navigationController.presentingViewController && self.navigationController.presentingViewController.modalViewController == self.navigationController) ||
                   //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                   [[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]]);
        
    }
    
    return isModal;
}
- (void)didSwitchUserAccount
{
    // STUB
}

#pragma mark - Autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end


@implementation UABaseTableViewController

#pragma mark - Setup
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if(self)
    {
        isVisible = NO;
        isFirstLoad = YES;
        tableStyle = style;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeShown:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconBack.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setBackBarButtonItem:backBarButtonItem];
    }
    
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView = [[UITableView alloc] initWithFrame:baseView.frame style:tableStyle];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
    [baseView addSubview:self.tableView];
    
    self.view = baseView;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Logic
- (void)keyboardWillBeShown:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
}
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // STUB
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap"];
}

@end