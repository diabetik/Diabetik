//
//  UABaseViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 11/12/2012.
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

#import "UABaseViewController.h"

@interface UABaseViewController ()
{
    UIView *dismissableOverlayView;
    
    id iCloudChangeNotifier;
}
@end

@implementation UABaseViewController

#pragma mark - Setup
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isVisible = NO;
        isFirstLoad = YES;
        
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(iCloudDataDidChange:)
                                                     name:USMStoreDidImportChangesNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(iCloudDataDidChange:)
                                                     name:USMStoreDidChangeNotification
                                                   object:nil];
        */
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeShown:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(coreDataDidChange:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[[UACoreDataController sharedInstance] managedObjectContext]];
        
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.screenName)
    {
        self.screenName = self.title;
    }
    isVisible = YES;
    
    if(!self.navigationItem.leftBarButtonItem && [self.navigationController.viewControllers count] > 1)
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [backButton setImage:[[UIImage imageNamed:@"NavBarIconBack.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [backButton setTitle:self.navigationItem.backBarButtonItem.title forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10.0f, 0, 0)];
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
- (void)reloadViewData:(NSNotification *)note
{
    // STUB
}
- (void)handleBack:(id)sender withSound:(BOOL)playSound
{
    if([self isPresentedModally] && [self.navigationController.viewControllers count] <= 1)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
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
    BOOL isModal = ((self.presentingViewController && self.presentingViewController.presentedViewController == self) ||
                    //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                    (self.navigationController && self.navigationController.presentingViewController && self.navigationController.presentingViewController.presentedViewController) ||
                    //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                    [[[self tabBarController] parentViewController] isKindOfClass:[UITabBarController class]]);
    
    return isModal;
}
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([self.navigationController.viewControllers count] <= 1)
    {
        return YES;
    }
    return NO;
}

#pragma mark - Keyboard notifications
- (void)keyboardWillBeShown:(NSNotification *)aNotification
{
    // STUB
}
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    // STUB
}
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    // STUB
}
- (void)keyboardWasHidden:(NSNotification *)aNotification
{
    // STUB
}

#pragma mark - Notifications
- (void)coreDataDidChange:(NSNotification *)note
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reloadViewData:note];
    });
}
- (void)iCloudDataDidChange:(NSNotification *)note
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf reloadViewData:note];
    });
}

#pragma mark - Helpers
- (UIView *)dismissableView
{
    if(!dismissableOverlayView)
    {
        dismissableOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
        dismissableOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dismissableOverlayView.backgroundColor = [UIColor clearColor];
        dismissableOverlayView.userInteractionEnabled = YES;
    }
    
    return dismissableOverlayView;
}
- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    
    return duration;
}

#pragma mark - Autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

@end


@interface UABaseTableViewController ()
{
    BOOL keyboardShown;
    CGFloat keyboardOverlap;
}

@end

@implementation UABaseTableViewController

#pragma mark - Setup
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        tableStyle = style;
         
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconBack.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setBackBarButtonItem:backBarButtonItem];
    }
    
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:baseView.frame style:tableStyle];
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
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    edgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    edgePanGestureRecognizer.edges = UIRectEdgeLeft;
    edgePanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:edgePanGestureRecognizer];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if(selectedIndexPath)
    {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:NO];
    }
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    self.tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap"];
}

#pragma mark - Helpers
- (void)tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
{
    // Scroll to the active cell
    if(self.activeControlIndexPath)
    {
        [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        [self.tableView selectRowAtIndexPath:self.activeControlIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end