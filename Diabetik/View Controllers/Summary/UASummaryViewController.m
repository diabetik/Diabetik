//
//  UASummaryViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "NSDate+Extension.h"
#import "FXBlurView.h"

#import "UASummaryCollectionViewFlowLayout.h"
#import "UASummaryViewController.h"
#import "UAEventController.h"

#import "UASummaryWidgetViewCell.h"
#import "UASummaryWidget.h"
#import "UASummaryIntroductionWidget.h"

@interface UASummaryViewController ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableArray *widgets;
@property (nonatomic, assign) NSInteger numberOfDays;
@end

@implementation UASummaryViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.widgets = [NSMutableArray array];
        
        for(int i = 0; i < 5; i++)
        {
            UASummaryIntroductionWidget *w = [[UASummaryIntroductionWidget alloc] init];
            w.label.text = [NSString stringWithFormat:@"%i", i];
            [self.widgets addObject:w];
        }
        
        //self.numberOfDays = 90;
        //[self analyse];
    }
    return self;
}
- (void)loadView
{
    FXBlurView *view = [[FXBlurView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.tintColor = [UIColor blackColor];
    view.dynamic = NO;
    view.blurRadius = 15.0f;
    
    self.view = view;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UASummaryCollectionViewFlowLayout *layout = [[UASummaryCollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[UASummaryWidgetViewCell class] forCellWithReuseIdentifier:@"widget"];
    [self.collectionView reloadData];
    
    self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.addButton setBackgroundImage:[UIImage imageNamed:@"AddEntryModalCloseIconiPad"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.collectionView.frame = self.view.bounds;
    self.addButton.frame = CGRectMake(self.view.bounds.size.width/2.0f-40.0f/2.0f, self.view.bounds.size.height-60.0f, 40.0f, 40.0f);
}

#pragma mark - Presentation logic
- (void)presentInViewController:(UIViewController *)parentVC
{
    self.view.alpha = 0.0f;
    
    [self willMoveToParentViewController:parentVC];
    self.view.frame = parentVC.view.bounds;
    //[(FXBlurView *)summaryVC.view setUnderlyingView:self.navigationController.view];
    [parentVC.view addSubview:self.view];
    [parentVC addChildViewController:self];
    [self didMoveToParentViewController:parentVC];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(self.view.bounds.size.height, 0.0f, 0.0f, 0.0f);
    [UIView animateWithDuration:0.15 animations:^{
        self.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
//        self.collectionView.frame = self.view.bounds;
    }];
    
    [UIView animateWithDuration:0.5 delay:0.075 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)dismiss
{
    UASummaryViewController *weakRef = self;
    [weakRef willMoveToParentViewController:nil];
    [weakRef.view removeFromSuperview];
    [weakRef removeFromParentViewController];
}

#pragma mark - UICollectionViewDelegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UASummaryWidget *widget = self.widgets[indexPath.row];
    [widget setShowingSettings:!widget.showingSettings];
}

#pragma mark - UICollectionViewDatasource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.widgets count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UASummaryWidgetViewCell *cell = (UASummaryWidgetViewCell *)[aCollectionView dequeueReusableCellWithReuseIdentifier:@"widget" forIndexPath:indexPath];
    [cell setWidget:self.widgets[indexPath.row]];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UASummaryWidget *widget = self.widgets[indexPath.row];
    return CGSizeMake(collectionView.bounds.size.width, widget.height);
}

#pragma mark - Logic
- (void)analyse
{
    NSDate *date = [[NSDate date] dateBySubtractingDays:self.numberOfDays];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType = %@ AND timestamp >= %@", @(ReadingFilterType), date];
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    NSArray *readings = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate
                                                                     sortDescriptors:nil
                                                                           inContext:moc];
    
    NSMutableArray *hourBreakdown = [NSMutableArray array];
    for(NSInteger i = 0; i < 24; i++)
    {
        [hourBreakdown addObject:@{@"total": @0, @"count": @0}];
    }
    
    if(readings)
    {
        double totalOfValues = 0;
        for(UAReading *reading in readings)
        {
            NSInteger hour = [[reading timestamp] hour];
            NSNumber *value = [reading mgValue];
            totalOfValues += [value doubleValue];
            
            if(hourBreakdown[hour])
            {
                NSNumber *totalValue = [NSNumber numberWithDouble:[hourBreakdown[hour][@"total"] doubleValue] + [value doubleValue]];
                NSNumber *count = [NSNumber numberWithInteger:[hourBreakdown[hour][@"count"] integerValue]+1];
                hourBreakdown[hour] = @{@"total": totalValue, @"count": count};
            }
            
            [moc refreshObject:reading mergeChanges:YES];
        }
        
        // Calculate HbA1C
        double avgReading = totalOfValues/[readings count];
        double b = avgReading+46.7;
        double c = 28.7;
        double d = b/c*100;
        double a1c = floor(d)/100;
        
        NSLog(@"AVG: %f", [[UAHelper convertBGValue:@(avgReading) fromUnit:BGTrackingUnitMG toUnit:[UAHelper userBGUnit]] doubleValue]);
        NSLog(@"A1C %f%%", a1c);
        
        // Calculate hourly breakdown
        NSMutableArray *hourlySummary = [NSMutableArray array];
        NSInteger hourIncrements = 4;
        for(NSInteger i = 0; i < 24; i+=hourIncrements)
        {
            double totalValue = 0;
            NSInteger countTotal = 0;
            for(NSInteger h = 0; h < hourIncrements; h++)
            {
                // Are we outside the 24-hour bounds?
                if(i+h >= 24) break;
                
                totalValue += [hourBreakdown[i+h][@"total"] doubleValue];
                countTotal += [hourBreakdown[i+h][@"count"] integerValue];
            }
            
            NSInteger hourTo = i+hourIncrements;
            if(hourTo > 23) hourTo = 23;
            
            NSDictionary *summary = @{@"from": @(i), @"to": @(hourTo), @"avg": @(totalValue/countTotal), @"total": @(countTotal)};
            [hourlySummary addObject:summary];
        }
        NSLog(@"%@", hourlySummary);
    }
    
    /*
     NSMutableArray *hourArray = [NSMutableArray arrayWithCapacity:24];
     for(UAEvent *event in self.data)
     {
     NSInteger hour = [[event timestamp] hour];
     
     NSLog(@"%d", hour);
     NSMutableDictionary *breakdown = [NSMutableDictionary dictionaryWithDictionary:@{@"readingTotal": @0, @"readingCount": @0, @"carbsTotal": @0, @"carbsCount": @0}];
     if(hourArray[hour])
     {
     breakdown = hourArray[hour];
     }
     
     if([event isKindOfClass:[UAReading class]])
     {
     breakdown[@"readingsCount"] = @([breakdown[@"readingsCount"] integerValue]+1);
     }
     else if([event isKindOfClass:[UAMeal class]])
     {
     breakdown[@"carbsTotal"] = @([breakdown[@"carbsTotal"] integerValue]+1);
     }
     
     hourArray[hour] = breakdown;
     }
     
     NSLog(@"%@", hourArray);
     */
}

#pragma mark - LXReorderableCollectionViewDataSource methods
- (void)collectionView:(UICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
   willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    id object = [self.widgets objectAtIndex:fromIndexPath.item];
    [self.widgets removeObjectAtIndex:fromIndexPath.item];
    [self.widgets insertObject:object atIndex:toIndexPath.item];
}

@end