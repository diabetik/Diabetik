//
//  UAAnalytikController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 04/01/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UAAnalytikController : NSObject

// Logic
- (void)authorizeWithCredentials:(NSDictionary *)credentials
                         success:(void (^)(void))successBlock
                         failure:(void (^)(NSError *))failureBlock;
- (void)destroyCredentials;

// Helpers
- (NSDictionary *)activeAccount;

@end
