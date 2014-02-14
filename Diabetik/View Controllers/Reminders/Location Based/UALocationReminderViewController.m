//
//  UALocationReminderViewController.m
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

#import "UAAppDelegate.h"
#import "UALocationReminderViewController.h"
#import "UALocationController.h"

@interface UALocationReminderViewController ()
{
    NSString *message;
    NSInteger trigger;
    
    BOOL currentlyDeterminingUserLocation;
    CLLocation *location;
    NSString *locationName;
}

@end

@implementation UALocationReminderViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Add Reminder", nil);

        message = @"";
        trigger = 0;
        location = nil;
        
        currentlyDeterminingUserLocation = NO;
    }
    return self;
}
- (id)initWithReminder:(UAReminder *)theReminder
{
    self = [self init];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit reminder", nil);
        self.reminder = theReminder;

        UAReminder *reminder = (UAReminder *)[self reminder];
        if(reminder)
        {
            message = reminder.message;
            trigger = [reminder.trigger integerValue];
            location = [[CLLocation alloc] initWithLatitude:[reminder.lat doubleValue] longitude:[reminder.lng doubleValue]];
            locationName = reminder.locationName;
        }
        
        currentlyDeterminingUserLocation = NO;
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![self reminder])
    {
        [self.tableView reloadData];
        
        UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.accessoryControl becomeFirstResponder];
    }
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(addReminder:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
}

#pragma mark - Logic
- (void)addReminder:(id)sender
{
    [self.view endEditing:YES];
    
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        if(message && [message length] && location && locationName)
        {
            NSError *error = nil;
            
            UAReminder *newReminder = [self reminder];
            if(!newReminder)
            {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAReminder" inManagedObjectContext:moc];
                newReminder = (UAReminder *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                newReminder.type = [NSNumber numberWithInteger:kReminderTypeLocation];            
                newReminder.created = [NSDate date];
            }
            newReminder.message = message;
            newReminder.locationName = locationName;        
            newReminder.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
            newReminder.lng = [NSNumber numberWithDouble:location.coordinate.longitude];
            newReminder.trigger = [NSNumber numberWithInteger:trigger];
            [moc save:&error];
            
            if(error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"We were unable to save your reminder for the following reason: %@", nil), [error localizedDescription]]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            else
            {
                // Setup region monitoring
                [[UALocationController sharedInstance] setupLocationMonitoringForApplicableReminders];
                
                // Notify anyone interested that we've updated our reminders
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindersUpdatedNotification object:nil];
                
                [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
                [self handleBack:self withSound:NO];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:NSLocalizedString(@"Please complete all required fields", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}
- (void)geolocateUser
{
    currentlyDeterminingUserLocation = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    [[UALocationController sharedInstance] fetchUserLocationWithSuccess:^(CLLocation *theLocation) {
        location = theLocation;
        
        [[[UALocationController sharedInstance] geocoder] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if(!error)
            {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                locationName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            }
            else
            {
                locationName = nil;
            }
            
            currentlyDeterminingUserLocation = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }];
    } failure:^(NSError *error) {
        currentlyDeterminingUserLocation = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAReminderCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UAReminderCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.font = [UAFont standardRegularFontWithSize:16.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:114.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Alert", nil);
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            textField.delegate = self;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.text = message;
            textField.placeholder = NSLocalizedString(@"Your reminder message", nil);
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.adjustsFontSizeToFitWidth = NO;
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.textAlignment = NSTextAlignmentRight;
            textField.font = [UAFont standardMediumFontWithSize:16.0f];
            textField.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            cell.accessoryView = textField;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Location", nil);
            
            if(currentlyDeterminingUserLocation)
            {
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activityIndicator startAnimating];
                cell.accessoryView = activityIndicator;
            }
            else
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
                label.backgroundColor = [UIColor clearColor];
                label.text = location ? locationName : NSLocalizedString(@"No location", nil);
                label.textAlignment = NSTextAlignmentRight;
                label.font = [UAFont standardMediumFontWithSize:16.0f];
                label.textColor = location ? [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] : [UIColor lightGrayColor];
                cell.accessoryView = label;
            }
        }
    }
    else
    {

        if(indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"On Arrival", @"On arrival to a geographic location");
            cell.accessoryType = (trigger == 0) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"On Departure", @"On departure from a geographic location");
            cell.accessoryType = (trigger == 1) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Both", nil);
            cell.accessoryType = (trigger == 2) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"Reminder details", nil);
    }
    else
    {
        return NSLocalizedString(@"When you'd like to be reminded", nil);
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    UAGenericTableHeaderView *header = [[UAGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}

#pragma mark - UITableViewDelegate reference
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 1)
        {
            [self.view endEditing:YES];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Current Location", @"Current geographic location"), NSLocalizedString(@"Search", nil), nil];
            [sheet showInView:self.view];
        }
    }
    else if(indexPath.section == 1)
    {
        trigger = indexPath.row;
        [aTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UILocationReminderMapDelegate methods
- (void)didSelectLocation:(CLLocation *)theLocation withName:(NSString *)theLocationName
{
    location = theLocation;
    locationName = theLocationName;
    
    [self.tableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        message = textField.text;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self geolocateUser];
    }
    else if(buttonIndex == 1)
    {
        UALocationReminderMapViewController *vc = nil;
        if(location && locationName)
        {
            vc = [[UALocationReminderMapViewController alloc] initWithLocation:location andName:locationName];
        }
        else
        {
            vc = [[UALocationReminderMapViewController alloc] init];
        }
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
