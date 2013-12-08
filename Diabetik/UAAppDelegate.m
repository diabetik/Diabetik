//
//  UAAppDelegate.m
//  Diabetik
//
//  Created by Nial Giacomelli on 05/12/2012.
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

#import <Dropbox/Dropbox.h>
#import <ShinobiCharts/ShinobiChart.h>
#import "NXOAuth2.h"
#import "Appirater.h"

#import "UAHelper.h"
#import "UAAppDelegate.h"
#import "UAJournalViewController.h"
#import "UASideMenuViewController.h"

#import "UAReminderController.h"
#import "UAAccountController.h"
#import "UALocationController.h"
#import "UAEventController.h"

#import "UAKeyboardController.h"

@implementation UAAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Setup
+ (void)initialize;
{
    [[NXOAuth2AccountStore sharedStore] setClientID:kRunKeeperClientKey
                                             secret:kRunKeeperClientSecret
                                   authorizationURL:[NSURL URLWithString:kRunKeeperAuthURL]
                                           tokenURL:[NSURL URLWithString:kRunKeeperTokenURL]
                                        redirectURL:[NSURL URLWithString:[NSString stringWithFormat:@"rk%@://oauth2", kRunKeeperClientKey]]
                                     forAccountType:kRunKeeperServiceIdentifier];
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

    // Initialise Appirater
    [Appirater setAppId:@"634983291"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    
    // Is this a first run experience?
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasRunBeforeKey])
    {
        // Dump any existing local notifications (handy when the application has been deleted and re-installed, as iOS likes to keep local notifications around for 24 hours)
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasRunBeforeKey];
    }
    [self setupDefaultConfigurationValues];
    [self setupStyling];
    [self setupSFX];
    [self setupDropbox];
    
    // Setup our backup controller
    self.backupController = [[UABackupController alloc] initWithMOC:[self managedObjectContext]];

    // Call various singletons
    [[UAReminderController sharedInstance] setMOC:self.managedObjectContext];
    [[UAEventController sharedInstance] setMOC:self.managedObjectContext];
    [[UAAccountController sharedInstance] setMOC:self.managedObjectContext];
    [[UAAccountController sharedInstance] activeAccount];
    [UASyncController sharedInstance];
    [UALocationController sharedInstance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = kDefaultTintColor;
    
    UAJournalViewController *journalViewController = [[UAJournalViewController alloc] initWithMOC:self.managedObjectContext];
    UANavigationController *navigationController = [[UANavigationController alloc] initWithRootViewController:journalViewController];
    
    self.viewController = [[REFrostedViewController alloc] initWithContentViewController:navigationController menuViewController:[[UASideMenuViewController alloc] initWithMOC:self.managedObjectContext]];
    self.viewController.direction = REFrostedViewControllerDirectionLeft;
    self.viewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    self.viewController.liveBlur = NO;
    self.viewController.limitMenuViewSize = YES;
    self.viewController.blurSaturationDeltaFactor = 0.25f;
    self.viewController.blurRadius = 10.0f;
    
    [self.window setRootViewController:self.viewController];
    [self.window makeKeyAndVisible];

    // Fetch and cache default keyboard sizes after our view hierarchy has been setup
    [[UAKeyboardController sharedInstance] fetchKeyboardSize];
    
    // Let Appirater know our application has launched
    [Appirater appLaunched:YES];
    
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
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
    
    // Determine whether we need to sync with any external services
    [[UASyncController sharedInstance] requestExternalSyncByForce:NO];
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
    // Is this RunKeeper?
    else if([[url absoluteString] hasPrefix:[NSString stringWithFormat:@"rk%@", kRunKeeperClientKey]])
    {
        BOOL handled = [[NXOAuth2AccountStore sharedStore] handleRedirectURL:url];
        if (!handled) {
            NSLog(@"The URL (%@) could not be handled. Maybe you want to do something with it.", [url absoluteString]);
        }
        
        return handled;
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
                                          kShowInlineImages: @YES
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
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Location services
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UAReminderController sharedInstance] didReceiveLocalNotification:notification];
}

#pragma mark - Core Data stack
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Diabetik" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self persistentStoreURL];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Helpers
- (NSURL *)persistentStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Diabetik.sqlite"];
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
