//
//  UAInputBaseViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 21/04/2013.
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

#import "UAInputBaseViewController.h"
#import "UALocationController.h"
#import "UAEventMapViewController.h"

@implementation UAInputBaseViewController
@synthesize event = _event;

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        usingSmartInput = NO;
        self.activeView = NO;
        self.activeControlIndexPath = nil;
        self.currentPhotoPath = nil;
        self.lat = nil, self.lon = nil;
        self.date = [NSDate date];
        self.view.tintColor = [self tintColor];
        
        dummyNotesTextView = [[UAEventNotesTextView alloc] initWithFrame:CGRectZero];
        dummyNotesTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dummyNotesTextView.scrollEnabled = NO;
        dummyNotesTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        dummyNotesTextView.autocorrectionType = UITextAutocorrectionTypeYes;
        dummyNotesTextView.font = [UAFont standardMediumFontWithSize:16.0f];
        
        // If we've been asked to automatically geotag events, kick that off here
        if([[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticallyGeotagEvents])
        {
            [self requestCurrentLocation];
        }
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)theEvent
{
    self = [self init];
    if(self)
    {
        self.event = theEvent;
        
        self.date = self.event.timestamp;
        notes = self.event.notes;
        self.currentPhotoPath = self.event.photoPath;
        self.lat = self.event.lat;
        self.lon = self.event.lon;
    }
    
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView = [[UITableView alloc] initWithFrame:baseView.frame style:tableStyle];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithRed:10.0f/255.0f green:10.0f/255.0f blue:10.0f/255.0f alpha:0.12f];
    
    [baseView addSubview:self.tableView];
    
    self.view = baseView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [self.tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
   
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Logic
- (NSError *)validationError
{
    return nil;
}
- (UAEvent *)saveEvent:(NSError **)error
{
    return nil;
}
- (void)discardChanges
{
    // Remove any existing photo (provided it's not our original photo)
    if(self.currentPhotoPath && (!self.event || (self.event && ![self.event.photoPath isEqualToString:self.currentPhotoPath])))
    {
        [[UAMediaController sharedInstance] deleteImageWithFilename:self.currentPhotoPath success:nil failure:nil];
    }
}
- (void)triggerDeleteEvent:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Entry", nil)
                                                        message:NSLocalizedString(@"Are you sure you'd like to permanently delete this entry?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alertView.tag = kDeleteAlertViewTag;
    [alertView show];
}
- (void)deleteEvent
{
    NSError *error = nil;
    
    UAEvent *event = [self event];
    if(event)
    {
        NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            [moc deleteObject:event];
            [moc save:&error];
        }
        else
        {
            error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    if(!error)
    {
        [self discardChanges];
    
        [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
        if([self.parentVC.viewControllers count] == 1)
        {
            [self handleBack:self withSound:NO];
        }
        else
        {
            [self.parentVC removeVC:self];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"There was an error while trying to delete this event: %@", nil), [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)updateKeyboardShortcutButtons
{
    [self.keyboardShortcutAccessoryView.tagButton setEnabled:NO];
    if(self.activeControlIndexPath)
    {
        UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
        if([cell.control isKindOfClass:[UAEventNotesTextView class]])
        {
            [self.keyboardShortcutAccessoryView.tagButton setEnabled:YES];
        }
    }
    
    if((self.event && [self.event.lat doubleValue] != 0.0 && [self.event.lon doubleValue] != 0.0) || ([self.lat doubleValue] != 0.0 && [self.lon doubleValue] != 0.0))
    {
        [self.keyboardShortcutAccessoryView.locationButton setImage:[UIImage imageNamed:@"KeyboardShortcutLocationActiveIcon"] forState:UIControlStateNormal];
    }
    else
    {
        [self.keyboardShortcutAccessoryView.locationButton setImage:[UIImage imageNamed:@"KeyboardShortcutLocationIcon"] forState:UIControlStateNormal];
    }

    if(self.currentPhotoPath)
    {
        UIImage *photo = [[UAMediaController sharedInstance] imageWithFilename:self.currentPhotoPath];
        self.keyboardShortcutAccessoryView.photoButton.fullsizeImageView.image = photo;
    }
    else
    {
        self.keyboardShortcutAccessoryView.photoButton.fullsizeImageView.image = nil;
    }
}

#pragma mark - Photograph logic
- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType fromView:(UIView *)view
{
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        if(!imagePickerController)
        {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
        }
        imagePickerController.sourceType = sourceType;
        
        if (imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            CGRect r = [self.parentVC.view convertRect:CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 1.0f, 1.0f) fromView:view];
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
            [popover setDelegate:self.parentVC];
            
            self.parentVC.popoverVC = popover;
            [popover presentPopoverFromRect:r inView:self.parentVC.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
        else
        {
            [self.parentViewController presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(!image) image = [info objectForKey:UIImagePickerControllerCropRect];
    
    if(image)
    {
        NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
        NSString *filename = [NSString stringWithFormat:@"%ld", (long)timestamp];
        
        __weak typeof(self) weakSelf = self;
        [[UAMediaController sharedInstance] saveImage:image withFilename:filename success:^{
            
            // Remove any existing photo (provided it's not our original photo)
            if(weakSelf.currentPhotoPath && (!weakSelf.event || (weakSelf.event && ![weakSelf.event.photoPath isEqualToString:weakSelf.currentPhotoPath])))
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:weakSelf.currentPhotoPath success:nil failure:nil];
            }
            
            weakSelf.currentPhotoPath = filename;
            [self updateKeyboardShortcutButtons];
            
        } failure:^(NSError *error) {
            NSLog(@"Image failed with filename: %@. Error: %@", filename, error);
        }];
        
        if (imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self.parentVC closeActivePopoverController];
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.parentVC closeActivePopoverController];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UI
- (void)didBecomeActive
{
    [self updateKeyboardShortcutButtons];
    
    if(!self.activeControlIndexPath)
    {
        self.activeControlIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    [cell.control becomeFirstResponder];
    
    self.activeView = YES;
}
- (void)willBecomeInactive
{
    isFirstLoad = NO;
    [self finishEditing:self];
    
    self.activeView = NO;
}
- (void)finishEditing:(id)sender
{
    [self.view endEditing:YES];
}
- (UIColor *)tintColor
{
    return nil;
}
- (UIImage *)navigationBarBackgroundImage
{
    return nil;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if([cell respondsToSelector:@selector(control)])
    {
        [cell.control becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.keyboardShortcutAccessoryView.autocompleteBar.shouldFetchSuggestions = YES;
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textView.tag inSection:0];
    
    [textView reloadInputViews];
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    [self updateKeyboardShortcutButtons];
}
- (void)textViewDidChange:(UITextView *)textView
{
    // Determine whether we're currently in tag 'edit mode'
    NSUInteger caretLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
    NSRange range = [[UATagController sharedInstance] rangeOfTagInString:textView.text withCaretLocation:caretLocation];
    if(range.location != NSNotFound)
    {
        NSString *currentTag = [textView.text substringWithRange:range];
        currentTag = [currentTag substringFromIndex:1];
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:currentTag];
    }
    else
    {
        [[self keyboardShortcutAccessoryView] setShowingAutocompleteBar:NO];
    }
    
    // Update values
    notes = textView.text;
    
    // Finally, update our tableview
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.keyboardShortcutAccessoryView.autocompleteBar.shouldFetchSuggestions = YES;
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    
    [textField reloadInputViews];
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    [self updateKeyboardShortcutButtons];
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)autocompleteBar
{
    return nil;
}
- (void)autocompleteBar:(UAAutocompleteBar *)autocompleteBar didSelectSuggestion:(NSString *)suggestion
{
    [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    if([cell.control isKindOfClass:[UITextField class]])
    {
        UITextField *activeTextField = (UITextField *)cell.control;
        activeTextField.text = suggestion;
    }
    else if([cell.control isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)cell.control;
        
        NSUInteger caretLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
        NSRange range = [[UATagController sharedInstance] rangeOfTagInString:textView.text withCaretLocation:caretLocation];
        if(range.location != NSNotFound)
        {
            // Only pad our new tag with a space if it's not the end of our note and there isn't already a space following it
            if(range.location + range.length >= textView.text.length || [[textView.text substringWithRange:NSMakeRange(range.location+range.length, 1)] isEqualToString:@" "])
            {
                textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location+1, range.length-1) withString:suggestion];
            }
            else
            {
                textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location+1, range.length-1) withString:[NSString stringWithFormat:@"%@ ", suggestion]];
            }
            
            //textViewHeight = textView.intrinsicContentSize.height;
            notes = textView.text;
            
            //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
}
- (void)presentTagOptions:(id)sender
{
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    if(!cell)
    {
        [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    if([cell.control isKindOfClass:[UAEventNotesTextView class]])
    {
        UAEventNotesTextView *activeTextField = (UAEventNotesTextView *)cell.control;
        activeTextField.text = [activeTextField.text stringByAppendingString:@"#"];
    }
}

#pragma mark - Metadata management
- (void)requestCurrentLocation
{
    [self.keyboardShortcutAccessoryView.locationButton showActivityIndicator:YES];
    
    __weak __typeof(self)weakSelf = self;
    [[UALocationController sharedInstance] fetchUserLocationWithSuccess:^(CLLocation *location) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        strongSelf.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        
        [strongSelf updateKeyboardShortcutButtons];
        [strongSelf.keyboardShortcutAccessoryView.locationButton showActivityIndicator:NO];
        
    } failure:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf.keyboardShortcutAccessoryView.locationButton showActivityIndicator:NO];
    }];
}

#pragma mark - Accessors
- (UAEvent *)event
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(!moc) return nil;
    if(!self.eventOID) return nil;
    
    NSError *error = nil;
    UAEvent *event = (UAEvent *)[moc existingObjectWithID:self.eventOID error:&error];
    if (!event)
    {
        self.eventOID = nil;
    }
    
    return event;
}
- (void)setEvent:(UAEvent *)theEvent
{
    NSError *error = nil;
    if(theEvent.objectID.isTemporaryID && ![theEvent.managedObjectContext obtainPermanentIDsForObjects:@[theEvent] error:&error])
    {
        self.eventOID = nil;
    }
    else
    {
        self.eventOID = theEvent.objectID;
    }
}
- (UAKeyboardShortcutAccessoryView *)keyboardShortcutAccessoryView
{
    if(!_keyboardShortcutAccessoryView)
    {
        _keyboardShortcutAccessoryView = [[UAKeyboardShortcutAccessoryView alloc] initWithFrame:CGRectZero];
        _keyboardShortcutAccessoryView.delegate = self;
    }
    
    return _keyboardShortcutAccessoryView;
}

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    self.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    
    [manager stopUpdatingLocation];
    [self updateKeyboardShortcutButtons];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kDeleteAlertViewTag && buttonIndex == 1)
    {
        [self deleteEvent];
    }
    else if(alertView.tag == kGeoTagAlertViewTag && buttonIndex == 1)
    {
        [self requestCurrentLocation];
    }
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kGeotagActionSheetTag)
    {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            self.lat = nil, self.lon = nil;
            self.event.lat = nil, self.event.lon = nil;
            
            [self updateKeyboardShortcutButtons];
        }
        else if(buttonIndex == 1)
        {
            [self.view endEditing:YES];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lon doubleValue]];
            UAEventMapViewController *vc = [[UAEventMapViewController alloc] initWithLocation:location];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(buttonIndex == 2)
        {
            [self requestCurrentLocation];
        }
    }
    else
    {
        if(actionSheet.tag == kExistingImageActionSheetTag)
        {
            if(buttonIndex == actionSheet.destructiveButtonIndex)
            {
                self.event.photoPath = nil, self.currentPhotoPath = nil;
                
                [self updateKeyboardShortcutButtons];
            }
            else if(buttonIndex == 1)
            {
                [self.view endEditing:YES];
                
                UIImage *image = [[UAMediaController sharedInstance] imageWithFilename:self.currentPhotoPath];
                if(image)
                {
                    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:image];
                    viewController.transitioningDelegate = self;
                    
                    [self presentViewController:viewController animated:YES completion:nil];
                }
            }
        }
        else
        {
            if(buttonIndex != actionSheet.cancelButtonIndex && buttonIndex != actionSheet.destructiveButtonIndex)
            {
                if(buttonIndex == 0)
                {
                    [self.view endEditing:YES];
                }
            }
            
            if(buttonIndex == 0)
            {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera fromView:[self.keyboardShortcutAccessoryView photoButton]];
            }
            else if(buttonIndex == 1)
            {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromView:[self.keyboardShortcutAccessoryView photoButton]];
            }
        }
    }
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class])
    {
        UIImageView *imageView = [[self.keyboardShortcutAccessoryView photoButton] fullsizeImageView];
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:TGRImageViewController.class])
    {
        UIImageView *imageView = [[self.keyboardShortcutAccessoryView photoButton] fullsizeImageView];
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}

#pragma mark - UIKeyboardShortcutDelegate methods
- (void)keyboardShortcut:(UAKeyboardShortcutAccessoryView *)shortcutView didPressButton:(UAKeyboardShortcutButton *)button
{
    if([button isEqual:[shortcutView locationButton]])
    {
        [(UAInputParentViewController *)self.parentViewController presentGeotagOptions:button];
    }
    else if([button isEqual:[shortcutView deleteButton]])
    {
        [self triggerDeleteEvent:button];
    }
    else if([button isEqual:[shortcutView photoButton]])
    {
        [(UAInputParentViewController *)self.parentViewController presentMediaOptions:button];
    }
    else if([button isEqual:[shortcutView reminderButton]])
    {
        [(UAInputParentViewController *)self.parentViewController presentAddReminder:button];
    }
    else if([button isEqual:[shortcutView tagButton]])
    {
        [self presentTagOptions:button];
    }
}

#pragma mark - UINavigationControllerDelegate methods
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    self.parentVC = (UAInputParentViewController *)parent;
    if(parent && self.activeView)
    {
        [self didBecomeActive];
    }
}

@end
