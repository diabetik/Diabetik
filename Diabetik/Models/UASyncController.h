//
//  UASyncController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 04/01/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAAnalytikController.h"

@interface UASyncController : NSObject

+ (id)sharedInstance;

// Logic
- (void)sync;

// Accessors
- (UAAnalytikController *)analytikController;

@end
