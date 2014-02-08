//
//  UAEventMapViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 06/04/2013.
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

#import "UAEventMapViewController.h"

@interface UAEventMapViewController ()
{
    MKMapView *mapView;
    UAEventMapPin *pin;
    
    CLLocation *location;
}
@end

@implementation UAEventMapViewController

#pragma mark - Setup
- (id)initWithLocation:(CLLocation *)theLocation
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        self.title = NSLocalizedString(@"Event Location", @"Geo-location of event");
        location = theLocation;
        pin = [[UAEventMapPin alloc] init];
    }
    
    return self;
}
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    mapView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:mapView];
    
    self.view = view;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mapView.frame = self.view.frame;
    [self positionPin:location];
    
    UIColor *tintColor = kDefaultTintColor;
    [self.navigationController.navigationBar setTintColor:tintColor];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UAFont standardDemiBoldFontWithSize:17.0f]}];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    mapView.frame = self.view.bounds;
}

#pragma mark - Logic
- (void)positionPin:(CLLocation *)aLocation
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = aLocation.coordinate.latitude;
    newRegion.center.longitude = aLocation.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.005;
    newRegion.span.longitudeDelta = 0.005;
    
    pin.coordinate = aLocation.coordinate;
    [mapView setRegion:newRegion animated:YES];
    [mapView addAnnotation:pin];
}

@end
