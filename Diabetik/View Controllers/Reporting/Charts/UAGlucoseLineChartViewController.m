//
//  UAGlucoseLineChartViewController.m
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

#import "UAGlucoseLineChartViewController.h"
#import "UAChartLineCrosshair.h"
#import "UALeastSquareFitCalculator.h"

@interface UAGlucoseLineChartViewController ()
{
    UALineFitCalculator *trendline;
    
    double lowestReading;
}
@end

@implementation UAGlucoseLineChartViewController

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
    NSInteger dataPoints = [[chartData objectForKey:@"data"] count];
    
    return dataPoints > 1 ? 3 : 2;
}
- (SChartSeries*)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)seriesIndex
{
    SChartSeries *series = nil;
    
    if(seriesIndex == 0)
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
    else if(seriesIndex == 1)
    {
        SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
        
        SChartLineSeriesStyle *style = [[SChartLineSeriesStyle alloc] init];
        style.showFill = NO;
        style.lineColor = [UIColor colorWithRed:186.0f/255.0f green:125.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        
        lineSeries.style = style;
        
        series = lineSeries;
    }
    else if(seriesIndex == 2)
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
    if(seriesIndex == 1)
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
        multiPoint.yValue = reading.value;
        
        return multiPoint;
    }
    else if(seriesIndex == 1)
    {
        UAReading *reading = nil;
        if(dataIndex == 0)
        {
            reading = (UAReading *)[[chartData objectForKey:@"data"] objectAtIndex:0];
            multiPoint.yValue = [NSNumber numberWithDouble:[trendline projectedYValueForX:[[chartData objectForKey:@"data"] count]-1]];
        }
        else
        {
            reading = (UAReading *)[[chartData objectForKey:@"data"] lastObject];
            multiPoint.yValue = [NSNumber numberWithDouble:[trendline projectedYValueForX:0]];
        }
        multiPoint.xValue = reading.timestamp;
        
        return multiPoint;
    }
    else if(seriesIndex == 2)
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
