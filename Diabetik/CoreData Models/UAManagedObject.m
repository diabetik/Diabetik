//
//  UAManagedObject.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/03/2013.
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

#import "UAManagedObject.h"

@implementation UAManagedObject
@synthesize traversed;
@dynamic guid;
@dynamic modifiedTimestamp, createdTimestamp;

#pragma mark - Setup
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.guid = [self generateUniqueID];
    self.createdTimestamp = [NSDate date];
}

#pragma mark - Logic
- (void)willSave
{
    [super willSave];
    
    if([self isUpdated])
    {
        [self setPrimitiveValue:[NSDate date] forKey:@"modifiedTimestamp"];
    }
}

#pragma mark - Archiver
- (NSDictionary *)dictionaryRepresentation
{
    self.traversed = YES;
    
    NSArray *attributes = [[[self entity] attributesByName] allKeys];
    NSArray *relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + [relationships count] + 1];
    
    [dict setObject:[[self class] description]forKey:@"class"];
    
    for(NSString *attr in attributes)
    {
        NSObject *value = [self valueForKey:attr];
        
        if(value != nil)
        {
            [dict setObject:value forKey:attr];
        }
    }
    
    for(NSString *relationship in relationships)
    {
        NSObject *value = [self valueForKey:relationship];
        
        if([value isKindOfClass:[NSSet class]])
        {
            // To-many relationship
            
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
            
            // Our set holds a collection of dictionaries
            NSMutableSet* dictSet = [NSMutableSet setWithCapacity:[relatedObjects count]];
            for(UAManagedObject *relatedObject in relatedObjects)
            {
                if (!relatedObject.traversed)
                {
                    [dictSet addObject:[relatedObject dictionaryRepresentation]];
                }
            }
            
            [dict setObject:dictSet forKey:relationship];
        }
        else if ([value isKindOfClass:[UAManagedObject class]])
        {
            // To-one relationship
            UAManagedObject* relatedObject = (UAManagedObject *)value;
            
            if (!relatedObject.traversed)
            {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject dictionaryRepresentation] forKey:relationship];
            }
        }
    }
    
    return dict;
}
- (void)populateFromDictionaryRepresentation:(NSDictionary*)dict
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(NSString *key in dict)
    {
        if([key isEqualToString:@"class"]) continue;
        
        NSObject *value = [dict objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]])
        {
            // This is a to-one relationship
            UAManagedObject *relatedObject = [UAManagedObject createManagedObjectFromDictionaryRepresentation:(NSDictionary *)value inContext:context];
            [self setValue:relatedObject forKey:key];
        }
        else if ([value isKindOfClass:[NSSet class]])
        {
            // This is a to-many relationship
            NSSet *relatedObjectDictionaries = (NSSet*) value;
            
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet *relatedObjects = [self mutableSetValueForKey:key];
            
            for (NSDictionary *relatedObjectDict in relatedObjectDictionaries)
            {
                UAManagedObject *relatedObject = [UAManagedObject createManagedObjectFromDictionaryRepresentation:relatedObjectDict inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }
        else if (value != nil)
        {
            // This is an attribute
            [self setValue:value forKey:key];
        }
    }
}
+ (UAManagedObject *)createManagedObjectFromDictionaryRepresentation:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    NSString *guid = [dict objectForKey:@"guid"];
    NSString *class = [dict objectForKey:@"class"];
    UAManagedObject *object = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UABaseObject" inManagedObjectContext:context];
    if(entity)
    {
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid = %@", guid];
        [request setPredicate:predicate];
        
        @try {
            
            // Execute the fetch.
            NSError *error = nil;
            NSArray *objects = [context executeFetchRequest:request error:&error];
            if (objects != nil && [objects count] > 0)
            {
                object = [objects objectAtIndex:0];
            }
            else
            {
                object = (UAManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:class inManagedObjectContext:context];
            }
            
            [object populateFromDictionaryRepresentation:dict];
            
        }
        @catch (NSException *exception) {
            
            // STUB
            
        }
        @finally {
            
            // STUB
            
        }
    }
    
    return object;
}

#pragma mark - Helpers
- (NSString *)generateUniqueID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *str = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return str;
}

@end