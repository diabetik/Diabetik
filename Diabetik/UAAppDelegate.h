//
//  UAAppDelegate.h
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "REFrostedViewController.h"

#import "UAUI.h"
#import "UABackupController.h"
#import "UASideMenuController.h"

#import "UAAccount.h"
#import "UASyncController.h"

@interface UAAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, BITHockeyManagerDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) REFrostedViewController *viewController;
@property (strong, nonatomic) UABackupController *backupController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Logic
- (void)setupDropbox;
- (void)setupStyling;
- (void)setupSFX;
- (void)setupDefaultConfigurationValues;

// Helpers
- (void)saveContext;
- (NSURL *)persistentStoreURL;
- (NSURL *)applicationDocumentsDirectory;

@end