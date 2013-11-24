//
//  UAInputBaseViewController.h
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

#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

#import "UABaseViewController.h"
#import "UAInputParentViewController.h"
#import "UAUI.h"

#import "UAAccountController.h"
#import "UAEventController.h"
#import "UATagController.h"
#import "UAMediaController.h"

#import "UAEventInputViewCell.h"
#import "UAEvent.h"

#define kImageActionSheetTag 0
#define kExistingImageActionSheetTag 1
#define kGeotagActionSheetTag 2
#define kReminderActionSheetTag 3

#define kDeleteAlertViewTag 0
#define kGeoTagAlertViewTag 1

@class UAInputParentViewController;
@interface UAInputBaseViewController : UABaseTableViewController <CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UAAutocompleteBarDelegate, UIViewControllerTransitioningDelegate>
{
@protected
    UAInputParentViewController *parentVC;
    UIImagePickerController *imagePickerController;
    NSDateFormatter *dateFormatter;
    NSString *notes;
    
    CGFloat textViewHeight;
    BOOL usingSmartInput;
}
@property (nonatomic, retain) UAEvent *event;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UAAutocompleteBar *autocompleteBar;
@property (nonatomic, strong) UAAutocompleteBar *autocompleteTagBar;

@property (nonatomic, strong) NSString *currentPhotoPath;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) UIView *previouslyActiveField;

// Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC;
- (id)initWithEvent:(UAEvent *)aEvent andMOC:(NSManagedObjectContext *)aMOC;

// Logic
- (void)didBecomeActive:(BOOL)editing;
- (void)willBecomeInactive;
- (void)discardChanges;
- (NSError *)validationError;
- (UAEvent *)saveEvent:(NSError **)error;

// UI
- (void)triggerDeleteEvent:(id)sender;
- (UIColor *)barTintColor;

// Metadata
- (void)requestCurrentLocation;

// Social helpers
- (NSString *)facebookSocialMessageText;
- (NSString *)twitterSocialMessageText;

@end
