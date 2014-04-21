//
//  UAReportsViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/05/2013.
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

#import "UAReportsViewController.h"
#import "UAReportPreviewView.h"
#import "UADateButton.h"

#import "UAGlucoseLineChartViewController.h"
#import "UAGlucoseTimeOfDayChartViewController.h"
#import "UAGlucoseDonutChartViewController.h"
#import "UAGlucoseCandlestickChartViewController.h"
#import "UACarbsChartViewController.h"

@interface UAReportsViewController ()
{
    NSArray *reports;
    NSArray *reportData;
    
    NSDateFormatter *dateFormatter;
    NSDate *toDate, *fromDate;
    
    UADateButton *fromDateButton, *toDateButton;
    UILabel *dateRangeLabel, *dateRangeToLabel;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
}
@property (nonatomic, strong) UIButton *closeButton;

// Logic
- (void)dismiss;

@end

@implementation UAReportsViewController

#pragma mark - Setup
- (id)initFromDate:(NSDate *)aFromDate toDate:(NSDate *)aToDate;
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        // If we're passed invalid dates, default to the current month
        if(!aFromDate) aFromDate = [[NSDate date] dateAtStartOfMonth];
        if(!aToDate) aToDate = [[NSDate date] dateAtEndOfMonth];
        
        fromDate = aFromDate;
        toDate = aToDate;
        reportData = nil;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        [self fetchReportData];
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    reports = @[
                @{@"title": NSLocalizedString(@"Blood Glucose Readings", nil), @"description": NSLocalizedString(@"A line chart showing your blood glucose and general trend over a given period", nil), @"class": [UAGlucoseLineChartViewController class]},
                @{@"title": NSLocalizedString(@"Time-of-Day Glucose Readings", nil), @"description": NSLocalizedString(@"A scatter chart showing blood glucose levels during different time segments", nil), @"class": [UAGlucoseTimeOfDayChartViewController class]},
                @{@"title": NSLocalizedString(@"Daily Blood Glucose Ranges", nil), @"description": NSLocalizedString(@"A candlestick chart showing your first, last, lowest and highest glucose readings per day", nil), @"class": [UAGlucoseCandlestickChartViewController class]},
                @{@"title": NSLocalizedString(@"Carbohydrate in-take", nil), @"description": NSLocalizedString(@"A stacked bar chart (segmented by morning, afternoon and evening) showing total carbohydrate in-take per day", nil), @"class": [UACarbsChartViewController class]},
                @{@"title": NSLocalizedString(@"Healthy Glucose Tally", nil), @"description": NSLocalizedString(@"A pie chart showing the number of healthy glucose readings versus unhealthy over a given period", nil), @"class": [UAGlucoseDonutChartViewController class]}
                ];

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    pageControl.numberOfPages = [reports count];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:69.0f/255.0f green:77.0f/255.0f blue:74.0f/255.0f alpha:0.4];
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:69.0f/255.0f green:77.0f/255.0f blue:74.0f/255.0f alpha:0.12];
    [self.view addSubview:pageControl];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.closeButton setImage:[UIImage imageNamed:@"AddEntryModalCloseIconiPad"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.closeButton];
    }
    
    CGFloat y = 35.0f;
    dateRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, 300.0f, 18.0f)];
    dateRangeLabel.backgroundColor = [UIColor clearColor];
    dateRangeLabel.textColor = [UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    dateRangeLabel.font = [UAFont standardDemiBoldFontWithSize:14.0f];
    dateRangeLabel.text = NSLocalizedString(@"Reporting events between", nil);
    [self.view addSubview:dateRangeLabel];
    
    dateRangeToLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, 300.0f, 18.0f)];
    dateRangeToLabel.backgroundColor = [UIColor clearColor];
    dateRangeToLabel.textColor = [UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    dateRangeToLabel.font = [UAFont standardDemiBoldFontWithSize:14.0f];
    dateRangeToLabel.text = NSLocalizedString(@"and", nil);
    [self.view addSubview:dateRangeToLabel];
    
    fromDateButton = [[UADateButton alloc] initWithFrame:CGRectMake(10.0f, y-6.0f, 100.0f, 30.0f)];
    [fromDateButton setTitle:[dateFormatter stringFromDate:fromDate] forState:UIControlStateNormal];
    [fromDateButton addTarget:self action:@selector(setDateForReportRange:) forControlEvents:UIControlEventTouchUpInside];
    [fromDateButton setTag:0];
    [self.view addSubview:fromDateButton];
    
    toDateButton = [[UADateButton alloc] initWithFrame:CGRectMake(10.0f, y-6.0f, 100.0f, 30.0f)];
    [toDateButton setTitle:[dateFormatter stringFromDate:toDate] forState:UIControlStateNormal];
    [toDateButton addTarget:self action:@selector(setDateForReportRange:) forControlEvents:UIControlEventTouchUpInside];
    [toDateButton setTag:1];
    [self.view addSubview:toDateButton];
    
    for(NSInteger i = 0; i < [reports count]; i++)
    {
        NSDictionary *info = [reports objectAtIndex:i];
        
        UAReportPreviewView *reportPreview = [[UAReportPreviewView alloc] initWithFrame:CGRectZero andInfo:info];
        [reportPreview setTag:i];
        [reportPreview addTarget:self action:@selector(didSelectReport:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:reportPreview];
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutReports];
    
    NSInteger reportKey = [[NSUserDefaults standardUserDefaults] integerForKey:kReportsDefaultKey];
    if(reportKey < 0) reportKey = 0;
    if(reportKey > [reports count]-1) reportKey = [reports count]-1;
    
    [scrollView setContentOffset:CGPointMake(self.view.bounds.size.width*reportKey, 0.0f) animated:NO];
    [pageControl setCurrentPage:reportKey];
    
    NSDictionary *chartInfo = [reports objectAtIndex:reportKey];
    if(chartInfo)
    {
        Class chartClass = (Class)[chartInfo objectForKey:@"class"];
        
        UAChartViewController *chartVC = [(UAChartViewController *)[chartClass alloc] initWithData:reportData];
        chartVC.view.frame = self.view.bounds;
        
        for(UIView *subview in scrollView.subviews)
        {
            if(subview.tag == reportKey)
            {
                chartVC.initialRect = [scrollView convertRect:subview.frame toView:self.view];
                break;
            }
        }
        if([chartVC hasEnoughDataToShowChart])
        {
            [chartVC willMoveToParentViewController:self];
            [self addChildViewController:chartVC];
            chartVC.view.bounds = self.view.bounds;
            chartVC.chart.alpha = 1.0f;
            [self.view addSubview:chartVC.view];
            [chartVC didMoveToParentViewController:self];
        }
    }
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutReports];
}

#pragma mark - Logic
- (void)fetchReportData
{
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSDate *fetchFromDate = [fromDate dateAtStartOfDay];
        NSDate *fetchToDate = [toDate dateAtEndOfDay];
        
        if(fetchFromDate)
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAEvent" inManagedObjectContext:moc];
            [fetchRequest setEntity:entity];
            [fetchRequest setFetchBatchSize:20];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor];
            [fetchRequest setSortDescriptors:sortDescriptors];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"timestamp >= %@ && timestamp <= %@", fetchFromDate, fetchToDate]];
            
            NSError *error = nil;
            reportData = [moc executeFetchRequest:fetchRequest error:&error];
            
            if(error)
            {
                reportData = nil;
            }
        }
    }
}
- (void)layoutReports
{
    CGFloat x = 0.0f;
    for(UIView *view in scrollView.subviews)
    {
        view.frame = CGRectMake(x + (self.view.bounds.size.width/2.0f - 300.0f/2.0f), self.view.bounds.size.height/2.0f - 151.0f/2.0f, 300.0f, 151.0f);
        
        x += self.view.bounds.size.width;
    }
    
    scrollView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length);
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*[reports count], self.view.bounds.size.height);
    pageControl.frame = CGRectMake(0.0f, self.view.bounds.size.height - 55.0f, self.view.bounds.size.width, 25.0f);
    
    
    if(self.closeButton)
    {
        self.closeButton.frame = CGRectMake(self.view.bounds.size.width - 40.0f - 20.0f, 20.0f, 40.0f, 40.0f);
    }
    
    fromDateButton.frame = CGRectMake(fromDateButton.frame.origin.x, fromDateButton.frame.origin.y, [fromDateButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: fromDateButton.titleLabel.font}].width+20.0f, fromDateButton.frame.size.height);
    toDateButton.frame = CGRectMake(toDateButton.frame.origin.x, toDateButton.frame.origin.y, [toDateButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: toDateButton.titleLabel.font}].width+20.0f, toDateButton.frame.size.height);
    
    CGFloat width = [dateRangeLabel.text sizeWithAttributes:@{NSFontAttributeName: dateRangeLabel.font}].width;
    width += 5.0f + fromDateButton.bounds.size.width;
    width += 5.0f + [dateRangeToLabel.text sizeWithAttributes:@{NSFontAttributeName: dateRangeToLabel.font}].width;
    width += 5.0f + toDateButton.bounds.size.width;
    
    x = ceilf(self.view.bounds.size.width/2.0f - width/2.0f);
    dateRangeLabel.frame = CGRectMake(x, dateRangeLabel.frame.origin.y, [dateRangeLabel.text sizeWithAttributes:@{NSFontAttributeName: dateRangeLabel.font}].width, dateRangeLabel.frame.size.height);
    
    x += ceilf(dateRangeLabel.bounds.size.width + 5.0f);
    fromDateButton.frame = CGRectMake(x, fromDateButton.frame.origin.y, fromDateButton.frame.size.width, fromDateButton.frame.size.height);
    
    x += ceilf(fromDateButton.bounds.size.width + 5.0f);
    dateRangeToLabel.frame = CGRectMake(x, dateRangeToLabel.frame.origin.y, [dateRangeToLabel.text sizeWithAttributes:@{NSFontAttributeName: dateRangeToLabel.font}].width, dateRangeToLabel.frame.size.height);
    
    x += ceilf(dateRangeToLabel.bounds.size.width + 5.0f);
    toDateButton.frame = CGRectMake(x, toDateButton.frame.origin.y, toDateButton.frame.size.width, toDateButton.frame.size.height);
}
- (void)didSelectReport:(UIButton *)previewButton
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    NSDictionary *chartInfo = [reports objectAtIndex:previewButton.tag];
    if(chartInfo)
    {
        CGRect initialRect = [scrollView convertRect:previewButton.frame toView:self.view];
        
        Class chartClass = (Class)[chartInfo objectForKey:@"class"];
        UAChartViewController *chartVC = [(UAChartViewController *)[chartClass alloc] initWithData:reportData];
        chartVC.view.frame = initialRect;
        chartVC.initialRect = initialRect;
        
        if([chartVC hasEnoughDataToShowChart])
        {
            [chartVC willMoveToParentViewController:self];
            [self addChildViewController:chartVC];
            chartVC.chart.alpha = 0.0f;        
            [self.view addSubview:chartVC.view];
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                chartVC.view.bounds = self.view.bounds;
                chartVC.chart.alpha = 1.0f;
            } completion:^(BOOL finished) {
                [chartVC didMoveToParentViewController:self];
            }];
            
            [[NSUserDefaults standardUserDefaults] setInteger:previewButton.tag forKey:kReportsDefaultKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not enough data", nil) message:NSLocalizedString(@"You haven't collected enough data to display this report", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", nil) otherButtonTitles:nil];
            [alertView show];
        }
    }
}
- (void)setDateForReportRange:(UIButton *)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UADatePickerController *datePicker = [[UADatePickerController alloc] initWithFrame:self.view.bounds andDate:(sender.tag == 0 ? fromDate : toDate)];
    datePicker.delegate = self;
    datePicker.tag = sender.tag;
    [datePicker present];
    [self.view addSubview:datePicker];
}
- (void)dismiss
{
    BOOL animated = NO;// (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    [self dismissViewControllerAnimated:animated completion:^{
        [self.delegate didDismissReportsController:self];
    }];
}

#pragma mark - UADatePickerDelegate methods
- (void)datePicker:(UADatePickerController *)controller didSelectDate:(NSDate *)date
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"success"];
    
    if(controller.tag == 0)
    {
        fromDate = date;
        [fromDateButton setTitle:[dateFormatter stringFromDate:fromDate] forState:UIControlStateNormal];
    }
    else
    {
        toDate = date;
        [toDateButton setTitle:[dateFormatter stringFromDate:toDate] forState:UIControlStateNormal];
    }
    
    [self.view setNeedsLayout];
    [self fetchReportData];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    NSInteger page = aScrollView.contentOffset.x/self.view.bounds.size.width;
    if(page < 0) page = 0;
    if(page > [reports count]) page = [reports count];
    
    pageControl.currentPage = page;
}

#pragma mark - Autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        {
            if([self.delegate shouldDismissReportsOnRotation:self])
            {
                [self dismiss];
            }
        }
    }
    else
    {
        [UIView animateWithDuration:0.1 animations:^{
            scrollView.alpha = 0.0f;
            pageControl.alpha = 0.0f;
        }];
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self layoutReports];
        [scrollView setContentOffset:CGPointMake(self.view.bounds.size.width*pageControl.currentPage, 0.0f) animated:NO];
        
        [UIView animateWithDuration:0.1 animations:^{
            scrollView.alpha = 1.0f;
            pageControl.alpha = 1.0f;
        }];
    }
}

#pragma mark - UIViewController methods
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
