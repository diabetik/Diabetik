//
//  UACarbsChartViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 09/03/2013.
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

#import "UACarbsChartViewController.h"
#import "UAChartLineCrosshair.h"
#import "UALeastSquareFitCalculator.h"
#import "OrderedDictionary.h"

#import "UAEvent.h"
#import "UAMeal.h"
#import "UAReading.h"

@interface UACarbsChartViewController ()
{
    UALineFitCalculator *trendline;
    
    double lowestReading;
}
@end

@implementation UACarbsChartViewController

#pragma mark - Chart logic
- (NSDictionary *)parseData:(NSArray *)theData
{
    NSDate *minDate = [NSDate distantFuture];
    NSDate *maxDate = [NSDate distantPast];
    
    NSNumber *minCarbRange = [NSNumber numberWithInteger:0];
    NSNumber *maxCarbRange = [NSNumber numberWithInteger:-99999999];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSMutableArray *formattedData = [NSMutableArray array];
    OrderedDictionary *dictionary = [OrderedDictionary dictionary];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    theData = [theData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for(UAEvent *event in theData)
    {
        if([event.timestamp isEarlierThanDate:minDate]) minDate = event.timestamp;
        if([event.timestamp isLaterThanDate:maxDate]) maxDate = event.timestamp;
        
        NSMutableDictionary *data = nil;
        NSString *key = [dateFormatter stringFromDate:event.timestamp];
        if(!(data = [dictionary objectForKey:key]))
        {
            data = [NSMutableDictionary dictionaryWithDictionary:@{@"date": [event.timestamp dateAtStartOfDay], @"morningTotal": [NSNumber numberWithDouble:0.0], @"afternoonTotal": [NSNumber numberWithDouble:0.0], @"eveningTotal": [NSNumber numberWithDouble:0.0], @"readingsTotal": [NSNumber numberWithDouble:0.0], @"readingsCount": [NSNumber numberWithInteger:0]}];
        }
        
        if([event isKindOfClass:[UAMeal class]])
        {
            NSInteger hour = [event.timestamp hour];
            enum TimeOfDay timePeriod = Morning;
            
            // Morning 4AM - 11AM
            if(hour >= 4 && hour <= 10)
            {
                timePeriod = Morning;
            }
            // Afternoon 11AM - 4PM
            else if(hour > 10 && hour <= 16)
            {
                timePeriod = Afternoon;
            }
            // Evening 5PM - 4AM
            else
            {
                timePeriod = Evening;
            }
            
            UAMeal *meal = (UAMeal *)event;
            if(timePeriod == Morning) [data setObject:[NSNumber numberWithDouble:[[data objectForKey:@"morningTotal"] doubleValue] + [meal.grams doubleValue]] forKey:@"morningTotal"];
            if(timePeriod == Afternoon) [data setObject:[NSNumber numberWithDouble:[[data objectForKey:@"afternoonTotal"] doubleValue] + [meal.grams doubleValue]] forKey:@"afternoonTotal"];
            if(timePeriod == Evening) [data setObject:[NSNumber numberWithDouble:[[data objectForKey:@"eveningTotal"] doubleValue] + [meal.grams doubleValue]] forKey:@"eveningTotal"];
        }
        else if([event isKindOfClass:[UAReading class]])
        {
            UAReading *reading = (UAReading *)event;
            [data setObject:[NSNumber numberWithDouble:[[data objectForKey:@"readingsCount"] integerValue] + 1] forKey:@"readingsCount"];
            [data setObject:[NSNumber numberWithDouble:[[data objectForKey:@"readingsTotal"] doubleValue] + [reading.value doubleValue]] forKey:@"readingsTotal"];
        }
        
        [dictionary setObject:data forKey:key];
    }
    
    trendline = [[UALineFitCalculator alloc] init];
    double x = 0;
    for(NSString *key in dictionary)
    {
        NSDictionary *day = [dictionary objectForKey:key];
        double totalCarbs = [[day objectForKey:@"morningTotal"] doubleValue] + [[day objectForKey:@"afternoonTotal"] doubleValue] + [[day objectForKey:@"eveningTotal"] doubleValue];
        
        if(totalCarbs > 0)
        {
            [trendline addPoint:CGPointMake(x, totalCarbs)];
            x++;
            
            if(totalCarbs > [maxCarbRange doubleValue])
            {
                maxCarbRange = [NSNumber numberWithDouble:totalCarbs];
            }
            
            [formattedData addObject:[dictionary objectForKey:key]];
        }
    }
    
    minDate = [minDate dateAtStartOfDay];
    maxDate = [maxDate dateAtStartOfDay];
    
    // Stop a crash from occuring if our minDate equals our maxDate
    if([minDate isEqualToDate:maxDate])
    {
        maxDate = [maxDate dateByAddingDays:1];
    }
    
    return @{@"minDate": minDate, @"maxDate": maxDate, @"minCarbs": minCarbRange, @"maxCarbs": maxCarbRange, @"data": formattedData};
}
- (BOOL)hasEnoughDataToShowChart
{
    if([[chartData objectForKey:@"data"] count])
    {
        return YES;
    }
    
    return NO;
}
- (void)setupChart
{
    // Don't allow us to setup our chart more than once
    if(self.chart) return;
    
    if([[chartData objectForKey:@"data"] count])
    {
        self.chart = [[ShinobiChart alloc] initWithFrame:self.view.bounds];
        self.chart.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.chart.clipsToBounds = NO;
        self.chart.datasource = self;
        self.chart.delegate = self;
        self.chart.rotatesOnDeviceRotation = NO;
        self.chart.backgroundColor = [UIColor clearColor];
        self.chart.canvasAreaBackgroundColor = [UIColor clearColor];
        self.chart.plotAreaBackgroundColor = [UIColor clearColor];
        self.chart.borderThickness = [NSNumber numberWithDouble:1.0f];
        self.chart.gesturePinchAspectLock = YES;
        self.chart.crosshair = [[UAChartLineCrosshair alloc] initWithChart:self.chart];
        [self.chart applyTheme:[SChartLightTheme new]];
        
        //Double tap can either reset zoom or zoom in
        self.chart.gestureDoubleTapResetsZoom = YES;
        
        //Our xAxis is a category to take the discrete month data
        //SChartDateRange *dateRange = [[SChartDateRange alloc] initWithDateMinimum:[chartData objectForKey:@"minDate"] andDateMaximum:[chartData objectForKey:@"maxDate"]];
        SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] init];
        xAxis.enableGesturePanning = YES;
        xAxis.enableGestureZooming = YES;
        xAxis.enableMomentumPanning = YES;
        xAxis.enableMomentumZooming = YES;
        xAxis.allowPanningOutOfDefaultRange = NO;
        xAxis.allowPanningOutOfMaxRange = NO;
        xAxis.majorTickFrequency = [[SChartDateFrequency alloc] initWithDay:1];
        self.chart.xAxis = xAxis;
        
        //Use a custom range to best display our data
        SChartNumberRange *numberRange = [[SChartNumberRange alloc] initWithMinimum:[chartData objectForKey:@"minCarbs"] andMaximum:[chartData objectForKey:@"maxCarbs"]];
        SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:numberRange];
        yAxis.enableGesturePanning = YES;
        yAxis.enableGestureZooming = YES;
        yAxis.enableMomentumPanning = YES;
        yAxis.enableMomentumZooming = YES;
        yAxis.title = NSLocalizedString(@"Total Carbohydrates (grams)", nil);
        yAxis.style.titleStyle.position = SChartTitlePositionCenter;
        self.chart.yAxis = yAxis;
        
        [self.view insertSubview:self.chart belowSubview:closeButton];
    }
}

#pragma mark - SChartDataSource methods
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart
{
    return 4;
}
- (SChartSeries*)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)seriesIndex
{
    if(seriesIndex < 3)
    {
        SChartColumnSeries *barSeries = [SChartColumnSeries new];
        barSeries.stackIndex = @1; //(seriesIndex);
        return barSeries;
    }
    else if(seriesIndex == 3)
    {
        SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
        
        SChartLineSeriesStyle *style = [[SChartLineSeriesStyle alloc] init];
        style.showFill = NO;
        style.lineColor = [UIColor colorWithRed:186.0f/255.0f green:125.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        
        lineSeries.style = style;
        return lineSeries;
    }
    else if(seriesIndex == 4)
    {
        SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
        
        SChartLineSeriesStyle *style = [[SChartLineSeriesStyle alloc] init];
        style.showFill = NO;
        style.lineColor = [UIColor colorWithRed:186.0f/255.0f green:125.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        
        lineSeries.style = style;
        return lineSeries;
    }
    
    return nil;
}
- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex
{
    NSInteger dataPoints = [[chartData objectForKey:@"data"] count];
    if(seriesIndex == 3 && dataPoints > 1)
    {
        return 2;
    }
    
    return dataPoints;
}
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    SChartDataPoint *point = [[SChartDataPoint alloc] init];
    
    NSDictionary *info = (NSDictionary *)[[chartData objectForKey:@"data"] objectAtIndex:dataIndex];
    point.xValue = [info objectForKey:@"date"];
    
    if(seriesIndex == 0)
    {
        point.yValue = [info objectForKey:@"morningTotal"];
    }
    else if(seriesIndex == 1)
    {
        point.yValue = [info objectForKey:@"afternoonTotal"];
    }
    else if(seriesIndex == 2)
    {
        point.yValue = [info objectForKey:@"eveningTotal"];
    }
    else if(seriesIndex == 3)
    {
        if(dataIndex == 0)
        {
            point.xValue = [chartData objectForKey:@"minDate"];
            point.yValue = [NSNumber numberWithDouble:[trendline projectedYValueForX:[[chartData objectForKey:@"data"] count]-1]];
        }
        else
        {
            point.xValue = [chartData objectForKey:@"maxDate"];
            point.yValue = [NSNumber numberWithDouble:[trendline projectedYValueForX:0]];
        }
    }
    else if(seriesIndex == 4)
    {
        point.yValue = [NSNumber numberWithDouble:[[info objectForKey:@"readingsTotal"] doubleValue]/[[info objectForKey:@"readingsCount"] integerValue]];
    }
    
    return point;
}
- (SChartAxis *)sChart:(ShinobiChart *)chart yAxisForSeriesAtIndex:(NSInteger)seriesIndex
{
    if(seriesIndex == 4)
    {
        return [[chart allYAxes] lastObject];
    }
    return chart.yAxis;
}

@end
