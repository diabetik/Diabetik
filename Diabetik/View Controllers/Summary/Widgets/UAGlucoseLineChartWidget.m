//
//  UAGlucoseLineChartWidget.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/04/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UAGlucoseLineChartWidget.h"
#import "UAGlucoseLineChartViewController.h"

@interface UAGlucoseLineChartWidget ()
@property (nonatomic, strong) UAGlucoseLineChartViewController *lineChartVC;
@end

@implementation UAGlucoseLineChartWidget

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.widgetContentView.frame = self.bounds;
}

#pragma mark - Logic
- (void)update
{
    [super update];
    
    if(self.lineChartVC) return;
    
    NSDate *date = [[NSDate date] dateBySubtractingDays:90];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType = %@ AND timestamp >= %@", @(ReadingFilterType), date];
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] newPrivateContext];
    if(moc)
    {
        __weak typeof(self) weakSelf = self;
        [moc performBlockAndWait:^{
            
            NSArray *readings = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate
                                                                             sortDescriptors:nil
                                                                                   inContext:moc];
            NSLog(@"%@", readings);
            self.lineChartVC = [[UAGlucoseLineChartViewController alloc] initWithData:readings];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                //[self.lineChartVC willMoveToParentViewController:self.pare];
                [self.widgetContentView addSubview:self.lineChartVC.view];
                [self.lineChartVC setupChart];
                [strongSelf.activityIndicatorView stopAnimating];
            });
        }];
    }
    
    [self.activityIndicatorView stopAnimating];
}
- (CGFloat)height
{
    return 300.0f;
}

@end
