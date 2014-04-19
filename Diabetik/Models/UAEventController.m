//
//  UAEventController.m
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

#import "NSDate+Extension.h"

#import "UAEventController.h"
#import "UATagController.h"

#import "UAReading.h"
#import "UAMedicine.h"
#import "UAMeal.h"
#import "UAActivity.h"

@interface UAEventController ()
@property (nonatomic, strong) NSManagedObjectContext *moc;
@end

@implementation UAEventController
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
- (void)setMOC:(NSManagedObjectContext *)aMOC
{
    _moc = aMOC;
}

#pragma mark - Events
- (void)attemptSmartInputWithExistingEntries:(NSMutableArray *)existingEntries
                                     success:(void (^)(UAMedicine*))successBlock
                                     failure:(void (^)(void))failureBlock
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        [moc performBlock:^{

            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAMedicine" inManagedObjectContext:moc];
            [request setEntity:entity];
            
            // Fetch all medication inputs over the past 15 days
            NSDate *timestamp = [[[NSDate date] dateAtStartOfDay] dateBySubtractingDays:15];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@", timestamp];
            [request setPredicate:predicate];
            
            NSInteger hourInterval = 3;
            NSInteger numberOfSegments = 24/(hourInterval*2);
            
            // Execute the fetch.
            NSError *error = nil;
            NSMutableArray *objects = [NSMutableArray array];
            NSArray *results = [moc executeFetchRequest:request error:&error];
            if(results)
            {
                [objects addObjectsFromArray:results];
            }
            if(existingEntries)
            {
                [objects addObjectsFromArray:existingEntries];
            }
            
            if (objects != nil && [objects count] > 0)
            {
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *currentComponents = [gregorianCalendar components:NSHourCalendarUnit fromDate:[NSDate date]];
                NSInteger currentHour = [currentComponents hour];
                
                // Create an event array index for each medicine 'type'
                NSMutableArray *previousEvents = [NSMutableArray array];
                NSMutableArray *todaysEvents = [NSMutableArray array];
                for(NSInteger i = 0; i < numberOfSegments; i++)
                {
                    [previousEvents addObject:[NSMutableArray array]];
                    [todaysEvents addObject:[NSMutableArray array]];
                }
                
                // Iterate over all medicine events that have taken place over the past 15 days
                for(UAMedicine *event in objects)
                {
                    NSDateComponents *eventComponents = [gregorianCalendar components:NSHourCalendarUnit fromDate:[event timestamp]];
                    NSInteger eventHour = [eventComponents hour];
                    
                    // If this event occurred today, remove it from the rest of the group
                    if([[event timestamp] isEqualToDateIgnoringTime:[NSDate date]])
                    {
                        NSMutableArray *existingEvents = [todaysEvents objectAtIndex:[[event type] integerValue]];
                        [existingEvents addObject:event];
                        [todaysEvents replaceObjectAtIndex:[[event type] integerValue] withObject:existingEvents];
                    }
                    else
                    {
                        // Did this event happen within 3 hours (irrespective of date) from the current time?
                        if(fabs(eventHour-currentHour) <= numberOfSegments-1)
                        {
                            NSMutableArray *existingEvents = [previousEvents objectAtIndex:[[event type] integerValue]];
                            [existingEvents addObject:event];
                            [previousEvents replaceObjectAtIndex:[[event type] integerValue] withObject:existingEvents];
                        }
                    }
                }
                
                // Loop through today's events and try to determine what has already been entered
                for(NSInteger i = 0; i < numberOfSegments; i++)
                {
                    NSMutableArray *events = [todaysEvents objectAtIndex:i];
                    if([events count])
                    {
                        // Loop through all of the events of this type that occurred today
                        NSMutableArray *pEvents = [previousEvents objectAtIndex:i];
                        for(UAMedicine *event in events)
                        {
                            // Loop through previous events of this type
                            for(UAMedicine *pEvent in [pEvents copy])
                            {
                                // Determine whether this previous event is similar to the medicine taken earlier today
                                // If it is, remove it from consideration
                                NSString *eventDesc = [[event name] lowercaseString];
                                NSString *pEventDesc = [[pEvent name] lowercaseString];
                                if([eventDesc levenshteinDistanceToString:pEventDesc] <= 3)
                                {
                                    NSDateComponents *eventComponents = [gregorianCalendar components:NSHourCalendarUnit fromDate:[event timestamp]];
                                    NSInteger eventHour = [eventComponents hour];
                                    
                                    // Remove any medication taken within 3 hours of this date/time
                                    if(fabs(eventHour-currentHour) <= numberOfSegments-1)
                                    {
                                        [pEvents removeObject:pEvent];
                                    }
                                }
                            }
                        }
                        [previousEvents replaceObjectAtIndex:i withObject:pEvents];
                    }
                }
                
                NSMutableArray *sortedEvents = [NSMutableArray arrayWithArray:[previousEvents sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSNumber *first = [NSNumber numberWithInteger:[a count]];
                    NSNumber *second = [NSNumber numberWithInteger:[b count]];
                    return [first compare:second];
                }]];
                for(NSInteger i = numberOfSegments-1; i >= 0; i--)
                {
                    NSMutableArray *events = [sortedEvents objectAtIndex:i];
                    
                    // Only choose an event if there's more than 1 instance of it (experimental)
                    if([events count] > 1)
                    {
                        successBlock((UAMedicine *)[events objectAtIndex:0]);
                        return;
                    }
                    else
                    {
                        // Uh oh, better get out of here
                        break;
                    }
                }
                
                failureBlock();
            }
            else
            {
                // No objects to perform Smart Input with
                failureBlock();
            }
        }];
    }
    else
    {
        failureBlock();
    }
}
- (NSArray *)fetchEventsWithPredicate:(NSPredicate *)predicate
                      sortDescriptors:(NSArray *)sortDescriptors
                            inContext:(NSManagedObjectContext *)moc
{
    __block NSArray *returnArray = nil;
    
    [moc performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAEvent" inManagedObjectContext:moc];
        [request setEntity:entity];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects != nil && [objects count] > 0)
        {
            returnArray = objects;
        }
    }];
    return returnArray;
}
- (NSDictionary *)statisticsForEvents:(NSArray *)events fromDate:(NSDate *)minDate toDate:(NSDate *)maxDate
{
    NSInteger totalGrams = 0, totalMinutes = 0, totalReadings = 0;
    double lowestReading = 99999.9, highestReading = 0.0f, readingsTotal = 0.0f;
    NSMutableArray *readingValues = [NSMutableArray array];
    for(UAEvent *event in events)
    {
        NSDate *timestamp = [event valueForKey:@"timestamp"];
        if([timestamp isEarlierThanDate:maxDate] && [timestamp isLaterThanDate:minDate])
        {
            if([event isKindOfClass:[UAReading class]])
            {
                UAReading *reading = (UAReading *)event;
                
                double readingValue = [[reading value] doubleValue];
                readingsTotal += readingValue;
                
                if(readingValue > highestReading) highestReading = readingValue;
                if(readingValue < lowestReading) lowestReading = readingValue;
                
                [readingValues addObject:[NSNumber numberWithDouble:readingValue]];
                
                totalReadings ++;
            }
            else if([event isKindOfClass:[UAMeal class]])
            {
                UAMeal *meal = (UAMeal *)event;
                totalGrams += [[meal grams] integerValue];
            }
            else if([event isKindOfClass:[UAActivity class]])
            {
                UAActivity *activity = (UAActivity *)event;
                totalMinutes += [[activity minutes] integerValue];
            }
        }
    }
    
    double readingsAvg = 0;
    double readingsDeviation = 0;
    if(totalReadings <= 0)
    {
        lowestReading = 0.0f;
        highestReading = 0.0f;
    }
    else
    {
        readingsAvg = readingsTotal / totalReadings;
        for(NSNumber *reading in readingValues)
        {
            double diff = fabs([reading doubleValue] - readingsAvg);
            readingsDeviation += diff;
        }
        readingsDeviation /= totalReadings;
    }
    
    return @{
             @"min_date": minDate,
             @"max_date": maxDate,
             @"readings_deviation": [NSNumber numberWithDouble:readingsDeviation],
             @"readings_avg": [NSNumber numberWithDouble:readingsAvg],
             @"total_readings": [NSNumber numberWithInteger:totalReadings],
             @"total_grams": [NSNumber numberWithInteger:totalGrams],
             @"total_minutes": [NSNumber numberWithInteger:totalMinutes],
             @"lowest_reading": [NSNumber numberWithDouble:lowestReading],
             @"highest_reading": [NSNumber numberWithDouble:highestReading],
             @"events": events
             };
}
- (NSArray *)fetchKey:(NSString *)key forEventsWithFilterType:(EventFilterType)filterType
{
    __block NSArray *returnArray = nil;
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        [moc performBlockAndWait:^{

            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAEvent" inManagedObjectContext:moc];
            [request setEntity:entity];
            [request setResultType:NSDictionaryResultType];
            
            NSExpression *valueExpression = [NSExpression expressionForKeyPath:key];
            NSExpressionDescription *valueDescription = [[NSExpressionDescription alloc] init];
            [valueDescription setName:@"value"];
            [valueDescription setExpression:valueExpression];
            [valueDescription setExpressionResultType:NSStringAttributeType];
            [request setPropertiesToFetch:@[valueDescription]];
            [request setReturnsDistinctResults:YES];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType == %d", filterType];
            [request setPredicate:predicate];
            
            // Execute the fetch.
            NSError *error = nil;
            NSMutableArray *results = [NSMutableArray array];
            NSArray *objects = [moc executeFetchRequest:request error:&error];
            if (objects != nil && [objects count] > 0)
            {
                for(NSDictionary *object in objects)
                {
                    if([object valueForKey:@"value"])
                    {
                        [results addObject:[object valueForKey:@"value"]];
                    }
                }
            }
            
            if([results count])
            {
                NSArray *sorted = [NSArray arrayWithArray:results];
                returnArray = [sorted sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            }
        }];
    }
    
    return returnArray;
}

#pragma mark - Helpers
- (NSString *)medicineTypeHR:(NSInteger)type
{
    NSString *typeHR = nil;
    switch(type)
    {
        case kMedicineTypePills:
            typeHR = NSLocalizedString(@"pills", @"Type/unit of medicine");
            break;
        case kMedicineTypePuffs:
            typeHR = NSLocalizedString(@"puffs", @"Type/unit of medicine");
            break;
        case kMedicineTypeMG:
            typeHR = NSLocalizedString(@"mg", @"Type/unit of medicine");
            break;
        case kMedicineTypeUnits:
            typeHR = NSLocalizedString(@"units", @"Type/unit of medicine");
            break;
    }
    
    return typeHR;
}

@end
