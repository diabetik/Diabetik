//
//  UALocationController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 04/03/2013.
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

#import "UALocationController.h"

@interface UALocationController ()
{
    BOOL isFetchingUserLocation;
    
    NSTimer *locationFetchTimer;
    CLLocation *lastLocation;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UACurrentLocationSuccessCallback currentLocationSuccessCallback;
@property (nonatomic, strong) UACurrentLocationFailureCallback currentLocationFailureCallback;

- (void)locationFetchTimerTick;
@end

@implementation UALocationController
@synthesize locationManager = _locationManager;
@synthesize geocoder = _geocoder;
@synthesize currentLocationSuccessCallback = _currentLocationSuccessCallback;
@synthesize currentLocationFailureCallback = _currentLocationFailureCallback;

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        lastLocation = nil;
        locationFetchTimer = nil;
        isFetchingUserLocation = NO;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof (weakSelf) strongSelf = weakSelf;
            
            strongSelf.geocoder = [[CLGeocoder alloc] init];
            
            strongSelf.locationManager = [[CLLocationManager alloc] init];
            strongSelf.locationManager.delegate = strongSelf;
            strongSelf.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        });
    }
    
    return self;
}

#pragma mark - Logic
- (void)fetchUserLocationWithSuccess:(UACurrentLocationSuccessCallback)successCallback failure:(UACurrentLocationFailureCallback)failureCallback
{
    isFetchingUserLocation = YES;
    lastLocation = nil;
    
    if(locationFetchTimer)
    {
        [locationFetchTimer invalidate], locationFetchTimer = nil;
    }
    locationFetchTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(locationFetchTimerTick) userInfo:nil repeats:NO];
    
    self.currentLocationSuccessCallback = successCallback;
    self.currentLocationFailureCallback = failureCallback;
    
    [self.locationManager startUpdatingLocation];
}
- (void)setupLocationMonitoringForApplicableReminders
{
    // Stop monitoring all regions
    for(CLRegion *region in self.locationManager.monitoredRegions)
    {
        [self.locationManager stopMonitoringForRegion:region];
    }
    
    NSArray *reminders = [[UAReminderController sharedInstance] fetchAllReminders];
    NSMutableArray *newRegions = [NSMutableArray array];
    for(UAReminder *reminder in [reminders objectAtIndex:kReminderTypeLocation])
    {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[reminder.lat doubleValue] longitude:[reminder.lng doubleValue]];

        BOOL regionAlreadyMonitored = NO;
        for(CLCircularRegion *region in newRegions)
        {
            if([region containsCoordinate:location.coordinate])
            {
                regionAlreadyMonitored = YES;
                break;
            }
        }
        
        if(!regionAlreadyMonitored)
        {
            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:150 identifier:reminder.guid];
            [self.locationManager startMonitoringForRegion:region];
            [newRegions addObject:region];
        }
    }
}
- (void)locationFetchTimerTick
{
    if(isFetchingUserLocation)
    {
        isFetchingUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
        
        if(lastLocation)
        {
            self.currentLocationSuccessCallback(lastLocation);
        }
        else
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:NSLocalizedString(@"Unable to determine location", @"Error message shown when a users current geographic location cannot be determined") forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
            
            self.currentLocationFailureCallback(error);
        }
        self.currentLocationSuccessCallback = nil;
        self.currentLocationFailureCallback = nil;
    }
}

#pragma mark - CLLocationsManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = (CLLocation *)[locations lastObject];
    
    // Make sure this location data isn't cached
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    // Test that horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    
    if (lastLocation == nil || lastLocation.horizontalAccuracy >= newLocation.horizontalAccuracy)
    {
        lastLocation = newLocation;
        
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy)
        {
            [self.locationManager stopUpdatingLocation];
            
            if(isFetchingUserLocation)
            {
                isFetchingUserLocation = NO;
                
                [locationFetchTimer invalidate], locationFetchTimer = nil;
                
                self.currentLocationSuccessCallback(newLocation);
                self.currentLocationSuccessCallback = nil;
                self.currentLocationFailureCallback = nil;
            }
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    
    if(isFetchingUserLocation)
    {
        isFetchingUserLocation = NO;
        
        self.currentLocationFailureCallback(error);
        self.currentLocationFailureCallback = nil;
    }
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLCircularRegion *)region
{
    NSArray *reminders = [[UAReminderController sharedInstance] fetchAllReminders];
    for(UAReminder *reminder in [reminders objectAtIndex:kReminderTypeLocation])
    {
        if([reminder.trigger integerValue] == kReminderTriggerBoth || [reminder.trigger integerValue] == kReminderTriggerArriving)
        {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([reminder.lat doubleValue], [reminder.lng doubleValue]);
            if([region containsCoordinate:coord])
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate date];
                notification.alertBody = reminder.message;
                notification.soundName = @"notification.caf";
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.userInfo = @{@"ID": reminder.guid, @"type": reminder.type};
                
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLCircularRegion *)region
{
    NSArray *reminders = [[UAReminderController sharedInstance] fetchAllReminders];
    for(UAReminder *reminder in [reminders objectAtIndex:kReminderTypeLocation])
    {
        if([reminder.trigger integerValue] == kReminderTriggerBoth || [reminder.trigger integerValue] == kReminderTriggerDeparting)
        {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([reminder.lat doubleValue], [reminder.lng doubleValue]);
            if([region containsCoordinate:coord])
            {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate date];
                notification.alertBody = reminder.message;
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.soundName = @"notification.caf";
                notification.userInfo = @{@"ID": reminder.guid, @"type": reminder.type};
                
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
}

@end
