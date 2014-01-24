//
//  NSString+Extension.m
//  Diabetik
//
//  Created by Nial Giacomelli on 20/12/2012.
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

#import "NSString+Extension.h"

@implementation NSString (Extension)

#pragma mark - Transforms
- (NSString *)escapedForCSV
{
    NSString *value = [self stringByReplacingOccurrencesOfString: @"\"" withString: @"\"\""];
    return [NSString stringWithFormat:@"\"%@\"", value];
}
- (NSArray *)characterArray
{
    NSRange theRange = {0, 1};
    NSMutableArray * array = [NSMutableArray array];
    for(NSInteger i = 0; i < [self length]; i++)
    {
        theRange.location = i;
        [array addObject:[self substringWithRange:theRange]];
    }
    
    return [NSArray arrayWithArray:array];
}

#pragma mark - Calculations
- (NSUInteger)levenshteinDistanceToString:(NSString *)string
{
    NSUInteger sl = [self length];
    NSUInteger tl = [string length];
    NSUInteger *d = calloc(sizeof(*d), (sl+1) * (tl+1));
    
#define d(i, j) d[((j) * sl) + (i)]
    for (NSUInteger i = 0; i <= sl; i++) {
        d(i, 0) = i;
    }
    for (NSUInteger j = 0; j <= tl; j++) {
        d(0, j) = j;
    }
    for (NSUInteger j = 1; j <= tl; j++) {
        for (NSUInteger i = 1; i <= sl; i++) {
            if ([self characterAtIndex:i-1] == [string characterAtIndex:j-1]) {
                d(i, j) = d(i-1, j-1);
            } else {
                d(i, j) = MIN(d(i-1, j), MIN(d(i, j-1), d(i-1, j-1))) + 1;
            }
        }
    }
    
    NSUInteger r = d(sl, tl);
#undef d
    
    free(d);
    
    return r;
}
@end
