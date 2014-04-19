//
//  UAHelper.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/12/2012.
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

#import "UAHelper.h"

@implementation UAHelper

#pragma mark - Formatter methods
+ (NSString *)formatMinutes:(double)minutes
{
    int hours = minutes/60;
    int mins = (int)minutes%60;
    
    return [NSString stringWithFormat:@"%02d:%02d", hours, mins];
}
+ (NSNumber *)formatBGReadingWithValue:(NSNumber *)value inUnit:(NSInteger)units
{
    if(units == BGTrackingUnitMG)
    {
        value = [NSNumber numberWithInteger:[value integerValue]];
    }
    
    return value;
}
+ (NSNumberFormatter *)standardNumberFormatter
{
    static dispatch_once_t pred;
    static NSNumberFormatter *standardFormatter = nil;
    dispatch_once(&pred, ^{
        standardFormatter = [[NSNumberFormatter alloc] init];
    });
    [standardFormatter setAlwaysShowsDecimalSeparator:NO];
    [standardFormatter setMaximumFractionDigits:4];
    
    return standardFormatter;
}
+ (NSNumberFormatter *)glucoseNumberFormatter
{
    static dispatch_once_t pred;
    static NSNumberFormatter *glucoseFormatter = nil;
    dispatch_once(&pred, ^{
        glucoseFormatter = [[NSNumberFormatter alloc] init];
    });
    [glucoseFormatter setAlwaysShowsDecimalSeparator:NO];
    [glucoseFormatter setMaximumFractionDigits:[UAHelper userBGUnit] == BGTrackingUnitMG ? 0 : 2];
    
    return glucoseFormatter;
}
+ (NSDateFormatter *)shortTimeFormatter
{
    static dispatch_once_t pred;
    static NSDateFormatter *shortTimeFormatter = nil;
    dispatch_once(&pred, ^{
        shortTimeFormatter = [[NSDateFormatter alloc] init];
        [shortTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    
    return shortTimeFormatter;
}
+ (NSDateFormatter *)hhmmTimeFormatter
{
    static dispatch_once_t pred;
    static NSDateFormatter *shortTimeFormatter = nil;
    dispatch_once(&pred, ^{
        shortTimeFormatter = [[NSDateFormatter alloc] init];
        [shortTimeFormatter setDateFormat:@"HH:mm"];
    });
    
    return shortTimeFormatter;
}

#pragma mark - Converts
+ (NSNumber *)convertBGValue:(NSNumber *)value fromUnit:(NSInteger)fromUnit toUnit:(NSInteger)toUnit
{
    // NSInteger userUnit = [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
    double convertedValue = [value doubleValue];
    
    if(fromUnit == BGTrackingUnitMG && toUnit == BGTrackingUnitMMO)
    {
        convertedValue *= 0.0555;
    }
    else if(fromUnit == BGTrackingUnitMMO && toUnit == BGTrackingUnitMG)
    {
        convertedValue *= 18.0182;
    }
    
    return [UAHelper formatBGReadingWithValue:[NSNumber numberWithDouble:convertedValue] inUnit:toUnit];
}

#pragma mark - Helpers
+ (NSInteger)userBGUnit
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kBGTrackingUnitKey];
}
+ (BOOL)isBGLevelSafe:(double)value
{
    NSInteger userUnit = [UAHelper userBGUnit];
    NSNumber *healthyRangeMin = [UAHelper convertBGValue:[[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyBGKey] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
    NSNumber *healthyRangeMax = [UAHelper convertBGValue:[[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyBGKey] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
    
    if(value >= [healthyRangeMin doubleValue] && value <= [healthyRangeMax doubleValue])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
