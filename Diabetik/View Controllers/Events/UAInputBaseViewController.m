//
//  UAInputBaseViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 21/04/2013.
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
        self.currentPhotoPath = nil;
        self.lat = nil, self.lon = nil;
        self.date = [NSDate date];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeShown:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardDidHideNotification object:nil];
        
        self.autocompleteBar = [[UAAutocompleteBar alloc] initWithFrame:CGRectMake(0, 0, 235, 44)];
        self.autocompleteBar.showTagButton = NO;
        self.autocompleteBar.delegate = self;
        self.autocompleteTagBar = [[UAAutocompleteBar alloc] initWithFrame:CGRectMake(0, 0, 235, 44)];
        self.autocompleteTagBar.showTagButton = YES;
        self.autocompleteTagBar.delegate = self;
        
        dummyNotesTextView = [[UANotesTextView alloc] initWithFrame:CGRectZero];
        dummyNotesTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dummyNotesTextView.scrollEnabled = NO;
        dummyNotesTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        dummyNotesTextView.autocorrectionType = UITextAutocorrectionTypeYes;
        dummyNotesTextView.font = [UAFont standardMediumFontWithSize:16.0f];
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
    
    BOOL editMode = self.event ? NO : YES;
    if(!isFirstLoad)
    {
        editMode = NO;
    }
    
    [self didBecomeActive:editMode];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, kAccessoryViewHeight, 0.0f);
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, kAccessoryViewHeight, 0.0f);
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
    [self.view endEditing:YES];
    
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
        if([parentVC.viewControllers count] == 1)
        {
            [self handleBack:self withSound:NO];
        }
        else
        {
            [parentVC removeVC:self];
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

#pragma mark - UI
- (void)didBecomeActive:(BOOL)editing
{
    [parentVC updateKeyboardButtons];
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // Select our first input field
    if(editing)
    {
        [cell.control becomeFirstResponder];
    }

    self.previouslyActiveControlIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}
- (void)willBecomeInactive
{
    isFirstLoad = NO;
    [self finishEditing:self];
}
- (void)finishEditing:(id)sender
{
    [self.view endEditing:YES];
}
- (void)nextField:(UITextField *)sender
{
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag+1 inSection:0]];
    [cell.control becomeFirstResponder];
}
- (UIColor *)barTintColor
{
    return [UIColor greenColor];
}

#pragma mark - Social helpers
- (NSString *)facebookSocialMessageText
{
    return NSLocalizedString(@"I love Diabetik! It's a great way to track my diabetes.", nil);
}
- (NSString *)twitterSocialMessageText
{
    return NSLocalizedString(@"I love @diabetikapp! It's a great way to track my diabetes.", nil);
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
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textView.tag inSection:0];
    
    [textView reloadInputViews];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.activeControlIndexPath = nil;
    self.previouslyActiveControlIndexPath = [NSIndexPath indexPathForRow:textView.tag inSection:0];
}
- (void)textViewDidChange:(UITextView *)textView
{
    // Determine whether we're current in tag 'edit mode'
    NSUInteger caretLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
    NSRange range = [[UATagController sharedInstance] rangeOfTagInString:textView.text withCaretLocation:caretLocation];
    if(range.location != NSNotFound)
    {
        NSString *currentTag = [textView.text substringWithRange:range];
        currentTag = [currentTag substringFromIndex:1];
        [self.autocompleteTagBar showSuggestionsForInput:currentTag];
    }
    else
    {
        [self.autocompleteTagBar showSuggestionsForInput:nil];
    }
    
    // Update values
    notes = textView.text;
    
    // Finally, update our tableview
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    //textViewHeight = [textView height];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeControlIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [textField reloadInputViews];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.previouslyActiveControlIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    self.activeControlIndexPath = nil;
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
}
- (void)addTagCaret
{
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    if(!cell)
    {
        [self.tableView scrollToRowAtIndexPath:self.activeControlIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:self.activeControlIndexPath];
    
    UITextField *activeTextField = (UITextField *)cell.control;
    activeTextField.text = [activeTextField.text stringByAppendingString:@"#"];
}

#pragma mark - Metadata management
- (void)requestCurrentLocation
{    
    parentVC.locationButton.titleLabel.alpha = 0.0f;
    parentVC.locationButton.imageView.alpha = 0.0f;
    [parentVC.locationButton.activityIndicatorView startAnimating];
    
    [[UALocationController sharedInstance] fetchUserLocationWithSuccess:^(CLLocation *location) {
        self.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        self.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
        
        [parentVC updateKeyboardButtons];
        [parentVC.locationButton.activityIndicatorView stopAnimating];
        parentVC.locationButton.titleLabel.alpha = 1.0f;
        parentVC.locationButton.imageView.alpha = 1.0f;
        
    } failure:^(NSError *error) {
        [parentVC.locationButton.activityIndicatorView stopAnimating];
        parentVC.locationButton.titleLabel.alpha = 1.0f;
        parentVC.locationButton.imageView.alpha = 1.0f;
    }];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    self.lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    
    [manager stopUpdatingLocation];
    [parentVC updateKeyboardButtons];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}

#pragma mark - UIAlertViewDelegate
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

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kGeotagActionSheetTag)
    {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            self.lat = nil, self.lon = nil;
            self.event.lat = nil, self.event.lon = nil;
            
            [parentVC updateKeyboardButtons];
        }
        else if(buttonIndex == 1)
        {
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
        if(!imagePickerController)
        {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        if(actionSheet.tag == kExistingImageActionSheetTag)
        {
            if(buttonIndex == actionSheet.destructiveButtonIndex)
            {
                self.event.photoPath = nil, self.currentPhotoPath = nil;
                
                [parentVC updateKeyboardButtons];
            }
            else if(buttonIndex == 1)
            {
                UIImage *image = [[UAMediaController sharedInstance] imageWithFilename:self.currentPhotoPath];
                if(image)
                {
                    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:image];
                    viewController.transitioningDelegate = self;
                    
                    [self presentViewController:viewController animated:YES completion:nil];
                }
            }
            else if(buttonIndex == 2)
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else if(buttonIndex == 3)
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            if(buttonIndex == 2 || buttonIndex == 3)
            {
                [self.navigationController presentViewController:imagePickerController animated:YES completion:^{
                    // STUB
                }];
            }
        }
        else
        {
            if(buttonIndex == 0)
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else if(buttonIndex == 1)
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            if(buttonIndex != actionSheet.cancelButtonIndex)
            {
                [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
            }
        }
    }
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        
        UIImageView *imageView = [[(UAInputParentViewController *)self.parentViewController photoButton] fullsizeImageView];
        
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        
        UIImageView *imageView = [[(UAInputParentViewController *)self.parentViewController photoButton] fullsizeImageView];
        
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imageView];
    }
    return nil;
}


#pragma mark - UINavigationControllerDelegate methods
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        //[[UIApplication sharedApplication] setStatusBarHidden:NO];
        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!image)
    {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if(!image)
    {
        image = [info objectForKey:UIImagePickerControllerCropRect];
    }
    
    if(image)
    {
        NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
        NSString *filename = [NSString stringWithFormat:@"%d", (NSInteger)timestamp];
        
        __weak typeof(self) weakSelf = self;
        [[UAMediaController sharedInstance] saveImage:image withFilename:filename success:^{
            
            // Remove any existing photo (provided it's not our original photo)
            if(weakSelf.currentPhotoPath && (!weakSelf.event || (weakSelf.event && ![weakSelf.event.photoPath isEqualToString:weakSelf.currentPhotoPath])))
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:weakSelf.currentPhotoPath success:nil failure:nil];
            }
            
            weakSelf.currentPhotoPath = filename;
            
            [parentVC updateKeyboardButtons];
            
        } failure:^(NSError *error) {
            NSLog(@"Image failed with filename: %@. Error: %@", filename, error);
        }];
    }
}

#pragma mark - Notifications
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // STUB
}
- (void)keyboardWillBeShown:(NSNotification *)aNotification
{
    [parentVC.keyboardBackingView setKeyboardState:kKeyboardShown];
}
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [parentVC.keyboardBackingView setKeyboardState:kKeyboardHidden];
}
- (void)keyboardWasHidden:(NSNotification *)aNotification
{
    // STUB
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

#pragma mark - UINavigationControllerDelegate methods
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    parentVC = (UAInputParentViewController *)parent;
}

@end
