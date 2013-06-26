//
//  UAAccountController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 24/02/2013.
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

#import "UAAccountController.h"

@interface UAAccountController ()
@property (nonatomic, strong) NSManagedObjectContext *moc;
@end

@implementation UAAccountController
@synthesize activeAccount = _activeAccount;
@synthesize accounts = _accounts;
@synthesize moc = _moc;

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
        _activeAccount = nil;
        _accounts = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cacheAccounts) name:kAccountsUpdatedNotification object:nil];
    }
    
    return self;
}
- (void)setMOC:(NSManagedObjectContext *)aMOC
{
    _moc = aMOC;
    
    [self cacheAccounts];
}

#pragma mark - Logic
- (void)cacheAccounts
{
    _accounts = [self fetchAllAccountsInContext:self.moc];
}
- (UAAccount *)activeAccount
{
    // Do we already have a selected active account?
    if(_activeAccount) return _activeAccount;
    
    return [self activeAccountInContext:self.moc];
}
- (UAAccount *)activeAccountInContext:(NSManagedObjectContext *)aMOC
{
    UAAccount *theActiveAccount = nil;
    
    // Fetch a collection of all existing accounts
    NSArray *accounts = [self fetchAllAccountsInContext:aMOC];
    if([accounts count])
    {
        UAAccount *preferredAccount = nil;
        
        // If we have a saved 'active' account preference, try to restore it
        NSString *uuid = [[NSUserDefaults standardUserDefaults] valueForKey:kActiveAccountKey];
        if(uuid)
        {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAAccount" inManagedObjectContext:aMOC];
            [request setEntity:entity];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
            [request setPredicate:predicate];
            
            NSError *error = nil;
            NSArray *accounts = [aMOC executeFetchRequest:request error:&error];
            if (accounts != nil && [accounts count] > 0)
            {
                preferredAccount = (UAAccount *)[accounts objectAtIndex:0];
            }
        }
        
        // If we can't determine a preferred default account, just use the first that we're passed back
        if(!preferredAccount)
        {
            theActiveAccount = [accounts objectAtIndex:0];
        }
        else
        {
            theActiveAccount = preferredAccount;
        }
    }
    // If we don't have any active accounts, create a placeholder for the user
    else
    {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAAccount" inManagedObjectContext:aMOC];
        UAAccount *newAccount = (UAAccount *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:aMOC];
        newAccount.name = NSLocalizedString(@"You", @"Referring to the users account");
        newAccount.created = [NSDate date];
        newAccount.dob = [NSDate date];
        
        NSError *error = nil;
        [aMOC save:&error];
        
        if(!error)
        {
            theActiveAccount = newAccount;
        }
        else
        {
            theActiveAccount = nil;
        }
    }
    
    if(self.moc == aMOC)
    {
        if(theActiveAccount)
        {
            [self setActiveAccount:theActiveAccount];
        }
        [self cacheAccounts];
    }
    
    return theActiveAccount;
}
- (void)setActiveAccount:(UAAccount *)theAccount
{
    // Make sure this is a newly active account
    if([_activeAccount.uuid isEqual:theAccount.uuid]) return;
    
    _activeAccount = theAccount;
    
    [[NSUserDefaults standardUserDefaults] setValue:theAccount.uuid forKey:kActiveAccountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAccountsSwitchedNotification object:nil];
}
- (NSArray *)fetchAllAccountsInContext:(NSManagedObjectContext *)aMOC
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAAccount" inManagedObjectContext:aMOC];
    [request setEntity:entity];
    
    NSSortDescriptor *sortPredicate = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortPredicate]];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [aMOC executeFetchRequest:request error:&error];
    if (objects != nil && [objects count] > 0)
    {
        return objects;
    }
    
    return @[];
}

@end
