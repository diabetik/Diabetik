//
//  UAAccountViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 01/03/2013.
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

#import "UIImage+Resize.h"

#import "UAAccountDetailsCell.h"
#import "UAAccountViewController.h"
#import "UAMediaController.h"

#define kImageActionSheetTag 0
#define kExistingImageActionSheetTag 1

@interface UAAccountViewController ()
{
    UIImagePickerController *imagePickerController;
    NSDateFormatter *dateFormatter;
    
    NSString *currentAvatarPhotoPath;
    
    UAAccount *account;
    NSInteger gender;
    NSString *name;
    NSDate *dob;
}
@property (nonatomic, strong) NSManagedObjectContext *moc;
@end

@implementation UAAccountViewController
@synthesize moc = _moc;

#pragma mark - Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Add account", nil);
        _moc = aMOC;
        
        gender = 0;
        dob = [NSDate date];
        currentAvatarPhotoPath = nil;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    return self;
}
- (id)initWithAccount:(UAAccount *)theAccount andMOC:(NSManagedObjectContext *)aMOC
{
    self = [self initWithMOC:aMOC];
    if (self) {
        self.title = NSLocalizedString(@"Edit account", nil);
        
        account = theAccount;
        gender = [[account gender] integerValue];
        name = [account name];
        dob = [account dob];
        currentAvatarPhotoPath = [account photoPath];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconCancel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBarIconSave.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(addAccount:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
    
    if(account)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 74.0f)];
        footerView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
        UADeleteButton *deleteButton = [[UADeleteButton alloc] initWithFrame:CGRectMake(11, 15, self.tableView.frame.size.width-22.0f, 44.0f)];
        [deleteButton setTitle:NSLocalizedString(@"Delete Account", nil) forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(triggerDeleteEvent:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:deleteButton];
        
        self.tableView.tableFooterView = footerView;
    }
}

#pragma mark - Logic
- (void)addAccount:(id)sender
{
    [self.view endEditing:YES];
    
    if(name && [name length])
    {
        NSError *error = nil;
        
        if(!account)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAAccount" inManagedObjectContext:self.moc];
            account = (UAAccount *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.moc];
        }
        account.name = name;
        account.gender = [NSNumber numberWithInteger:gender];
        account.dob = dob;
        
        // Save our photo
        if(!currentAvatarPhotoPath || ![currentAvatarPhotoPath isEqualToString:account.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(account.photoPath)
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:account.photoPath success:nil failure:nil];
            }
            
            account.photoPath = currentAvatarPhotoPath;
        }
        
        [self.moc save:&error];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAccountsUpdatedNotification object:nil];
        
        if(error)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:[NSString stringWithFormat:NSLocalizedString(@"We were unable to save your account for the following reason: %@", nil), [error localizedDescription]]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
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
- (void)deleteAccount
{
    if([[[UAAccountController sharedInstance] accounts] count] > 1)
    {
        NSError *error = nil;
        
        // If the account we're trying to delete is our currently active account, try to select another
        UAAccount *newPreferredAccount = nil;
        BOOL isActiveAccount = [[[UAAccountController sharedInstance] activeAccount] isEqual:account];
        if(isActiveAccount)
        {
            for(UAAccount *existingAccount in [[UAAccountController sharedInstance] accounts])
            {
                if(![existingAccount isEqual:account])
                {
                    newPreferredAccount = existingAccount;
                    break;
                }
            }
            
            if(newPreferredAccount)
            {
                [[UAAccountController sharedInstance] setActiveAccount:newPreferredAccount];
            }
        }
        
        if(!isActiveAccount || newPreferredAccount)
        {
            [self.moc deleteObject:account];
            [self.moc save:&error];
            
            if(!error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kAccountsUpdatedNotification object:nil];
                
                [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
                [self handleBack:self withSound:NO];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"There was an error while trying to delete this account: %@", nil), [error localizedDescription]]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                message:NSLocalizedString(@"There was an error while trying to establish the new default account", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                            message:NSLocalizedString(@"This is your only account. Please create another before trying to delete this one", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UI
- (void)changeDOB:(UIDatePicker *)sender
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UAInputLabel *inputLabel = (UAInputLabel *)[cell accessoryControl];
    
    dob = [sender date];
    [inputLabel setText:[dateFormatter stringFromDate:dob]];
}
- (void)changeAvatar:(id)sender
{
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = nil;
    if(currentAvatarPhotoPath)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Delete photo", nil)
                                         otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
        actionSheet.tag = kExistingImageActionSheetTag;
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
        actionSheet.tag = kImageActionSheetTag;
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)changeGender:(UISegmentedControl *)sender
{
    gender = [sender selectedSegmentIndex];
}
- (void)triggerDeleteEvent:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Account", nil)
                                                        message:NSLocalizedString(@"Are you sure you'd like to delete this account? All associated entries will be permanently deleted", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alertView.tag = 99;
    [alertView show];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 80.0f;
    }
    
    return 45.0f;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = nil;
    if(indexPath.row == 0)
    {
        cell = (UAAccountDetailsCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAAccountDetailsCell"];
        if (cell == nil)
        {
            cell = [[UAAccountDetailsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UAAccountDetailsCell"];
        }
    }
    else
    {
        cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAAccountCell"];
        if (cell == nil)
        {
            cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UAAccountCell"];
        }
    }
    [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            UAAccountDetailsCell *detailsCell = (UAAccountDetailsCell *)cell;
            
            UIImage *avatar = [[UAMediaController sharedInstance] imageWithFilename:currentAvatarPhotoPath];
            [detailsCell.avatarButton setImage:avatar forState:UIControlStateNormal];
            [detailsCell.avatarButton addTarget:self action:@selector(changeAvatar:) forControlEvents:UIControlEventTouchUpInside];
            detailsCell.nameTextField.text = name;
            detailsCell.nameTextField.delegate = self;
            detailsCell.metadataLabel.text = [NSString stringWithFormat:@"%d %@", account ? account.events.count : 0, NSLocalizedString(@"entries in total", @"Used as part of a label that tallies the total number of entries entered by a user, i.e: x entries in total")];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Gender", nil);
            
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Male", @"Gender selector switch"), NSLocalizedString(@"Female", @"Gender selector switch")]];
            segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
            [segmentedControl addTarget:self action:@selector(changeGender:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = segmentedControl;
            
            [segmentedControl setSelectedSegmentIndex:gender];
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"D.O.B.", @"Abbreviation for Date of Birth");
            
            UAInputLabel *inputLabel = [[UAInputLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
            inputLabel.text = [dateFormatter stringFromDate:dob];
            inputLabel.textAlignment = NSTextAlignmentRight;
            inputLabel.delegate = self;
            inputLabel.font = [UAFont standardDemiBoldFontWithSize:16.0f];
            inputLabel.textColor = [UIColor colorWithRed:114.0f/255.0f green:118.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
            cell.accessoryView = inputLabel;
            
            UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
            [datePicker setDate:dob];
            [datePicker setDatePickerMode:UIDatePickerModeDate];
            [datePicker addTarget:self action:@selector(changeDOB:) forControlEvents:UIControlEventValueChanged];
            inputLabel.inputView = datePicker;
        }
    }
        
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self deleteAccount];
    }
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
    if(indexPath.row == 0)
    {
        name = textField.text;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(!imagePickerController)
    {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.allowsEditing = YES;
        imagePickerController.delegate = self;
    }
    
    if(actionSheet.tag == kExistingImageActionSheetTag)
    {
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            currentAvatarPhotoPath = nil;
            
            UAAccountDetailsCell *cell = (UAAccountDetailsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell.avatarButton setImage:nil forState:UIControlStateNormal];
            
            return;
        }
        else
        {
            buttonIndex -= 1;
        }
    }
    
    if(buttonIndex == 0)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if(buttonIndex == 1)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    if(buttonIndex < 2)
    {
        [self.navigationController presentViewController:imagePickerController animated:YES completion:^{
            // STUB
        }];
    }
}

#pragma mark - UAInputLabelDelegate
- (void)inputLabelDidBeginEditing:(UAInputLabel *)inputLabel
{
    UIDatePicker *datePicker = (UIDatePicker *)inputLabel.inputView;
    [datePicker setDate:dob];
}

#pragma mark - UIImagePickerControllerDelegate
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
        // Resize our image to make sure it'll load nice and quickly
        image = [image resizedImageToFitInSize:CGSizeMake(100, 100) scaleIfSmaller:YES];
        
        NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
        NSString *filename = [NSString stringWithFormat:@"%d", (NSInteger)timestamp];
        [[UAMediaController sharedInstance] saveImage:image withFilename:filename success:^{
            
            // Remove any existing photo (provided it's not our original photo)
            if(currentAvatarPhotoPath && (!account || (account && ![account.photoPath isEqualToString:currentAvatarPhotoPath])))
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:currentAvatarPhotoPath success:nil failure:nil];
            }
            
            currentAvatarPhotoPath = filename;
            
            UAAccountDetailsCell *cell = (UAAccountDetailsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell.avatarButton setImage:image forState:UIControlStateNormal];
            
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            NSLog(@"Image failed with filename: %@. Error: %@", filename, error);
        }];
    }
}

@end
