//
//  UATagController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2013.
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

#import "UATagController.h"
#import "UAAppDelegate.h"

@interface UATagController ()
@end

@implementation UATagController

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - String helpers
- (NSRange)rangeOfTagInString:(NSString *)string withCaretLocation:(NSUInteger)caretLocation
{
    NSRegularExpression *regex = [UATagController tagRegularExpression];
    __block NSRange range = NSMakeRange(NSNotFound, 0);
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location <= caretLocation && result.range.location+result.range.length >= caretLocation)
        {
            range = result.range;
            *stop = YES;
        }
    }];
    
    return range;
}

#pragma mark - Regular Expressions
+ (NSRegularExpression *)tagRegularExpression
{
    static NSRegularExpression *tagRegularExpression = nil;
    if(!tagRegularExpression)
    {
        NSError *error = nil;
        tagRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"#([\\w\\d\\-]+)"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
    }
    
    return tagRegularExpression;
}

#pragma mark - Helpers
- (NSArray *)fetchTagsInString:(NSString *)string
{
    __block NSMutableArray *tags = [NSMutableArray array];
    
    if(string && [string length])
    {
        NSRegularExpression *regex = [UATagController tagRegularExpression];
        [regex enumerateMatchesInString:string
                                options:0
                                  range:NSMakeRange(0, string.length)
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSString *tag = [string substringWithRange:[result rangeAtIndex:1]];

            // De-duplicate tags!
            BOOL tagAlreadyExists = NO;
            for(NSString *existingTag in tags)
            {
                if([[existingTag lowercaseString] isEqualToString:[tag lowercaseString]])
                {
                    tagAlreadyExists = YES;
                    break;
                }
            }               
            if(!tagAlreadyExists) [tags addObject:[tag lowercaseString]];
        }];
    }
    
    return [NSArray arrayWithArray:tags];
}
- (NSArray *)fetchAllTags
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    NSMutableArray *tags = [NSMutableArray array];
    if(moc)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UATag" inManagedObjectContext:moc];
        [request setEntity:entity];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            for(UATag *tag in objects)
            {
                [tags addObject:tag.name];
            }
        }
    }
    
    return [NSArray arrayWithArray:tags];
}
- (NSArray *)fetchExistingTagsWithStrings:(NSArray *)strings
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UATag" inManagedObjectContext:moc];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nameLC IN %@", strings];
        [request setPredicate:predicate];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            return objects;
        }
    }
    
    return nil;
}
- (void)assignTags:(NSArray *)tags toEvent:(UAEvent *)event
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        // Remove any existing tags from this event
        if(event.tags.count)
        {
            NSSet *existingEventTags = [event.tags copy];
            for (UATag *tag in existingEventTags)
            {
                [[event mutableSetValueForKey:@"tags"] removeObject:tag];
                if(tag.events.count <= 0)
                {
                    [moc deleteObject:tag];
                }
            }
        }
        
        // Now re-assign any applicable tags to this event
        for(NSString *tag in tags)
        {
            NSArray *existingTags = [self fetchExistingTagsWithStrings:@[[tag lowercaseString]]];
            if(existingTags && [existingTags count])
            {
                [event addTagsObject:(UATag *)[existingTags objectAtIndex:0]];
            }
            else
            {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UATag" inManagedObjectContext:moc];
                UATag *newTag = (UATag *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
                newTag.name = tag;
                [newTag addEventsObject:event];
            }
        }
    }
}

@end
