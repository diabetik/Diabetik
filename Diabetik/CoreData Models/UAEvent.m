//
//  UAEvent.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/02/2013.
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

#import "NSDate+Extension.h"
#import "UAMediaController.h"
#import "UAEvent.h"
#import "UATag.h"

@implementation UAEvent
@dynamic externalGUID, externalSource;
@dynamic filterType;
@dynamic name, notes;
@dynamic timestamp, primitiveTimestamp;
@dynamic sectionIdentifier, primitiveSectionIdentifier;
@dynamic photoPath;
@dynamic lat, lon;
@dynamic account;
@dynamic tags;

#pragma mark - Logic
- (void)willSave
{
    [super willSave];
    
    if([self isInserted] || [self isUpdated] || [self isDeleted])
    {
        BOOL shouldUpdateLastSyncTS = NO;
        NSNumber *lastSyncTimestamp = [[NSUserDefaults standardUserDefaults] valueForKey:kAnalytikLastSyncTimestampKey];
        if(lastSyncTimestamp)
        {
            if([lastSyncTimestamp integerValue] > [[self timestamp] timeIntervalSince1970])
            {
                shouldUpdateLastSyncTS = YES;
            }
        }
        else
        {
            shouldUpdateLastSyncTS = YES;
        }
        
        if(shouldUpdateLastSyncTS)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[[self timestamp] timeIntervalSince1970] forKey:kAnalytikLastSyncTimestampKey];
        }
    }
}
- (void)prepareForDeletion
{
    [super prepareForDeletion];
    
    // Remove any media
    if(self.photoPath)
    {
        [[UAMediaController sharedInstance] deleteImageWithFilename:self.photoPath success:nil failure:nil];
        self.photoPath = nil;
    }

    // Remove any tags
    for (UATag *tag in self.tags)
    {
        if(tag.events.count <= 1)
        {
            [self.managedObjectContext deleteObject:tag];
        }
    }
}

#pragma mark - Transient properties
- (NSString *)sectionIdentifier
{
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp)
    {
        tmp = [NSString stringWithFormat:@"%f", [[self.timestamp dateWithoutTime] timeIntervalSince1970]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    
    return tmp;
}
- (NSString *)humanReadableName
{
    return @"";
}

#pragma mark - Time stamp setter
- (void)setTimestamp:(NSDate *)newDate
{
    [self willChangeValueForKey:@"timestamp"];
    [self setPrimitiveTimestamp:newDate];
    [self didChangeValueForKey:@"timestamp"];
    
    [self setPrimitiveSectionIdentifier:nil];
}

#pragma mark - Key path dependencies
+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    return [NSSet setWithObject:@"timestamp"];
}

@end
