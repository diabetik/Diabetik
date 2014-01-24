//
//  UALeastSquareFitCalculator.m
//  Diabetik
//
//  Based on http://stackoverflow.com/questions/11796810/calculate-trendline-and-predict-future-results
//
//  Created by Nial Giacomelli on 06/05/2013.
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

#import "UALeastSquareFitCalculator.h"

@interface UALineFitCalculator ()
{
    double count;
    double sumX, sumX2;
    double sumXY, sumY;
}
@end

@implementation UALineFitCalculator

#pragma mark - Logic
- (void)addPoint:(CGPoint)point
{
    count++;
    sumX += point.x;
    sumX2 += point.x*point.x;
    sumXY += point.x*point.y;
    sumY += point.y;
}
- (CGFloat)projectedYValueForX:(CGFloat)x
{
    double det = count * sumX2 - sumX * sumX;
    double offset = (sumX2 * sumY - sumX * sumXY) / det;
    double scale = (count * sumXY - sumX * sumY) / det;
    
    CGFloat v = offset + x * scale;
    return v < 0 ? 0 : v;
}

@end

@interface UASquareFitCalculator ()
{
    double count;
    double sumX, sumX2, sumX3, sumX4;
    double sumXY, sumY, sumX2Y;
}
@end

@implementation UASquareFitCalculator

#pragma mark - Logic
- (void)addPoint:(CGPoint)point
{
    count++;
    sumX += point.x;
    sumX2 += point.x*point.x;
    sumX3 += point.x*point.x*point.x;
    sumX4 += point.x*point.x*point.x*point.x;
    sumY += point.y;    
    sumXY += point.x*point.y;
    sumX2Y += point.x*point.x*point.y;
}
- (CGFloat)projectedYValueForX:(CGFloat)x
{
    double det = count*sumX2*sumX4 - count*sumX3*sumX3 - sumX*sumX*sumX4 + 2*sumX*sumX2*sumX3 - sumX2*sumX2*sumX2;
    double offset = sumX*sumX2Y*sumX3 - sumX*sumX4*sumXY - sumX2*sumX2*sumX2Y + sumX2*sumX3*sumXY + sumX2*sumX4*sumY - sumX3*sumX3*sumY;
    double scale = -count*sumX2Y*sumX3 + count*sumX4*sumXY + sumX*sumX2*sumX2Y - sumX*sumX4*sumY - sumX2*sumX2*sumXY + sumX2*sumX3*sumY;
    double accel = sumY*sumX*sumX3 - sumY*sumX2*sumX2 - sumXY*count*sumX3 + sumXY*sumX2*sumX - sumX2Y*sumX*sumX + sumX2Y*count*sumX2;
    return (offset + x*scale + x*x*accel)/det;
}

@end