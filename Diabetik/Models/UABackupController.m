//
//  UABackupController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 31/03/2013.
//  Copyright (c) 2013-2014 Nial Giacomelli
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

#import <Dropbox/Dropbox.h>
#import "UABackupController.h"
#import "UAEventController.h"
#import "UAAppDelegate.h"

@interface UABackupController ()
@end

@implementation UABackupController

#pragma mark - Logic
- (void)backupToDropbox:(void (^)(NSError *))completionCallback
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSManagedObjectContext *childMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        childMOC.parentContext = moc;
        
        [childMOC performBlock:^{
            
            NSError *error = nil;
            NSMutableArray *representations = [NSMutableArray array];
            
            @autoreleasepool {
                NSArray *events = [[UAEventController sharedInstance] fetchEventsWithPredicate:nil sortDescriptors:nil inContext:childMOC];
                if(events)
                {
                    for(UAEvent *event in events)
                    {
                        NSDictionary *representation = [event dictionaryRepresentation];
                        [representations addObject:representation];
                        
                        // Re-fault this object to conserve on memory
                        [childMOC refreshObject:event mergeChanges:NO];
                    }
                }
            }
            
            if([representations count])
            {
                NSDictionary *archive = @{@"metadata": @{@"version": @1}, @"objects": representations};
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:archive];
                
                if([[DBFilesystem sharedFilesystem] completedFirstSync])
                {
                    DBPath *newPath = [[DBPath root] childPath:[NSString stringWithFormat:@"backup.dtk"]];
                    DBFile *file = [[DBFilesystem sharedFilesystem] openFile:newPath error:nil];
                    if(!file)
                    {
                        file = [[DBFilesystem sharedFilesystem] createFile:newPath error:&error];
                    }
                    
                    if(file && !error)
                    {
                        [file writeData:data error:&error];
                        [file close];
                    }
                }
                else
                {
                    error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Dropbox is currently performing a sync operation"}];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionCallback(error);
            });
        }];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"The underlying MOC is unavailable"}];
        completionCallback(error);
    }
}
- (void)restoreFromBackup:(void (^)(NSError *))completionCallback
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSManagedObjectContext *childMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        childMOC.parentContext = moc;
        
        [childMOC performBlock:^{
            NSError *error = nil;
            DBPath *path = [[DBPath root] childPath:[NSString stringWithFormat:@"backup.dtk"]];
            DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&error];
            
            if(!error && file)
            {
                NSData *data = [file readData:&error];
                if(!error && data)
                {
                    @try {
                        
                        NSDictionary *archive = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
                        
                        for(NSDictionary *representation in archive[@"objects"])
                        {
                            [UAManagedObject createManagedObjectFromDictionaryRepresentation:representation inContext:childMOC];
                        }
                        [file close];
                        
                        [childMOC save:&error];
                        
                    }
                    @catch (NSException *exception) {
                        
                    }
                }
                else
                {
                    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                    [errorInfo setValue:@"Failed to locate backup file" forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionCallback(error);
            });
        }];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"The underlying MOC is unavailable"}];
        completionCallback(error);
    }
}

@end
