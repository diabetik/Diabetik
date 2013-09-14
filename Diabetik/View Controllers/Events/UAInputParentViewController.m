//
//  UAInputParentViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 06/12/2012.
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

#import <QuartzCore/QuartzCore.h>
#import "UAKeyboardController.h"
#import "UAInputParentViewController.h"
#import "UAEventMapViewController.h"
#import "UAImageViewController.h"
#import "UAReminderController.h"

#import "UAMedicineInputViewController.h"
#import "UAMealInputViewController.h"
#import "UABGInputViewController.h"
#import "UAActivityInputViewController.h"
#import "UANoteInputViewController.h"

#define kDragBuffer 15.0f
#define kVCHorizontalPadding 0.0f

@interface UAInputParentViewController ()
{
    UANotesTextView *notesTextView;
    UIImageView *addEntryBubbleImageView;
    
    CGPoint scrollVelocity;
    
    CGPoint originalContentOffset;
    BOOL isAddingQuickEntry;
    BOOL isAnimatingAddEntry;
    BOOL isBeingPopped;
}

// Helpers
- (UAInputBaseViewController *)targetViewController;
- (UIColor *)colorLerpFrom:(UIColor *)start
                        to:(UIColor *)end
              withDuration:(float)t;

@end

@implementation UAInputParentViewController
@synthesize moc = _moc;
@synthesize event = _event;

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC andEventType:(NSInteger)eventType
{
    self = [super init];
    if (self)
    {
        _moc = aMOC;
        isAddingQuickEntry = NO;
        isAnimatingAddEntry = NO;
        isBeingPopped = NO;
    
        UAInputBaseViewController *vc = nil;
        if(eventType == 0)
        {
            vc = [[UAMedicineInputViewController alloc] initWithMOC:self.moc];
        }
        else if(eventType == 1)
        {
            vc = [[UABGInputViewController alloc] initWithMOC:self.moc];
        }
        else if(eventType == 2)
        {
            vc = [[UAMealInputViewController alloc] initWithMOC:self.moc];
        }
        else if(eventType == 3)
        {
            vc = [[UAActivityInputViewController alloc] initWithMOC:self.moc];
        }
        else if(eventType == 4)
        {
            vc = [[UANoteInputViewController alloc] initWithMOC:self.moc];
        }
        
        self.viewControllers = [NSMutableArray arrayWithObject:vc];
        
        [self performSetup];
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)aEvent andMOC:(NSManagedObjectContext *)aMOC
{
    _event = aEvent;
    _moc = aMOC;
    
    self = [super init];
    if(self)
    {
        isAddingQuickEntry = NO;
        isAnimatingAddEntry = NO;
        isBeingPopped = NO;
        
        if([aEvent isKindOfClass:[UAMedicine class]])
        {
            self.viewControllers = [NSMutableArray arrayWithObject:[[UAMedicineInputViewController alloc] initWithEvent:aEvent andMOC:aMOC]];
        }
        else if([aEvent isKindOfClass:[UAReading class]])
        {
            self.viewControllers = [NSMutableArray arrayWithObject:[[UABGInputViewController alloc] initWithEvent:aEvent andMOC:aMOC]];
        }
        else if([aEvent isKindOfClass:[UAActivity class]])
        {
            self.viewControllers = [NSMutableArray arrayWithObject:[[UAActivityInputViewController alloc] initWithEvent:aEvent andMOC:aMOC]];
        }
        else if([aEvent isKindOfClass:[UAMeal class]])
        {
            self.viewControllers = [NSMutableArray arrayWithObject:[[UAMealInputViewController alloc] initWithEvent:aEvent andMOC:aMOC]];
        }
        else if([aEvent isKindOfClass:[UANote class]])
        {
            self.viewControllers = [NSMutableArray arrayWithObject:[[UANoteInputViewController alloc] initWithEvent:aEvent andMOC:aMOC]];
        }
        
        [self performSetup];
    }
    
    return self;
}
- (void)performSetup
{
    // Setup notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentMediaOptions:)
                                                 name:@"presentMediaOptions" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentGeotagOptions:)
                                                 name:@"presentGeotagOptions" object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [[self targetViewController] barTintColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UAFont standardDemiBoldFontWithSize:17.0f]};
    
    // Setup our table view
    self.view.backgroundColor = [UIColor whiteColor];
    if(!self.keyboardBackingView)
    {
        self.locationButton = [[UAKeyboardBackingViewButton alloc] initWithFrame:CGRectZero];
        [self.locationButton setImage:[UIImage imageNamed:@"AddEntryKeyboardLocation.png"] forState:UIControlStateNormal];
        [self.locationButton addTarget:self action:@selector(presentGeotagOptions:) forControlEvents:UIControlEventTouchUpInside];
        
        self.photoButton = [[UAKeyboardBackingViewButton alloc] initWithFrame:CGRectZero];
        [self.photoButton setImage:[UIImage imageNamed:@"AddEntryKeyboardPhoto.png"] forState:UIControlStateNormal];
        [self.photoButton setTitle:NSLocalizedString(@"Add Photo", nil) forState:UIControlStateNormal];
        [self.photoButton addTarget:self action:@selector(presentMediaOptions:) forControlEvents:UIControlEventTouchUpInside];
        
        UAKeyboardBackingViewButton *reminderButton = [[UAKeyboardBackingViewButton alloc] initWithFrame:CGRectZero];
        [reminderButton setImage:[UIImage imageNamed:@"AddEntryKeyboardReminders.png"] forState:UIControlStateNormal];
        [reminderButton setTitle:NSLocalizedString(@"Add Reminder", nil) forState:UIControlStateNormal];
        [reminderButton addTarget:self action:@selector(presentAddReminder:) forControlEvents:UIControlEventTouchUpInside];
        
        UAKeyboardBackingViewButton *tweetButton = [[UAKeyboardBackingViewButton alloc] initWithFrame:CGRectZero];
        [tweetButton setImage:[UIImage imageNamed:@"AddEntryKeyboardTweet.png"] forState:UIControlStateNormal];
        [tweetButton setTitle:NSLocalizedString(@"Tweet", @"A button allowing users to post an entry on Twitter") forState:UIControlStateNormal];
        [tweetButton addTarget:self action:@selector(presentTweetComposer:) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL enableTwitterButton = YES;
        if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") || !NSClassFromString(@"SLComposeViewController"))
        {
            enableTwitterButton = NO;            
        }
        else
        {
            if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                enableTwitterButton = NO;
            }
        }
        [tweetButton setEnabled:enableTwitterButton];        
        
        UAKeyboardBackingViewButton *likeButton = [[UAKeyboardBackingViewButton alloc] initWithFrame:CGRectZero];
        [likeButton setImage:[UIImage imageNamed:@"AddEntryKeyboardLike.png"] forState:UIControlStateNormal];
        [likeButton setTitle:NSLocalizedString(@"Like", @"A button allowing users to 'Like' an entry on Facebook") forState:UIControlStateNormal];
        [likeButton addTarget:self action:@selector(presentFacebookComposer:) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL enableFacebookButton = YES;
        if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") || !NSClassFromString(@"SLComposeViewController"))
        {
            enableFacebookButton = NO;
        }
        else
        {
            if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                enableFacebookButton = NO;
            }
        }
        [likeButton setEnabled:enableFacebookButton];
        
        UAKeyboardBackingViewButton *deleteButton = [[UAKeyboardBackingViewButton alloc] initWithFrame:CGRectZero];
        [deleteButton setImage:[UIImage imageNamed:@"AddEntryKeyboardTrash.png"] forState:UIControlStateNormal];
        [deleteButton setTitle:NSLocalizedString(@"Delete Entry", nil) forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteEvent:) forControlEvents:UIControlEventTouchUpInside];
        if(!self.event)
        {
            //[deleteButton setEnabled:NO];
        }
        
        CGSize keyboardSize = [[UAKeyboardController sharedInstance] keyboardSize];
        NSArray *buttons = @[self.locationButton, self.photoButton, reminderButton, tweetButton, likeButton, deleteButton];
        self.keyboardBackingView = [[UAKeyboardBackingView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - keyboardSize.height, keyboardSize.width, keyboardSize.height) andButtons:buttons];
        self.keyboardBackingView.delegate = self;
        self.keyboardBackingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:self.keyboardBackingView];
        
        [self updateKeyboardButtons];
    }
    
    // Setup our scroll view
    if(!self.scrollView)
    {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - self.keyboardBackingView.bounds.size.height + kAccessoryViewHeight)];
        self.scrollView.delegate = self;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.directionalLockEnabled = YES;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        [self.view insertSubview:self.scrollView belowSubview:self.keyboardBackingView];
        
        for(UAInputBaseViewController *vc in self.viewControllers)
        {
            [self addVC:vc];
        }
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
    }
    
    if(!addEntryBubbleImageView)
    {
        addEntryBubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddEntryMedicineBubble.png"]];
        addEntryBubbleImageView.frame = CGRectMake(self.view.frame.size.width - addEntryBubbleImageView.frame.size.width, self.scrollView.frame.size.height/2.0f - addEntryBubbleImageView.frame.size.height/2.0f, addEntryBubbleImageView.frame.size.width, addEntryBubbleImageView.frame.size.height);
        addEntryBubbleImageView.alpha = 0.0f;
        [self.view addSubview:addEntryBubbleImageView];
    }
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(saveEvent:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
    
    [self updateNavigationBar];
    [self updateKeyboardButtons];
    
    if(!self.event && ![[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenAddDragUIHint])
    {
        __weak typeof(self) weakSelf = self;
        UAUIHintView *hintView = [[UAUIHintView alloc] initWithFrame:self.scrollView.frame text:NSLocalizedString(@"Drag left to add additional entries", nil) presentationCallback:^{
            weakSelf.scrollView.alpha = 0.25f;
        } dismissCallback:^{
            weakSelf.scrollView.alpha = 1.0f;
        }];
        [self.view addSubview:hintView];
        [hintView present];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenAddDragUIHint];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIColor *defaultBarTintColor = kDefaultBarTintColor;
    UIColor *defaultTintColor = kDefaultTintColor;
    self.navigationController.navigationBar.barTintColor = defaultBarTintColor;
    self.navigationController.navigationBar.tintColor = defaultTintColor;
    
    if(isBeingPopped)
    {
        UIColor *defaultBarTintColor = kDefaultBarTintColor;
        [self.navigationController.navigationBar setBarTintColor:defaultBarTintColor];
    }
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(isBeingPopped)
    {
        self.scrollView = nil;
        for(UAInputBaseViewController *vc in [self.viewControllers copy])
        {
            [self removeVC:vc];
        }
        self.viewControllers = nil;
    }
}

#pragma mark - Logic
- (void)saveEvent:(id)sender
{
    UAInputBaseViewController *targetVC = [self targetViewController];
    [targetVC.view endEditing:YES];
    
    NSError *validationError = nil;
    NSInteger vcIndex = 0;
    for(UAInputBaseViewController *vc in self.viewControllers)
    {
        validationError = [vc validationError];
        if(validationError)
        {
            [self.scrollView scrollRectToVisible:CGRectMake(vcIndex*self.scrollView.bounds.size.width, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:validationError.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            
            break;
        }
        vcIndex ++;
    }
    
    if(!validationError)
    {
        NSMutableArray *newEvents = [NSMutableArray array];
        
        NSError *saveError = nil;
        for(UAInputBaseViewController *vc in self.viewControllers)
        {
            UAEvent *event = [vc saveEvent:&saveError];
            if(event && !saveError)
            {
                [newEvents addObject:event];
            }
        }
        
        // If we're editing an event, remove it so that we don't continually create new reminders
        if(self.event)
        {
            [newEvents removeObject:self.event];
        }
        
        // Iterate over our newly created events and see if any match our rules
        NSArray *rules = [[UAReminderController sharedInstance] fetchAllReminderRules];
        if(rules && [rules count])
        {
            for(UAReminderRule *rule in rules)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:rule.predicate];
                if(predicate)
                {
                    NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:[newEvents filteredArrayUsingPredicate:predicate]];
                
                    // If we have a match go ahead and create a reminder
                    if(filteredEvents && [filteredEvents count])
                    {
                        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAReminder" inManagedObjectContext:self.moc];
                        UAReminder *newReminder = (UAReminder *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.moc];
                        newReminder.created = [NSDate date];
                        
                        NSDate *triggerDate = [[filteredEvents objectAtIndex:0] valueForKey:@"timestamp"];
                        
                        newReminder.message = rule.name;
                        if([rule.intervalType integerValue] == kMinuteIntervalType)
                        {
                            newReminder.date = [triggerDate dateByAddingMinutes:[rule.intervalAmount integerValue]];
                        } 
                        else if([rule.intervalType integerValue] == kHourIntervalType)
                        {
                            newReminder.date = [triggerDate dateByAddingHours:[rule.intervalAmount integerValue]];
                        }
                        else if([rule.intervalType integerValue] == kDayIntervalType)
                        {
                            newReminder.date = [triggerDate dateByAddingDays:[rule.intervalAmount integerValue]];
                        }
                        newReminder.type = [NSNumber numberWithInteger:kReminderTypeDate];
                        
                        NSError *error = nil;                        
                        [self.moc save:&error];
                        
                        if(!error)
                        {
                            [[UAReminderController sharedInstance] setNotificationsForReminder:newReminder];
                            
                            // Notify anyone interested that we've updated our reminders
                            [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                        }
                    }
                }
            }
        }
        
        [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
        [self handleBack:self withSound:NO];
    }
}
- (void)deleteEvent:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *targetVC = [self targetViewController];
    [targetVC triggerDeleteEvent:sender];
}
- (void)discardChanges:(id)sender
{
    for(UAInputBaseViewController *vc in self.viewControllers)
    {
        [vc discardChanges];
    }
    
    [self handleBack:self];
}
- (void)addVC:(UIViewController *)vc
{
    CGFloat contentWidth = self.scrollView.contentSize.width > 0 ? self.scrollView.contentSize.width-kVCHorizontalPadding : 0.0f;
    
    vc.view.frame = CGRectMake(contentWidth, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    [self.scrollView addSubview:vc.view];
    
    self.scrollView.contentSize = CGSizeMake(contentWidth + vc.view.frame.size.width + kVCHorizontalPadding, self.scrollView.bounds.size.height);
}
- (void)removeVC:(UIViewController *)vc
{
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    [self.viewControllers removeObject:vc];
    
    // Re-layout subviews
    CGFloat x = 0.0f;
    for(UAInputBaseViewController *vc in self.viewControllers)
    {
        vc.view.frame = CGRectMake(x, 0.0f, vc.view.frame.size.width, vc.view.frame.size.height);
        x += vc.view.frame.size.width;
    }
    
    // Adjust our viewport
    CGFloat contentWidth = self.scrollView.contentSize.width > 0 ? self.scrollView.contentSize.width-kVCHorizontalPadding : 0.0f;
    self.scrollView.contentSize = CGSizeMake((contentWidth - vc.view.frame.size.width) + kVCHorizontalPadding, self.scrollView.bounds.size.height);
    if(self.scrollView.contentOffset.x >= self.scrollView.contentSize.width - vc.view.frame.size.width - kVCHorizontalPadding)
    {
       [self.scrollView setContentOffset:CGPointMake((self.viewControllers.count-1)*vc.view.frame.size.width, 0.0f) animated:NO];
    }
    
    // Update UI
    [self activateTargetViewController];
}
- (void)activateTargetViewController
{
    BOOL currentlyEditing = NO;
    for(UAInputBaseViewController *vc in self.viewControllers)
    {
        if(vc.activeControlIndexPath != nil)
        {
            currentlyEditing = YES;
        }
        [vc willBecomeInactive];
    }
    
    UAInputBaseViewController *targetVC = [self targetViewController];
    [targetVC didBecomeActive:currentlyEditing];
    
    self.navigationController.navigationBar.barTintColor = [targetVC barTintColor];
    
    [self updateNavigationBar];
    [self updateKeyboardButtons];
}
- (void)handleBack:(id)sender
{
    isBeingPopped = YES;
    
    [super handleBack:sender];
}
- (void)handleBack:(id)sender withSound:(BOOL)playSound
{
    isBeingPopped = YES;
    
    [super handleBack:sender withSound:playSound];
}

#pragma mark - UI
- (void)presentAddReminder:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UIActionSheet *actionSheet = nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remind me in", nil)
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                destructiveButtonTitle:nil
                                     otherButtonTitles:NSLocalizedString(@"15 minutes", nil), NSLocalizedString(@"30 minutes", nil), NSLocalizedString(@"1 hour", nil), NSLocalizedString(@"The future", @"An option allow users to be reminded at some point in the future"), nil];
    actionSheet.tag = kExistingImageActionSheetTag;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)presentMediaOptions:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *targetVC = [self targetViewController];

    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = nil;
    if(targetVC.currentPhotoPath)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:targetVC
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Delete photo", nil)
                                         otherButtonTitles:NSLocalizedString(@"View photo", nil), NSLocalizedString(@"Take new photo", nil), NSLocalizedString(@"Choose new photo", nil), nil];
        actionSheet.tag = kExistingImageActionSheetTag;
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:targetVC
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
        actionSheet.tag = kImageActionSheetTag;
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)presentGeotagOptions:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *targetVC = [self targetViewController];

    [self.view endEditing:YES];
    if((self.event && [self.event.lat doubleValue] != 0.0 && [self.event.lon doubleValue] != 0.0) || ([targetVC.lat doubleValue] != 0.0 && [targetVC.lon doubleValue] != 0.0))
    {
        UIActionSheet *actionSheet = nil;
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:targetVC
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Remove", nil)
                                         otherButtonTitles:NSLocalizedString(@"View on map", nil), NSLocalizedString(@"Update location", nil), nil];
        actionSheet.tag = kGeotagActionSheetTag;
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Location", nil)
                                                            message:NSLocalizedString(@"Are you sure you'd like to add location data to this event?" ,nil)
                                                           delegate:targetVC
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Add", nil), nil];
        alertView.tag = kGeoTagAlertViewTag;
        [alertView show];
    }
}
- (void)presentTweetComposer:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *targetVC = [self targetViewController];
    
    SLComposeViewController *tweetComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetComposerSheet setInitialText:[targetVC twitterSocialMessageText]];
    if(targetVC.currentPhotoPath)
    {
        [tweetComposerSheet addImage:[[UAMediaController sharedInstance] imageWithFilename:targetVC.currentPhotoPath]];
    }
    
    __weak typeof(self) weakSelf = self;
    [tweetComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tweet sent", nil)
                                                                    message:NSLocalizedString(@"Your tweet has been sent", nil)
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
                break;
            default:
                break;
        }
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:tweetComposerSheet animated:YES completion:nil];
}
- (void)presentFacebookComposer:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *targetVC = [self targetViewController];
    
    SLComposeViewController *facebookComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookComposerSheet setInitialText:[targetVC facebookSocialMessageText]];
    if(targetVC.currentPhotoPath)
    {
        [facebookComposerSheet addImage:[[UAMediaController sharedInstance] imageWithFilename:targetVC.currentPhotoPath]];
    }
    
    __weak typeof(self) weakSelf = self;
    [facebookComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update sent", nil)
                                                                    message:NSLocalizedString(@"Your Facebook update has been sent", nil)
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
                break;
            default:
                break;
        }
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:facebookComposerSheet animated:YES completion:nil];
}
- (void)updateKeyboardButtons
{
    UAInputBaseViewController *targetVC = [self targetViewController];
    if((targetVC.event && [targetVC.event.lat doubleValue] != 0.0 && [targetVC.event.lon doubleValue] != 0.0) || ([targetVC.lat doubleValue] != 0.0 && [targetVC.lon doubleValue] != 0.0))
    {
        [self.locationButton setTitle:NSLocalizedString(@"View Location", nil) forState:UIControlStateNormal];
        [self.keyboardBackingView.locationIndicatorImageView setImage:[UIImage imageNamed:@"KeyboardDismissLocationActive.png"]];
    }
    else
    {
        [self.locationButton setTitle:NSLocalizedString(@"Add Location", nil) forState:UIControlStateNormal];
        [self.keyboardBackingView.locationIndicatorImageView setImage:[UIImage imageNamed:@"KeyboardDismissLocationInactive.png"]];
    }
    
    if(targetVC.currentPhotoPath)
    {
        [self.photoButton setTitle:NSLocalizedString(@"View Photo", nil) forState:UIControlStateNormal];
        [self.keyboardBackingView.photoIndicatorImageView setImage:[UIImage imageNamed:@"KeyboardDismissPhotoActive.png"]];
    }
    else
    {
        [self.photoButton setTitle:NSLocalizedString(@"Add Photo", nil) forState:UIControlStateNormal];
        [self.keyboardBackingView.photoIndicatorImageView setImage:[UIImage imageNamed:@"KeyboardDismissPhotoInactive.png"]];
    }
}
- (void)updateNavigationBar
{
    UAInputBaseViewController *targetVC = [self targetViewController];
    
    if([self.viewControllers count] > 1)
    {
        NSInteger page = (NSInteger)floorf(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
        UANavPaginationTitleView *titleView = [[UANavPaginationTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        [titleView setTitle:targetVC.title];
        [titleView.pageControl setViewControllers:self.viewControllers];
        [titleView.pageControl setCurrentPage:page];
        self.navigationItem.titleView = titleView;
    }
    else if(targetVC.event && targetVC.event.externalSource)
    {
        UANavSubtitleHeaderView *titleView = [[UANavSubtitleHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        [titleView setTitle:targetVC.title];
        [titleView setSubtitle:self.event.externalSource];
        self.navigationItem.titleView = titleView;
    }
    else
    {
        self.navigationItem.title = targetVC.title;
        self.navigationItem.titleView = nil;
    }
}

#pragma mark - UAKeyboardBackingDelegate
- (void)presentKeyboard
{
    UAInputBaseViewController *targetVC = [self targetViewController];
    
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[targetVC.tableView cellForRowAtIndexPath:targetVC.previouslyActiveControlIndexPath];
    if(!cell)
    {
        [targetVC.tableView scrollToRowAtIndexPath:targetVC.previouslyActiveControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    cell = (UAEventInputViewCell *)[targetVC.tableView cellForRowAtIndexPath:targetVC.previouslyActiveControlIndexPath];
    
    [cell.control becomeFirstResponder];
}
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    originalContentOffset = aScrollView.contentOffset;
}
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat offsetX = [self.viewControllers count] > 1 ? aScrollView.contentOffset.x - ([self.viewControllers count]-1)*aScrollView.frame.size.width : aScrollView.contentOffset.x;

    if(aScrollView.isTracking && offsetX > kDragBuffer && [self.viewControllers count] < 8)
    {
        addEntryBubbleImageView.alpha = 1.0f; //((offsetX-kDragBuffer > 20.0f ? 20.0f : offsetX-kDragBuffer)/20.0f)*1.0f;
        aScrollView.alpha = 1.0f - ((offsetX-kDragBuffer > 20.0f ? 20.0f : offsetX-kDragBuffer)/20.0f)*0.5f;
        
        if(offsetX-kDragBuffer < 20.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryMedicineBubble.png"];
        }
        else if(offsetX-kDragBuffer < 40.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryBloodBubble.png"];
        }
        else if(offsetX-kDragBuffer < 60.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryMealBubble.png"];
        }
        else if(offsetX-kDragBuffer < 80.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryActivityBubble.png"];
        }
        else if(offsetX-kDragBuffer < 100.0f)
        {
            addEntryBubbleImageView.image = [UIImage imageNamed:@"AddEntryNoteBubble.png"];
        }
    }
    else
    {
        addEntryBubbleImageView.alpha = 0.0f;
        aScrollView.alpha = 1.0f;
    }
    
    if(isAddingQuickEntry && !aScrollView.tracking && !isAnimatingAddEntry)
    {
        [aScrollView scrollRectToVisible:CGRectMake(aScrollView.contentSize.width-aScrollView.frame.size.width-kVCHorizontalPadding, 0.0f, aScrollView.frame.size.width, aScrollView.frame.size.height) animated:YES];
        isAnimatingAddEntry = YES;
    }
    else if(!aScrollView.isTracking && aScrollView.contentOffset.x > aScrollView.contentSize.width-aScrollView.frame.size.width-kVCHorizontalPadding && !isAnimatingAddEntry)
    {
        [aScrollView scrollRectToVisible:CGRectMake(aScrollView.contentSize.width-aScrollView.frame.size.width-kVCHorizontalPadding, 0.0f, aScrollView.frame.size.width, aScrollView.frame.size.height) animated:YES];
        isAnimatingAddEntry = YES;
    }
    
    if(aScrollView.isTracking)
    {
        scrollVelocity = [[aScrollView panGestureRecognizer] velocityInView:aScrollView.superview];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetX = [self.viewControllers count] > 1 ? aScrollView.contentOffset.x - ([self.viewControllers count]-1)*aScrollView.frame.size.width : aScrollView.contentOffset.x;
    if(fabsf(scrollVelocity.x) < 150.0f && offsetX > kDragBuffer && [self.viewControllers count] < 8)
    {
        isAddingQuickEntry = YES;
        
        if(offsetX-kDragBuffer < 20.0f)
        {
            UAMedicineInputViewController *vc = [[UAMedicineInputViewController alloc] initWithMOC:self.moc];
            [self.viewControllers addObject:vc];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 40.0f)
        {
            UABGInputViewController *vc = [[UABGInputViewController alloc] initWithMOC:self.moc];
            [self.viewControllers addObject:vc];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 60.0f)
        {
            UAMealInputViewController *vc = [[UAMealInputViewController alloc] initWithMOC:self.moc];
            [self.viewControllers addObject:vc];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 80.0f)
        {
            UAActivityInputViewController *vc = [[UAActivityInputViewController alloc] initWithMOC:self.moc];
            [self.viewControllers addObject:vc];
            [self addVC:(UIViewController *)vc];
        }
        else if(offsetX-kDragBuffer < 100.0f)
        {
            UANoteInputViewController *vc = [[UANoteInputViewController alloc] initWithMOC:self.moc];
            [self.viewControllers addObject:vc];
            [self addVC:(UIViewController *)vc];
        }
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    isAnimatingAddEntry = NO;
    isAddingQuickEntry = NO;
    [self activateTargetViewController];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    if(!isAddingQuickEntry && !isAnimatingAddEntry)
    {
        [self activateTargetViewController];
    }
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex > 3) return;
    
    NSInteger minutes = 0;
    switch(buttonIndex)
    {
        case 0:
            minutes = 15;
            break;
        case 1:
            minutes = 30;
            break;
        case 2:
            minutes = 60;
            break;
    }
    
    NSDate *date = [[NSDate date] dateByAddingMinutes:minutes];
    UATimeReminderViewController *vc = [[UATimeReminderViewController alloc] initWithMOC:self.moc andDate:date];
    UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:^{
        // STUB
    }];
}

#pragma mark - Helpers
- (UAInputBaseViewController *)targetViewController
{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if(offsetX < 0.0f) offsetX = 0.0f;
    if(offsetX > self.scrollView.contentSize.width) offsetX = self.scrollView.contentSize.width;
    
    NSInteger page = (NSInteger)floorf(offsetX / self.scrollView.bounds.size.width);
    if(page < 0) page = 0;
    
    if(self.viewControllers && [self.viewControllers count] && [self.viewControllers count]-1 >= page)
    {
        return (UAInputBaseViewController *)[self.viewControllers objectAtIndex:page];
    }
    
    return nil;
}
- (UIColor *)colorLerpFrom:(UIColor *)start
                        to:(UIColor *)end
              withDuration:(float)t
{
    if(t < 0.0f) t = 0.0f;
    if(t > 1.0f) t = 1.0f;
    
    const CGFloat *startComponent = CGColorGetComponents(start.CGColor);
    const CGFloat *endComponent = CGColorGetComponents(end.CGColor);
    
    float startAlpha = CGColorGetAlpha(start.CGColor);
    float endAlpha = CGColorGetAlpha(end.CGColor);
    
    float r = startComponent[0] + (endComponent[0] - startComponent[0]) * t;
    float g = startComponent[1] + (endComponent[1] - startComponent[1]) * t;
    float b = startComponent[2] + (endComponent[2] - startComponent[2]) * t;
    float a = startAlpha + (endAlpha - startAlpha) * t;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
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
