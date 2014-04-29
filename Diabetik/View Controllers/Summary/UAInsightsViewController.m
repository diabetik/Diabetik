//
//  UAInsightsViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
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

#import "NSDate+Extension.h"
#import "FXBlurView.h"

#import "UAInsightsViewController.h"
#import "UAEventController.h"

#import "UASummaryCollectionViewCell.h"
#import "UASummaryWidget.h"

@interface UAInsightsViewController ()
{
}
@property (nonatomic, strong) UASummaryWidgetListViewController *widgetListVC;
@property (nonatomic, assign) BOOL inEditMode;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *closeButton, *addButton, *removeButton;
@property (nonatomic, strong) NSMutableArray *widgets;
@property (nonatomic, assign) NSInteger numberOfDays;

// Logic
- (void)loadWidgets;
- (void)saveWidgets;

// Helpers
- (NSString *)applicationSupportDirectoryPath;

@end

@implementation UAInsightsViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _inEditMode = NO;
        self.widgets = [NSMutableArray array];
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
    
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    //UASummaryCollectionViewFlowLayout *layout = [[UASummaryCollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[UASummaryCollectionViewCell class] forCellWithReuseIdentifier:@"widget"];
    [self.collectionView reloadData];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"AddEntryModalCloseIconiPad"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.addButton setBackgroundImage:[UIImage imageNamed:@"AddEntryModalCloseIconiPad"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(showAddWidgetScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    self.removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [self.removeButton setBackgroundImage:[UIImage imageNamed:@"AddEntryModalCloseIconiPad"] forState:UIControlStateNormal];
    [self.removeButton addTarget:self action:@selector(showAddWidgetScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.removeButton setAlpha:0.0f];
    [self.view addSubview:self.removeButton];
    
    [self loadWidgets];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self saveWidgets];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.collectionView.frame = self.view.bounds;
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 60.0f, 0.0f);
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    self.closeButton.frame = CGRectMake(self.view.bounds.size.width - 60.0f, self.view.bounds.size.height-60.0f, 40.0f, 40.0f);
    self.addButton.frame = CGRectMake(20.0f, self.view.bounds.size.height-60.0f, 40.0f, 40.0f);
    self.removeButton.frame = CGRectMake(20.0f, self.view.bounds.size.height-60.0f, 40.0f, 40.0f);
}

#pragma mark - Logic
- (void)loadWidgets
{
    NSLog(@"Loading widgets");
    
    @try
    {
        NSString *appSupportDirectory = [self applicationSupportDirectoryPath];
        if(appSupportDirectory)
        {
            NSString *filePath = [NSString stringWithFormat:@"%@/dashboard.dtk", appSupportDirectory];
            
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfFile:filePath options:kNilOptions error:&error];
            if(!error && data)
            {
                NSDictionary *representations = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if(!error && representations)
                {
                    for(NSDictionary *representation in representations)
                    {
                        Class WidgetClass = NSClassFromString(representation[@"class"]);
                        if(WidgetClass)
                        {
                            id widget = [(UASummaryWidget *)[WidgetClass alloc] initFromSerializedRepresentation:representation];
                            if(widget)
                            {
                                [self.widgets addObject:widget];
                                [widget update];
                            }
                        }
                    }
                    
                    [self.collectionView reloadData];
                }
                else
                {
                    [NSException raise:@"Failed to parse JSON" format:@"Failed to parse dashboard widget JSON: %@", [error localizedDescription]];
                }
            }
            else
            {
                [NSException raise:@"Failed to parse dashboard widget file" format:@"Failed to parse dashboard widget file: %@", [error localizedDescription]];
            }
        }
        else
        {
            [NSException raise:@"Failed to find application support directory" format:@"Failed to find application support directory"];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Failed to load dashboard widgets: %@", [exception reason]);
    }
}
- (void)saveWidgets
{
    NSLog(@"Saving widgets");
    
    @try
    {
        NSMutableArray *serializedWidgetRepresentations = [NSMutableArray array];
        for(UASummaryWidget *widget in self.widgets)
        {
            NSDictionary *serializedRepresentation = [widget serializedRepresentation];
            if(serializedRepresentation)
            {
                [serializedWidgetRepresentations addObject:[widget serializedRepresentation]];
            }
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serializedWidgetRepresentations
                                                           options:kNilOptions
                                                             error:&error];
        
        NSString *appSupportDirectory = [self applicationSupportDirectoryPath];
        if(appSupportDirectory)
        {
            NSString *filePath = [NSString stringWithFormat:@"%@/dashboard.dtk", appSupportDirectory];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            if(![manager fileExistsAtPath:appSupportDirectory])
            {
                BOOL result = [manager createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error];
                if(!result || error)
                {
                    [NSException raise:@"Failed to find and create application support directory" format:@"Failed to find and create application support directory: %@", appSupportDirectory];
                }
            }
            
            if(![jsonData writeToFile:filePath atomically:YES])
            {
                [NSException raise:@"Failed to write serialized JSON" format:@"Failed to write serialized JSON to filepath: %@", filePath];
            }
        }
        else
        {
            [NSException raise:@"Failed to find application support directory" format:@"Failed to find application support directory"];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Failed to save dashboard widgets: %@", [exception reason]);
    }
}
- (void)setInEditMode:(BOOL)state
{
    if(_inEditMode != state)
    {
        [UIView animateWithDuration:0.15 animations:^{
            if(state)
            {
                self.closeButton.alpha = 0.0f;
                self.addButton.alpha = 0.0f;
                self.removeButton.alpha = 1.0f;
            }
            else
            {
                self.closeButton.alpha = 1.0f;
                self.addButton.alpha = 1.0f;
                self.removeButton.alpha = 0.0f;
            }
        }];
    }
    
    _inEditMode = state;
}
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

#pragma mark - UI logic
- (void)showAddWidgetScreen:(id)sender
{
    self.widgetListVC = [[UASummaryWidgetListViewController alloc] init];
    self.widgetListVC.delegate = self;
    [(FXBlurView *)self.widgetListVC.view setUnderlyingView:self.parentViewController.view];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.widgetListVC];
    [self presentViewController:nvc animated:YES completion:nil];
    
    /*
    
    self.widgetListVC.view.frame = self.view.bounds;
    [self.widgetListVC willMoveToParentViewController:self];
    [self.view addSubview:self.widgetListVC.view];
    [self.widgetListVC didMoveToParentViewController:self];
     */
}

#pragma mark - Presentation logic
- (void)presentInViewController:(UIViewController *)parentVC
{
    self.view.alpha = 0.0f;
    self.view.frame = parentVC.view.bounds;
    
    [self willMoveToParentViewController:parentVC];
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
    [self saveWidgets];
    
    __weak typeof(self) weakRef = self;
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
    UASummaryCollectionViewCell *cell = (UASummaryCollectionViewCell *)[aCollectionView dequeueReusableCellWithReuseIdentifier:@"widget" forIndexPath:indexPath];
    
    UIView *widgetView = [self.widgets objectAtIndex:indexPath.row];
    [cell setWidgetView:widgetView];
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UASummaryWidget *widget = self.widgets[indexPath.row];
    
    NSLog(@"Widget %@ size: %@", indexPath, NSStringFromCGSize(CGSizeMake(collectionView.bounds.size.width, widget.height)));
    return CGSizeMake(collectionView.bounds.size.width, [widget height]);
}

#pragma mark - Helpers
- (NSString *)applicationSupportDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if(paths && [paths count])
    {
        return [paths lastObject];
    }
    
    return nil;
}

#pragma mark - UASummaryWidgetListViewDelegate methods
- (void)summaryList:(UASummaryWidgetListViewController *)summaryListVC didSelectWidgetClass:(Class)WidgetClass
{
    NSLog(@"Did select widget of class: %@", WidgetClass);
    
    id newWidget = [[WidgetClass alloc] init];
    [self.widgets addObject:newWidget];
    [self.collectionView reloadData];
    
    [newWidget update];
    
    [self saveWidgets];
    [summaryListVC dismiss];
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
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setInEditMode:YES];
    
    [(UASummaryWidget *)self.widgets[indexPath.row] setBeingDragged:YES];
}
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath atPoint:(CGPoint)point
{
    UASummaryWidget *widget = (UASummaryWidget *)self.widgets[indexPath.row];
    if(CGRectContainsPoint(self.removeButton.frame, point))
    {
        [self.widgets removeObject:widget];
        [collectionView reloadData];
    }
    else
    {
        [widget setBeingDragged:NO];
    }
    
    [self setInEditMode:NO];
}
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didDragItemAtIndexPath:(NSIndexPath *)indexPath toPoint:(CGPoint)point
{
    if(CGRectContainsPoint(self.removeButton.frame, point))
    {
        
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willPerformCustomDropAnimationForItemAtIndexPath:(NSIndexPath *)indexPath withRepresentationView:(UIView *)representationView atDropPoint:(CGPoint)point
{
    if(CGRectContainsPoint(self.removeButton.frame, point))
    {
        representationView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
        //representationView.center = self.removeButton.center;
        return YES;
    }
    
    return NO;
}
@end