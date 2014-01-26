//
//  UAAppDelegate.m
//  Diabetik
//
//  Created by Nial Giacomelli on 05/12/2012.
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
#import <ShinobiCharts/ShinobiChart.h>
#import "GAI.h"
#import "Appirater.h"

#import "UAHelper.h"
#import "UAAppDelegate.h"
#import "UAJournalViewController.h"
#import "UASideMenuViewController.h"

#import "UAReminderController.h"
#import "UALocationController.h"
#import "UAEventController.h"
#import "UASyncController.h"

#import "UAKeyboardController.h"

@implementation UAAppDelegate

#pragma mark - Setup
+ (UAAppDelegate *)sharedAppDelegate
{
    return (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialise HockeyApp if we have applicable credentials
    if(
       kHockeyAppBetaIdentifierKey && [kHockeyAppBetaIdentifierKey length] &&
       kHockeyAppLiveIdentifierKey && [kHockeyAppLiveIdentifierKey length]
    )
    {
#ifdef RELEASE_BUILD
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppLiveIdentifierKey delegate:self];
#else
        NSLog(@"Running beta build");
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppBetaIdentifierKey delegate:self];
#endif
        [[BITHockeyManager sharedHockeyManager] startManager];
    }

    // Initialise the Google Analytics API
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingID];
    
    // Initialise Appirater
    [Appirater setAppId:@"634983291"];
    [Appirater setDaysUntilPrompt:4];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    [Appirater setDebug:NO];
    
    // Is this a first run experience?
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasRunBeforeKey])
    {
        // Dump any existing local notifications (handy when the application has been deleted and re-installed,
        // as iOS likes to keep local notifications around for 24 hours)
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasRunBeforeKey];
    }
    
    [self setupDefaultConfigurationValues];
    [self setupStyling];
    
    // Wake up singletons
    [UACoreDataController sharedInstance];
    [self setBackupController:[[UABackupController alloc] init]];
    
    // Setup our backup controller
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = kDefaultTintColor;
    
    UAJournalViewController *journalViewController = [[UAJournalViewController alloc] init];
    UANavigationController *navigationController = [[UANavigationController alloc] initWithRootViewController:journalViewController];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = [[UISplitViewController alloc] initWithNibName:nil bundle:nil];
        splitViewController.viewControllers = @[[[UASideMenuViewController alloc] init], navigationController];
        splitViewController.delegate = self;
        self.viewController = splitViewController;
    }
    else
    {
        REFrostedViewController *viewController = [[REFrostedViewController alloc] initWithContentViewController:navigationController menuViewController:[[UASideMenuViewController alloc] init]];
        viewController.direction = REFrostedViewControllerDirectionLeft;
        viewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
        viewController.liveBlur = NO;
        viewController.limitMenuViewSize = YES;
        viewController.blurSaturationDeltaFactor = 3.0f;
        viewController.blurRadius = 10.0f;
        self.viewController = viewController;
    }
    
    // Delay launch on non-essential classes
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf setupSFX];
            [strongSelf setupDropbox];
            
            // Call various singletons
            [UASyncController sharedInstance];
            [UAReminderController sharedInstance];
            [UALocationController sharedInstance];
            [[UAKeyboardController sharedInstance] fetchKeyboardSize];
        });
    });
    
    [self.window setRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    
    // Let Appirater know our application has launched
    [Appirater appLaunched:YES];
    
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UACoreDataController sharedInstance] saveContext];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationResumed" object:nil];
    
    // Let Appirater know our application has launched
    [Appirater appLaunched:YES];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Delete any expired date-based notifications
    [[UAReminderController sharedInstance] deleteExpiredReminders];
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation
{
    // Is this Dropbox?
    if([source isEqualToString:@"com.getdropbox.Dropbox"])
    {
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        if (account)
        {
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
            
            // Post a notification so that we can determine when linking occurs
            [[NSNotificationCenter defaultCenter] postNotificationName:kDropboxLinkNotification object:account];
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Logic
- (void)setupDropbox
{
    // Ditch out if we haven't been provided credentials
    if(!kDropboxAppKey || !kDropboxSecret || ![kDropboxAppKey length] || ![kDropboxSecret length]) return;
    
    DBAccountManager *accountMgr = [[DBAccountManager alloc] initWithAppKey:kDropboxAppKey secret:kDropboxSecret];
    [DBAccountManager setSharedManager:accountMgr];
    DBAccount *account = accountMgr.linkedAccount;
    
    if (account)
    {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
}
- (void)setupSFX
{
    [[VKRSAppSoundPlayer sharedInstance] addSoundWithFilename:@"tap" andExtension:@"caf"];
    [[VKRSAppSoundPlayer sharedInstance] addSoundWithFilename:@"pop-view" andExtension:@"caf"];
    [[VKRSAppSoundPlayer sharedInstance] addSoundWithFilename:@"tap-significant" andExtension:@"caf"];
    [[VKRSAppSoundPlayer sharedInstance] addSoundWithFilename:@"success" andExtension:@"caf"];
    [[VKRSAppSoundPlayer sharedInstance] setSoundsEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:kUseSoundsKey]];
}
- (void)setupDefaultConfigurationValues
{
    // Try to determine the users blood sugar unit based on their locale
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                         kBGTrackingUnitKey: [NSNumber numberWithInt:([countryCode isEqualToString:@"US"]) ? BGTrackingUnitMG : BGTrackingUnitMMO],
                                           kMinHealthyBGKey: @4,
                                           kMaxHealthyBGKey: @7,
     
                                          kUseSmartInputKey: @YES,
                                              kUseSoundsKey: @YES,
                                          kShowInlineImages: @YES,
                                    kFilterSearchResultsKey: @YES,
                                         
                               kAutomaticBackupFrequencyKey: @(BackupOnceADay),
                                         USMCloudEnabledKey: @NO // iCloud is disabled by default
     }];
    
    
}
- (void)setupStyling
{
    NSDictionary *attributes = nil;
    
    UIColor *defaultBarTintColor = kDefaultBarTintColor;
    [[UINavigationBar appearance] setBarTintColor:defaultBarTintColor];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UAFont standardDemiBoldFontWithSize:17.0f]}];
    
    // UISwitch
    [[UISwitch appearance] setOnTintColor:[UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
    
    // UISegmentedControl
    attributes = @{
                   NSFontAttributeName: [UAFont standardDemiBoldFontWithSize:13.0f],
                   NSForegroundColorAttributeName: [UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]
                   };
    [[UISegmentedControl appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f]];
    
    // Charts
    [ShinobiCharts setTheme:[SChartiOS7Theme new]];
}

#pragma mark - UISplitViewControllerDelegate method
- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    UINavigationController *nvc = svc.viewControllers[1];
    UIViewController *vc = nvc.viewControllers[0];
    
    barButtonItem.image = [[UIImage imageNamed:@"NavBarIconListMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    vc.navigationItem.leftBarButtonItem = barButtonItem;
}
- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    UINavigationController *nvc = svc.viewControllers[1];
    UIViewController *vc = nvc.viewControllers[0];
    vc.navigationItem.leftBarButtonItem = nil;
}
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}
 
#pragma mark - Location services
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UAReminderController sharedInstance] didReceiveLocalNotification:notification];
}

@end
