//
//  UACoreDataController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 12/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UACoreDataController.h"

@interface UACoreDataController ()
{
    UIAlertView *cloudContentCorruptedAlert;
    UIAlertView *cloudContentHealingAlert;
    UIAlertView *handleCloudContentWarningAlert;
    UIAlertView *handleLocalStoreAlert;
    
    UIAlertView *iCloudEnabledAlertView;
    UIAlertView *iCloudDisabledAlertView;
}
@property (copy, nonatomic) void(^iCloudConfirmationBlock)(BOOL);

// Helpers
- (NSURL *)persistentStoreURL;
- (NSURL *)applicationDocumentsDirectory;

@end

@implementation UACoreDataController

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
        self.ubiquityStoreManager = [[UbiquityStoreManager alloc] initStoreNamed:@"Diabetik"
                                                          withManagedObjectModel:nil
                                                                   localStoreURL:[self persistentStoreURL]
                                                             containerIdentifier:nil
                                                          additionalStoreOptions:nil
                                                                        delegate:self];
    }
    
    return self;
}

#pragma mark - Logic
- (void)toggleiCloudSync
{
    __weak typeof(self) weakSelf = self;
    if(!self.ubiquityStoreManager.cloudEnabled)
    {
        [self.ubiquityStoreManager setCloudEnabledAndOverwriteCloudWithLocalIfConfirmed:^(void(^setConfirmationAnswer)(BOOL answer)){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.iCloudConfirmationBlock = setConfirmationAnswer;
            
            iCloudEnabledAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloud", nil)
                                                                message:NSLocalizedString(@"You already have Diabetik data stored on iCloud. Would you like to download it and overwrite your local data, or overwrite it with the data on your device?", nil)
                                                               delegate:strongSelf
                                                      cancelButtonTitle:NSLocalizedString(@"Nevermind", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Overwrite my iCloud data", nil), NSLocalizedString(@"Overwrite my local data", nil), nil];
            [iCloudEnabledAlertView show];
        }];
    }
    else
    {
        [self.ubiquityStoreManager setCloudDisabledAndOverwriteLocalWithCloudIfConfirmed:^(void(^setConfirmationAnswer)(BOOL answer)){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.iCloudConfirmationBlock = setConfirmationAnswer;
            
            iCloudDisabledAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloud", nil)
                                                                message:NSLocalizedString(@"Disabling iCloud will make the data stored there unavailable. Would you like to download it to your device?", nil)
                                                               delegate:strongSelf
                                                      cancelButtonTitle:NSLocalizedString(@"Nevermind", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Download my iCloud data", nil), NSLocalizedString(@"Revert to my local data", nil), nil];
            [iCloudDisabledAlertView show];
        }];
    }
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - UbiquityStoreManagerDelegate
- (NSManagedObjectContext *)managedObjectContextForUbiquityChangesInManager:(UbiquityStoreManager *)manager
{
    return self.managedObjectContext;
}
- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager willLoadStoreIsCloud:(BOOL)isCloudStore
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
            NSLog( @"Unresolved error: %@\n%@", error, [error userInfo] );
        
        [managedObjectContext reset];
    }];
    
    _managedObjectContext = nil;
}
- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager
  didLoadStoreForCoordinator:(NSPersistentStoreCoordinator *)coordinator
                     isCloud:(BOOL)isCloudStore
{
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    moc.persistentStoreCoordinator = coordinator;
    moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    _managedObjectContext = moc;
    NSLog(@"SET MOC: %@", self.managedObjectContext);
    dispatch_async( dispatch_get_main_queue(), ^{
        [cloudContentCorruptedAlert dismissWithClickedButtonIndex:[cloudContentCorruptedAlert cancelButtonIndex] animated:YES];
        [handleCloudContentWarningAlert dismissWithClickedButtonIndex:[handleCloudContentWarningAlert cancelButtonIndex] animated:YES];
    });
}
- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager
 failedLoadingStoreWithCause:(UbiquityStoreErrorCause)cause
                     context:(id)context
                    wasCloud:(BOOL)wasCloudStore
{
    dispatch_async( dispatch_get_main_queue(), ^{
        
        if (!wasCloudStore && ![handleLocalStoreAlert isVisible]) {
            handleLocalStoreAlert = [[UIAlertView alloc] initWithTitle:@"Local Store Problem"
                                                               message:@"Your datastore got corrupted and needs to be recreated."
                                                              delegate:self
                                                     cancelButtonTitle:nil otherButtonTitles:@"Recreate", nil];
            [handleLocalStoreAlert show];
        }
    });
}
- (BOOL)ubiquityStoreManager:(UbiquityStoreManager *)manager
handleCloudContentCorruptionWithHealthyStore:(BOOL)storeHealthy
{
    
    if (storeHealthy) {
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([cloudContentHealingAlert isVisible])
                return;
            
            cloudContentHealingAlert = [[UIAlertView alloc]
                                        initWithTitle:@"iCloud Store Corruption"
                                        message:@"\n\n\n\nRebuilding cloud store to resolve corruption."
                                        delegate:self cancelButtonTitle:nil otherButtonTitles:@"Disable iCloud", nil];
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.center = CGPointMake( 142, 90 );
            [activityIndicator startAnimating];
            [cloudContentHealingAlert addSubview:activityIndicator];
            [cloudContentHealingAlert show];
        } );
        
        return YES;
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([cloudContentHealingAlert isVisible] || [handleCloudContentWarningAlert isVisible])
                return;
            
            cloudContentCorruptedAlert = [[UIAlertView alloc]
                                          initWithTitle:@"iCloud Store Corruption"
                                          message:@"\n\n\n\nWaiting for another device to auto-correct the problem..."
                                          delegate:self cancelButtonTitle:nil otherButtonTitles:@"Disable iCloud", @"Fix Now", nil];
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.center = CGPointMake( 142, 90 );
            [activityIndicator startAnimating];
            [cloudContentCorruptedAlert addSubview:activityIndicator];
            [cloudContentCorruptedAlert show];
        } );
        
        return NO;
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == iCloudEnabledAlertView || alertView == iCloudDisabledAlertView)
    {
        if(buttonIndex == [alertView firstOtherButtonIndex])
        {
            self.iCloudConfirmationBlock(YES);
            self.iCloudConfirmationBlock = nil;
        }
        else if(buttonIndex == [alertView firstOtherButtonIndex]+1)
        {
            self.iCloudConfirmationBlock(NO);
            self.iCloudConfirmationBlock = nil;
        }
        else if(buttonIndex == [alertView cancelButtonIndex])
        {
            [[NSUserDefaults standardUserDefaults] setBool:(alertView == iCloudEnabledAlertView) ? @NO : @YES forKey:USMCloudEnabledKey];
        }
    }
    
    /*
    if (alertView == cloudContentHealingAlert)
    {
        if (buttonIndex == [alertView firstOtherButtonIndex]) {
            // Disable
            self.ubiquityStoreManager.cloudEnabled = NO;
        }
    }
    else if (alertView == cloudContentCorruptedAlert)
    {
        if (buttonIndex == [alertView firstOtherButtonIndex]) {
            // Disable
            self.ubiquityStoreManager.cloudEnabled = NO;
        }
        else if (buttonIndex == [alertView firstOtherButtonIndex] + 1) {
            // Fix Now
            handleCloudContentWarningAlert = [[UIAlertView alloc] initWithTitle:@"Fix iCloud Now" message:
                                              @"This problem can usually be auto‑corrected by opening the app on another device where you recently made changes.\n"
                                              @"If you wish to correct the problem from this device anyway, it is possible that recent changes on another device will be lost."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Back"
                                                              otherButtonTitles:@"Fix Anyway", nil];
            [handleCloudContentWarningAlert show];
        }
    }
    else if (alertView == handleCloudContentWarningAlert)
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Back
            [cloudContentCorruptedAlert show];
        }
        else if (buttonIndex == alertView.firstOtherButtonIndex) {
            // Fix Anyway
            [self.ubiquityStoreManager rebuildCloudContentFromCloudStoreOrLocalStore:YES];
        }
    }
    else if (alertView == handleLocalStoreAlert)
    {
        if (buttonIndex == [alertView firstOtherButtonIndex]) {
            // Recreate
            [self.ubiquityStoreManager deleteLocalStore];
        }
    }
    */
}

#pragma mark - Helpers
- (NSURL *)persistentStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Diabetik.sqlite"];
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
