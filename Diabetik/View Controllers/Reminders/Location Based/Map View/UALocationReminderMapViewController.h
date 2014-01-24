//
//  UALocationReminderMapViewController.h
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "UAUI.h"
#import "UALocationMapPin.h"
#import "UALocationController.h"

@protocol UALocationReminderMapDelegate <NSObject>
@required
- (void)didSelectLocation:(CLLocation *)location withName:(NSString *)name;
@end

@interface UALocationReminderMapViewController : UABaseViewController <UISearchBarDelegate, MKMapViewDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) id<UALocationReminderMapDelegate> delegate;

// Setup
- (id)initWithLocation:(CLLocation *)theLocation andName:(NSString *)theLocationName;

// Logic
- (void)performReverseGeolocationWithTerm:(NSString *)term;

@end
