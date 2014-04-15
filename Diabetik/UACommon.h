//
//  UACommon.h
//  Diabetik
//
//  Created by Nial Giacomelli on 01/03/2013.
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

#import "NSString+Extension.h"
#import "NSDate+Extension.h"
#import "VKRSAppSoundPlayer.h"

#import "UAUI.h"
#import "UAManagedObject.h"
#import "UACoreDataController.h"
#import "UACredentials.h"

#ifndef Diabetik_UACommon_h
#define Diabetik_UACommon_h

#define kDefaultBarTintColor [UIColor whiteColor];
#define kDefaultTintColor [UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f];

// Macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Enums
enum TimeOfDay {
    Morning = 0,
    Afternoon = 1,
    Evening = 2
};

enum BGTrackingUnit {
    BGTrackingUnitMG = 0,
    BGTrackingUnitMMO = 1
};

enum {
    Everyday = 1,
    Monday = 2,
    Tuesday = 4,
    Wednesday = 8,
    Thursday = 16,
    Friday = 32,
    Saturday = 64,
    Sunday = 128
};

enum BackupFrequency {
    BackupOnClose = 0,
    BackupOnceADay = 86400, // 24 hours in seconds
    BackupOnceAWeek = 604800 // 1 week in seconds
};

typedef enum _EventFilterType {
    MedicineFilterType = 1,
    ReadingFilterType = 2,
    MealFilterType = 4,
    SnackFilterType = 8,
    ActivityFilterType = 16,
    NoteFilterType = 32
} EventFilterType;

// Constants
static NSString * const kErrorDomain = @"com.uglyapps.diabetik";

// RunKeeper
static NSString * const kRunKeeperAuthURL = @"https://runkeeper.com/apps/authorize";
static NSString * const kRunKeeperTokenURL = @"https://runkeeper.com/apps/token";
static NSString * const kRunKeeperServiceIdentifier = @"RunKeeper";

// Analytik
static NSString * const kAnalytikServiceIdentifier = @"Analytik";
static NSString * const kAnalytikAPIURL = @"http://api.analytikhq.com/api/v1/";
static NSString * const kAnalytikStagingAPIURL = @"http://api-staging.analytikhq.com/api/v1/";
static NSString * const kAnalytikLastSyncTimestampKey = @"kAnalytikLastSyncTimestampKey";
static NSString * const kAnalytikUseStagingServerKey = @"kAnalytikUseStagingServerKey";

// Notifications
static NSString * const kRemindersUpdatedNotification = @"com.uglyapps.reminders.updated";
static NSString * const kSettingsChangedNotification = @"com.uglyapps.settings.change";
static NSString * const kDropboxLinkNotification = @"com.uglyapps.dropbox.linked";
static NSString * const kRunKeeperLinkNotification = @"com.uglyapps.runkeeper.linked";
static NSString * const kRunKeeperLinkFailedNotification = @"com.uglyapps.runkeeper.link-failed";
static NSString * const kRunKeeperDidSyncNotification = @"com.uglyapps.runkeeper.sync-complete";

// NSUserDefault keys
static NSString * const kHasRunBeforeKey = @"kHasRunBefore";
static NSString * const kUseSmartInputKey = @"kUseSmartInputKey";
static NSString * const kUseSoundsKey = @"kUseSoundsKey";
static NSString * const kHasSeenStarterTooltip = @"kHasSeenStarterTooltip";
static NSString * const kHasSeenReminderTooltip = @"kHasSeenReminderTooltip";
static NSString * const kHasSeenExportTooltip = @"kHasSeenExportTooltip";
static NSString * const kHasSeenAddDragUIHint = @"kHasSeenAddDragUIHint";
static NSString * const kHasSeenInsulinCalculatorTooltip = @"kHasSeenInsulinCalculatorTooltip";
static NSString * const kFilterSearchResultsKey = @"kFilterSearchResultsKey";
static NSString * const kReportsDefaultKey = @"kReportsDefaultKey";
static NSString * const kShowInlineImages = @"kShowInlineImages";
static NSString * const kAutomaticallyGeotagEvents = @"kAutomaticallyGeotagEvents";

static NSString * const kAutomaticBackupEnabledKey = @"kAutomaticBackupEnabledKey";
static NSString * const kWWANAutomaticBackupEnabledKey = @"kWWANAutomaticBackupEnabledKey";
static NSString * const kAutomaticBackupFrequencyKey = @"kAutomaticBackupFrequencyKey";
static NSString * const kLastBackupTimestamp = @"kLastBackupTimestamp";

static NSString * const kMinHealthyBGKey = @"kMinHealthyBGKey";
static NSString * const kMaxHealthyBGKey = @"kMaxHealthyBGKey";
static NSString * const kBGTrackingUnitKey = @"kBGTrackingUnit";
static NSString * const kTargetBGKey = @"kTargetBGKey";
static NSString * const kCarbohydrateRatioKey = @"kCarbohydrateRatioKey";
static NSString * const kCorrectiveFactorKey = @"kCorrectiveFactorKey";

#endif
