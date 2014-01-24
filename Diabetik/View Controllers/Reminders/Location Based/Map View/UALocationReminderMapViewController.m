//
//  UALocationReminderMapViewController.m
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

#import "UALocationReminderMapViewController.h"
#import "MBProgressHUD.h"

@interface UALocationReminderMapViewController ()
{
    IBOutlet MKMapView *mapView;
    
    UISearchBar *searchBar;
    CLLocation *location;
    NSString *locationName;
    
    UIBarButtonItem *leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem;
    
    UISearchDisplayController *searchDisplayController;
    UALocationMapPin *pin;
    NSMutableArray *results;
}
@end

@implementation UALocationReminderMapViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNibName:@"UALocationReminderMapView" bundle:nil];
    if (self) {
        location = nil;
        locationName = nil;
        
        self.title = NSLocalizedString(@"Reminder Location", @"Title for screen showing the geographic location of a geo-fenced reminder");
        
        pin = [[UALocationMapPin alloc] init];
        results = [NSMutableArray array];
    }
    
    return self;
}
- (id)initWithLocation:(CLLocation *)theLocation andName:(NSString *)theLocationName;
{
    self = [self init];
    if (self) {
        location = theLocation;
        locationName = theLocationName;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add our search bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    [searchBar sizeToFit];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(saveLocation:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
    
    if(location)
    {
        [self positionPin:location];
    }
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    searchBar.frame = CGRectMake(0, self.topLayoutGuide.length, self.view.frame.size.width, 44.0f);
}

#pragma mark - Logic
- (void)positionPin:(CLLocation *)aLocation;
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
- (void)performReverseGeolocationWithTerm:(NSString *)term
{
    if(!term || ![term length]) return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[UALocationController sharedInstance] geocoder] geocodeAddressString:term completionHandler:^(NSArray *placemarks, NSError *error) {
        results = [NSMutableArray arrayWithArray:placemarks];
        [[searchDisplayController searchResultsTableView] reloadData];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

#pragma mark - UI
- (void)saveLocation:(id)sender
{
    if(location && locationName)
    {
        [self.delegate didSelectLocation:location withName:locationName];
        
        [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
        [self handleBack:self withSound:NO];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"Please select a valid location before continuing", @"Error message shown to users when setting up a geographical reminder")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [results count];
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAReminderCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UAReminderCell"];
    }
    
    CLPlacemark *aPlacemark = [results objectAtIndex:indexPath.row];
    if(aPlacemark)
    {
        cell.textLabel.text = [[aPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CLPlacemark *placemark = [results objectAtIndex:indexPath.row];
    if(placemark)
    {
        location = placemark.location;
        locationName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        [self positionPin:placemark.location];
        
        [searchDisplayController setActive:NO animated:YES];
    }
}

#pragma mark - UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [self performReverseGeolocationWithTerm:aSearchBar.text];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(performReverseGeolocationWithTerm:) withObject:searchText afterDelay:0.5];
}

@end
