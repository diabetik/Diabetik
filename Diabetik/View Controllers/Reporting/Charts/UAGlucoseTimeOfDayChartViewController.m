//
//  UAGlucoseTimeOfDayChartViewController.m
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

#import "UAGlucoseTimeOfDayChartViewController.h"
#import "UAChartLineCrosshair.h"
#import "UALeastSquareFitCalculator.h"

@interface UAGlucoseTimeOfDayChartViewController ()
{
    UALineFitCalculator *trendline;
    
    double lowestReading;
}
@end

@implementation UAGlucoseTimeOfDayChartViewController

#pragma mark - Chart logic
- (NSDictionary *)parseData:(NSArray *)theData
{
    NSDate *minDate = [NSDate distantFuture];
    NSDate *maxDate = [NSDate distantPast];
    
    lowestReading = 999999.0f;
    
    NSMutableArray *formattedData = [NSMutableArray array];
    for(UAEvent *event in theData)
    {
        if([event isKindOfClass:[UAReading class]])
        {
            if([event.timestamp isEarlierThanDate:minDate]) minDate = event.timestamp;
            if([event.timestamp isLaterThanDate:maxDate]) maxDate = event.timestamp;
            
            UAReading *reading = (UAReading *)event;
            if(lowestReading > [reading.mmoValue doubleValue])
            {
                lowestReading = [reading.mmoValue doubleValue];
            }
            
            [formattedData addObject:event];
        }
    }
    
    trendline = [[UALineFitCalculator alloc] init];
    double x = 0;
    for(NSInteger i = formattedData.count-1; i >= 0; i--)
    {
        UAReading *reading = (UAReading *)[formattedData objectAtIndex:i];
        [trendline addPoint:CGPointMake(x, [[reading value] doubleValue])];
        x++;
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
    if([[chartData objectForKey:@"data"] count] >= 2)
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
        //self.chart.gesturePinchAspectLock = YES;
        self.chart.crosshair = [[UAChartLineCrosshair alloc] initWithChart:self.chart];
        [self.chart applyTheme:[SChartLightTheme new]];
        
        //Double tap can either reset zoom or zoom in
        self.chart.gestureDoubleTapResetsZoom = YES;
        
        NSDate *minDate = [NSDate dateWithYear:nil month:nil day:nil hour:@0 minute:@0 seconds:@0];
        NSDate *maxDate = [NSDate dateWithYear:nil month:nil day:nil hour:@23 minute:@59 seconds:@59];
        
        //Our xAxis is a category to take the discrete month data
        SChartDateRange *xAxisRange = [[SChartDateRange alloc] initWithDateMinimum:minDate andDateMaximum:maxDate];
        SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:xAxisRange];
        //xAxis.majorTickFrequency = [[SChartDateFrequency alloc] initWithHour:1];
        xAxis.labelFormatter = [SChartTickLabelFormatter dateFormatter];
//        [xAxis.labelFormatter.dateFormatter setDateFormat:@"HH:mm"];
        [xAxis.labelFormatter.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        xAxis.anchorPoint = minDate;
        xAxis.enableGesturePanning = YES;
        xAxis.enableGestureZooming = YES;
        xAxis.enableMomentumPanning = YES;
        xAxis.enableMomentumZooming = YES;
        xAxis.allowPanningOutOfDefaultRange = NO;
        xAxis.allowPanningOutOfMaxRange = NO;
        xAxis.style.titleStyle.position = SChartTitlePositionCenter;
        self.chart.xAxis = xAxis;
        
        // Use a custom range to best display our data
        NSInteger userUnit = [UAHelper userBGUnit];
        NSNumber *gloodRangeMin = [UAHelper convertBGValue:[NSNumber numberWithFloat:lowestReading] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        NSNumber *gloodRangeMax = [UAHelper convertBGValue:[NSNumber numberWithFloat:25.0f] fromUnit:BGTrackingUnitMMO toUnit:userUnit];
        
        SChartNumberRange *yAxisRange = [[SChartNumberRange alloc] initWithMinimum:gloodRangeMin andMaximum:gloodRangeMax];
        SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:yAxisRange];
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
    NSInteger dataPoints = [[chartData objectForKey:@"data"] count];
    
    return dataPoints > 1 ? 2 : 1;
}
- (SChartSeries*)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)seriesIndex
{
    SChartSeries *series = nil;
    
    if(seriesIndex == 0)
    {
        SChartScatterSeries *scatterSeries = [[SChartScatterSeries alloc] init];
        scatterSeries.selectionMode = SChartSelectionPoint;
        scatterSeries.togglePointSelection = YES;
        scatterSeries.crosshairEnabled = YES;
        
        SChartPointStyle *pointStyle = [[SChartPointStyle alloc] init];
        pointStyle.innerColor = [UIColor whiteColor];
        pointStyle.color = [UIColor colorWithRed:254.0f/255.0f green:110.0f/255.0f blue:116.0f/255.0f alpha:1.0f];
        pointStyle.showPoints = YES;
        
//        scatterSeries.style = pointStyle;
        series = scatterSeries;
    }
    else if(seriesIndex == 1)
    {
        SChartBandSeries *bandSeries = [SChartBandSeries new];
        
        UIColor *color = [UIColor colorWithRed:24.0f/255.0f green:197.0f/255.0f blue:186.0f/255.0f alpha:0.85f];
        
        SChartBandSeriesStyle *style = [[SChartBandSeriesStyle alloc] init];
        style.lineWidth = [NSNumber numberWithDouble:1.0f];
        style.lineColorLow = color;
        style.lineColorHigh = color;
        style.areaColorNormal = color;
        bandSeries.style = style;
        
        series = bandSeries;
    }
    
    return series;
}
- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex
{
    NSInteger dataPoints = [[chartData objectForKey:@"data"] count];
    return dataPoints;
}
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    SChartMultiYDataPoint *multiPoint = [[SChartMultiYDataPoint alloc] init];
    
    UAReading *reading = (UAReading *)[[chartData objectForKey:@"data"] objectAtIndex:dataIndex];
    multiPoint.xValue = [NSDate dateWithYear:nil month:nil day:nil hour:@([reading.timestamp hour]) minute:@([reading.timestamp minute]) seconds:@([reading.timestamp seconds])];
    
    if(seriesIndex == 0)
    {
        multiPoint.yValue = reading.value;
        
        return multiPoint;
    }
    else if(seriesIndex == 1)
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
    
    return nil;
}

@end
