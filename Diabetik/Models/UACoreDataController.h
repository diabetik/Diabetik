//
//  UACoreDataController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 12/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UACoreDataController : NSObject <UbiquityStoreManagerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UbiquityStoreManager *ubiquityStoreManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;

// Logic
- (void)toggleiCloudSync;
- (void)saveContext;

@end
