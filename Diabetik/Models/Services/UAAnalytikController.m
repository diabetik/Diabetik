//
//  UAAnalytikController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 04/01/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "AFNetworking.h"
#import "UAAnalytikController.h"
#import "SSKeychain.h"

@interface UAAnalytikController ()

// Helpers
- (NSError *)responseError:(NSDictionary *)response;

@end

@implementation UAAnalytikController

#pragma mark - Logic
- (void)authorizeWithCredentials:(NSDictionary *)credentials
                         success:(void (^)(void))successBlock
                         failure:(void (^)(NSError *))failureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"email": credentials[@"email"], @"password": credentials[@"password"]};
    [manager POST:[NSString stringWithFormat:@"%@user/validate", kAnalytikAPIURL]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
              
          NSError *error = [self responseError:responseObject];
          if(!error)
          {
              // If our authorization is successful, store our login credentials securely in the keychain
              [SSKeychain setPassword:credentials[@"password"] forService:kAnalytikServiceIdentifier account:credentials[@"email"] error:&error];
              if(!error)
              {
                  successBlock();
              }
              else
              {
                  failureBlock(error);
              }
          }
          else
          {
              failureBlock(error);
          }
          
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failureBlock(error);
        
    }];
}
- (void)destroyCredentials
{
    NSArray *accounts = [SSKeychain accountsForService:kAnalytikServiceIdentifier];
    if(accounts && [accounts count])
    {
        for(NSDictionary *account in accounts)
        {
            [SSKeychain deletePasswordForService:kAnalytikServiceIdentifier account:account[kSSKeychainAccountKey]];
        }
    }
}

#pragma mark - Helpers
- (NSError *)responseError:(NSDictionary *)response
{
    // Check for the existance of an 'error' key in our JSON response to determine whether we've done something wrong
    if([response isKindOfClass:[NSDictionary class]] && response[@"error"])
    {
        NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"The Analytik API responded with the following error: %@", nil), response[@"error"][@"message"]];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    }
    else
    {
        // Since it appears there's no error present, try to look for a valid response
        if([response isKindOfClass:[NSDictionary class]] && response[@"response"])
        {
            if([response[@"response"][@"code"] integerValue] == 200)
            {
                return nil;
            }
        }
    }
    
    // If all else has failed, it looks like we don't understand the response, so throw back a generic error
    NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"The Analytik API returned an unrecognized response", nil)];
    return [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
}
- (NSDictionary *)activeAccount
{
    NSArray *accounts = [SSKeychain accountsForService:kAnalytikServiceIdentifier];
    if(accounts && [accounts count])
    {
        NSError *error = nil;
        NSString *email = accounts[0][kSSKeychainAccountKey];
        NSString *password = [SSKeychain passwordForService:kAnalytikServiceIdentifier account:email error:&error];
        
        if(!error)
        {
            return @{@"email": email, @"password": password};
        }
    }
    
    return nil;
}

@end
