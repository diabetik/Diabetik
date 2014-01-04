//
//  UASyncController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 04/01/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "SSKeychain.h"
#import "UAAnalytikController.h"
#import "UASyncController.h"

@implementation UASyncController

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Logic
- (void)sync
{
    // Have we got an Analytik API account setup?
    if([[self analytikController] activeAccount])
    {
        NSLog(@"Has got an Analytik API account");
    }
}

#pragma mark - Accessors
- (UAAnalytikController *)analytikController
{
    static dispatch_once_t pred = 0;
    __strong static UAAnalytikController* _analytikController = nil;
    dispatch_once(&pred, ^{
        _analytikController = [[UAAnalytikController alloc] init];
    });
    
    return _analytikController;
}

@end
