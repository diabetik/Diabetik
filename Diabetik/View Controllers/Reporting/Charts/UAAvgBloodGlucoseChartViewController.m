//
//  UAAvgBloodGlucoseChartViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/05/2013.
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

#import "UAAvgBloodGlucoseChartViewController.h"
#import "OrderedDictionary.h"
#import "UAChartLineCrosshair.h"

@interface UAAvgBloodGlucoseChartViewController ()
{
    double lowestReading;
}
@end

@implementation UAAvgBloodGlucoseChartViewController

#pragma mark - Chart logic
- (NSDictionary *)parseData:(NSArray *)theData
{
    NSDate *minDate = [NSDate distantFuture];
    NSDate *maxDate = [NSDate distantPast];
    
    lowestReading = 999999.0f;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSMutableArray *formattedData = [NSMutableArray array];
    OrderedDictionary *dictionary = [OrderedDictionary dictionary];
    for(UAEvent *event in theData)
    {
        if([event isKindOfClass:[UAReading class]])
        {
            if([event.timestamp isEarlierThanDate:minDate]) minDate = event.timestamp;
            if([event.timestamp isLaterThanDate:maxDate]) maxDate = event.timestamp;
            
            NSMutableDictionary *data = nil;
            NSString *key = [dateFormatter stringFromDate:event.timestamp];
            if(!(data = [dictionary objectForKey:key]))
            {
                data = [NSMutableDictionary dictionaryWithDictionary:@{@"date": event.timestamp, @"morningTotal": [NSNumber numberWithDouble:0.0], @"afternoonTotal": [NSNumber numberWithDouble:0.0], @"eveningTotal": [NSNumber numberWithDouble:0.0], @"readingsTotal": [NSNumber numberWithDouble:0.0], @"readingsCount": [NSNumber numberWithInteger:0]}];
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
    }
    
    for(NSString *key in dictionary)
    {
        NSDictionary *day = [dictionary objectForKey:key];
        double totalCarbs = [[day objectForKey:@"morningTotal"] doubleValue] + [[day objectForKey:@"afternoonTotal"] doubleValue] + [[day objectForKey:@"eveningTotal"] doubleValue];
        
        if(totalCarbs > 0)
        {
            [formattedData addObject:[dictionary objectForKey:key]];
        }
    }
    
    
    // Stop a crash from occuring if our minDate equals our maxDate
    if([minDate isEqualToDate:maxDate])
    {
        maxDate = [maxDate dateByAddingHours:1];
    }
    
    return @{@"minDate": minDate, @"maxDate": maxDate, @"data": formattedData};
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
        SChartDateRange *dateRange = [[SChartDateRange alloc] initWithDateMinimum:[chartData objectForKey:@"minDate"] andDateMaximum:[chartData objectForKey:@"maxDate"]];
        SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:dateRange];
        xAxis.enableGesturePanning = YES;
        xAxis.enableGestureZooming = YES;
        xAxis.enableMomentumPanning = YES;
        xAxis.enableMomentumZooming = YES;
        xAxis.allowPanningOutOfDefaultRange = NO;
        xAxis.allowPanningOutOfMaxRange = NO;
        self.chart.xAxis = xAxis;
        
        //Use a custom range to best display our data
        NSInteger userUnit = [UAHelper userBGUnit];
        NSNumber *gloodRangeMin = [UAHelper convertBGValue:[NSNumber numberWithFloat:lowestReading] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        NSNumber *gloodRangeMax = [UAHelper convertBGValue:[NSNumber numberWithFloat:25.0f] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        
        SChartNumberRange *r = [[SChartNumberRange alloc] initWithMinimum:gloodRangeMin andMaximum:gloodRangeMax];
        SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:r];
        yAxis.enableGesturePanning = YES;
        yAxis.enableGestureZooming = YES;
        yAxis.enableMomentumPanning = YES;
        yAxis.enableMomentumZooming = YES;
        yAxis.rangePaddingHigh = [NSNumber numberWithFloat:0.25f];
        yAxis.rangePaddingLow = [NSNumber numberWithFloat:0.25f];
        yAxis.title = NSLocalizedString(@"Blood Glucose Level", nil);
        yAxis.style.titleStyle.position = SChartTitlePositionCenter;
        self.chart.yAxis = yAxis;
        
        [self.view insertSubview:self.chart belowSubview:closeButton];
    }
}

#pragma mark - SChartDataSource methods
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart
{
    return 2;
}
- (SChartSeries*)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)seriesIndex
{
    SChartSeries *series = nil;
    
    if(seriesIndex == 0)
    {
        SChartBandSeries *bandSeries = [SChartBandSeries new];
        
        SChartBandSeriesStyle *style = [[SChartBandSeriesStyle alloc] init];
        style.lineWidth = [NSNumber numberWithDouble:1.0f];
        style.lineColorLow = [UIColor colorWithRed:199.0f/255.0f green:217.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
        style.lineColorHigh = [UIColor colorWithRed:199.0f/255.0f green:217.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
        style.areaColorNormal = [UIColor colorWithRed:199.0f/255.0f green:217.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
        bandSeries.style = style;
        
        series = bandSeries;
    }
    else if(seriesIndex == 1)
    {
        SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
        lineSeries.selectionMode = SChartSelectionPoint;
        lineSeries.togglePointSelection = YES;
        lineSeries.crosshairEnabled = YES;
        
        SChartPointStyle *pointStyle = [[SChartPointStyle alloc] init];
        pointStyle.innerColor = [UIColor whiteColor];
        pointStyle.color = [UIColor colorWithRed:254.0f/255.0f green:110.0f/255.0f blue:116.0f/255.0f alpha:1.0f];
        pointStyle.showPoints = YES;
        
        SChartLineSeriesStyle *style = [[SChartLineSeriesStyle alloc] init];
        style.showFill = NO;
        style.areaLineColor = [UIColor colorWithRed:254.0f/255.0f green:110.0f/255.0f blue:116.0f/255.0f alpha:1.0f];
        style.lineColor = [UIColor colorWithRed:254.0f/255.0f green:110.0f/255.0f blue:116.0f/255.0f alpha:1.0f];
        style.areaColor  = [UIColor colorWithRed:254.0f/255.0f green:110.0f/255.0f blue:116.0f/255.0f alpha:1.0f];
        style.fillWithGradient = NO;
        style.lineCrosshairTraceStyle = SChartLineCrosshairTraceStyleHorizontal;
        style.lineWidth = [NSNumber numberWithDouble:3.0f];
        style.areaLineWidth = [NSNumber numberWithDouble:3.0f];
        style.pointStyle = pointStyle;
        
        lineSeries.style = style;
        series = lineSeries;
    }
    
    return series;
}
- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex
{
    NSInteger dataPoints = [[chartData objectForKey:@"data"] count];
    if(seriesIndex == 2)
    {
        return 2;
    }
    
    return dataPoints;
}
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    SChartMultiYDataPoint *multiPoint = [[SChartMultiYDataPoint alloc] init];
    
    UAReading *reading = (UAReading *)[[chartData objectForKey:@"data"] objectAtIndex:dataIndex];
    multiPoint.xValue = reading.timestamp;
    
    if(seriesIndex == 0)
    {
        NSInteger userUnit = [UAHelper userBGUnit];
        
        double min = [[[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyBGKey] doubleValue];
        double max = [[[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyBGKey] doubleValue];
        
        NSNumber *minimumHealthy = (min < lowestReading && lowestReading < max) ? [NSNumber numberWithDouble:lowestReading] : [[NSUserDefaults standardUserDefaults] valueForKey:kMinHealthyBGKey];
        NSNumber *healthyRangeMin = [UAHelper convertBGValue:minimumHealthy fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        NSNumber *healthyRangeMax = [UAHelper convertBGValue:[[NSUserDefaults standardUserDefaults] valueForKey:kMaxHealthyBGKey] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        
        [multiPoint.yValues setValue:healthyRangeMin forKey:@"Low"];
        [multiPoint.yValues setValue:healthyRangeMax forKey:@"High"];
        
        return multiPoint;
    }
    else if(seriesIndex == 1)
    {
        multiPoint.yValue = reading.value;
        
        return multiPoint;
    }
    
    return nil;
}


@end
