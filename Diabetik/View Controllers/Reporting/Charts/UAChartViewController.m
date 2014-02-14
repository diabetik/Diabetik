//
//  UAChartViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/05/2013.
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

#import <QuartzCore/QuartzCore.h>
#import "UAChartViewController.h"

@implementation UAChartViewController

#pragma mark - Setup
- (id)initWithData:(NSArray *)theData
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Report", nil);
        
        chartData = [self parseData:theData];
    }
    return self;
}
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
    view.layer.cornerRadius = 3;
    view.layer.masksToBounds = YES;
    
    self.view = view;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
    
    if(!closeButton)
    {
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 60.0f, 20.0f, 40.0f, 40.0f)];
        [closeButton setImage:[UIImage imageNamed:@"AddEntryModalCloseIconiPad"] forState:UIControlStateNormal];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];
    }
}
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [self setupChart];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.chart.frame = CGRectInset(self.view.bounds, 15.0f, 15.0f);
}

#pragma mark - Logic
- (NSDictionary *)parseData:(NSArray *)theData
{
    return nil;
}
- (void)setupChart
{
    // STUB
}
- (BOOL)hasEnoughDataToShowChart
{
    return NO;
}
- (void)dismiss
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"pop-view"];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.bounds = self.initialRect;
        self.chart.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}

#pragma mark - Autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
