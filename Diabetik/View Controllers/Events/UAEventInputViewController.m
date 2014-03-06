//
//  UAEventInputViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 11/02/2014.
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

#import "UAEventInputViewController.h"
#import "UAEventCollectionViewCell.h"
#import "UANavPaginationTitleView.h"

#import "UAMedicineInputViewController.h"
#import "UAMealInputViewController.h"
#import "UABGInputViewController.h"
#import "UAActivityInputViewController.h"
#import "UANoteInputViewController.h"

#define kDragBuffer 15.0f

@interface UAEventInputViewController ()
{
    CGPoint scrollVelocity;
}
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) NSInteger currentIndex;

@property (nonatomic, strong) UIImageView *addEntryIndicatorImageView;
@property (nonatomic, assign) BOOL isBeingPopped;
@property (nonatomic, assign) BOOL isAddingEntry;
@property (nonatomic, assign) BOOL isAnimatingAddingEntry;

// Logic
- (void)addVC:(UAInputBaseViewController *)vc;
- (void)removeVC:(UAInputBaseViewController *)vc;

// Helpers
- (UAInputBaseViewController *)activeViewController;

@end

@implementation UAEventInputViewController

#pragma mark - Setup
- (id)initWithEventType:(NSInteger)eventType
{
    self = [super init];
    if(self)
    {
        [self commonInit];
        
        UAInputBaseViewController *vc = nil;
        if(eventType == 0)
        {
            vc = [[UAMedicineInputViewController alloc] init];
        }
        else if(eventType == 1)
        {
            vc = [[UABGInputViewController alloc] init];
        }
        else if(eventType == 2)
        {
            vc = [[UAMealInputViewController alloc] init];
        }
        else if(eventType == 3)
        {
            vc = [[UAActivityInputViewController alloc] init];
        }
        else if(eventType == 4)
        {
            vc = [[UANoteInputViewController alloc] init];
        }
        [self addVC:vc];
    }
    
    return self;
}
- (id)initWithEvent:(UAEvent *)aEvent
{
    self = [super init];
    if(self)
    {
        [self commonInit];
        
        UAInputBaseViewController *vc = nil;
        if([aEvent isKindOfClass:[UAMedicine class]])
        {
            vc = [[UAMedicineInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[UAReading class]])
        {
            vc = [[UABGInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[UAMeal class]])
        {
            vc = [[UAMealInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[UAActivity class]])
        {
            vc = [[UAActivityInputViewController alloc] initWithEvent:aEvent];
        }
        else if([aEvent isKindOfClass:[UANote class]])
        {
            vc = [[UANoteInputViewController alloc] initWithEvent:aEvent];
        }
        [self addVC:vc];
    }
    
    return self;
}
- (id)initWithMedicineAmount:(NSNumber *)amount
{
    self = [super init];
    if(self)
    {
        [self commonInit];
        
        UAMedicineInputViewController *vc = [[UAMedicineInputViewController alloc] initWithAmount:amount];
        [self addVC:vc];
    }
    
    return self;
}
- (void)commonInit
{
    self.currentIndex = 0;
    self.viewControllers = [NSMutableArray array];
    
    self.isBeingPopped = NO;
    self.isAddingEntry = NO;
    self.isAnimatingAddingEntry = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Setup our collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor redColor];
    [self.collectionView registerClass:[UAEventCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.view addSubview:self.collectionView];
    
    // Add our new entry indicator image view
    if(!self.addEntryIndicatorImageView)
    {
        self.addEntryIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddEntryMedicineBubble"]];
        self.addEntryIndicatorImageView.alpha = 0.0f;
        [self.view addSubview:self.addEntryIndicatorImageView];
    }
    
    // Setup header buttons
    if([self isPresentedModally])
    {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconCancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBack:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:NO];
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconSave"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(saveEvent:)];
    [self.navigationItem setRightBarButtonItem:saveBarButtonItem animated:NO];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self updateNavigationBar];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.collectionView.frame = self.view.bounds;
    
    [self updateNavigationBar];
    [self performSelector:@selector(activateTargetViewController) withObject:nil afterDelay:0.0f];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove any customisation on the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(self.isBeingPopped)
    {
        self.collectionView = nil;
        for(UAInputBaseViewController *vc in [self.viewControllers copy])
        {
            [self removeVC:vc];
        }
        self.viewControllers = nil;
    }
}

#pragma mark - Logic
- (void)deleteEvent:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *activeViewController = [self activeViewController];
    [activeViewController triggerDeleteEvent:sender];
}
- (void)discardChanges:(id)sender
{
    for(UAInputBaseViewController *vc in self.viewControllers)
    {
        [vc discardChanges];
    }
    
    [self handleBack:self];
}
- (void)addVC:(UAInputBaseViewController *)aVC
{
    if(aVC)
    {
        [self.viewControllers addObject:aVC];
        [aVC willMoveToParentViewController:self];
        [aVC didMoveToParentViewController:self];
        
        if(self.collectionView)
        {
            [self.collectionView reloadData];
        }
    }
}
- (void)removeVC:(UAInputBaseViewController *)aVC
{
    NSUInteger index = [self.viewControllers indexOfObject:aVC];
    if(index != NSNotFound)
    {
        [self.collectionView performBatchUpdates:^{
            [self.viewControllers removeObject:aVC];
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            
            [self activateTargetViewController];
        } completion:^(BOOL finished) {
            [self.collectionView.collectionViewLayout invalidateLayout];
        }];
    }
}
- (void)updateNavigationBar
{
    UAInputBaseViewController *activeViewController = [self activeViewController];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:[activeViewController navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"trans"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UAFont standardDemiBoldFontWithSize:17.0f]}];
    
    if([self.viewControllers count] > 1)
    {
        UANavPaginationTitleView *titleView = [[UANavPaginationTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
        [titleView setTitle:activeViewController.title];
        [titleView.pageControl setViewControllers:self.viewControllers];
        [titleView.pageControl setCurrentPage:self.currentIndex];
        self.navigationItem.titleView = titleView;
    }
    else
    {
        self.navigationItem.title = activeViewController.title;
        self.navigationItem.titleView = nil;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)activateTargetViewController
{
    CGPoint currentOffset = [self.collectionView contentOffset];
    NSInteger newIndex = ceilf(currentOffset.x / self.collectionView.frame.size.width);
    
    if(newIndex > [self.viewControllers count]-1)
    {
        newIndex = [self.viewControllers count]-1;
    }
    
    if(newIndex >= 0 && newIndex < [self.viewControllers count])
    {
        UAInputBaseViewController *targetVC = self.viewControllers[newIndex];
        if(targetVC)
        {
            self.currentIndex = newIndex;
            [self updateNavigationBar];
            
            for(UAInputBaseViewController *vc in self.viewControllers)
            {
                if([vc activeView])
                {
                    [vc willBecomeInactive];
                }
            }
            [targetVC didBecomeActive];
            [targetVC updateKeyboardShortcutButtons];
        }
    }
}
- (void)handleBack:(id)sender
{
    self.isBeingPopped = YES;
    
    [super handleBack:sender];
}
- (void)handleBack:(id)sender withSound:(BOOL)playSound
{
    self.isBeingPopped = YES;
    
    [super handleBack:sender withSound:playSound];
}

#pragma mark - UI
- (void)presentAddReminder:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UIActionSheet *actionSheet = nil;
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remind me in", nil)
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                destructiveButtonTitle:nil
                                     otherButtonTitles:NSLocalizedString(@"15 minutes", nil), NSLocalizedString(@"30 minutes", nil), NSLocalizedString(@"1 hour", nil), NSLocalizedString(@"The future", @"An option allow users to be reminded at some point in the future"), nil];
    actionSheet.tag = kExistingImageActionSheetTag;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)presentMediaOptions:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *activeViewController = [self activeViewController];
    UAActionSheet *actionSheet = nil;
    if(activeViewController.currentPhotoPath)
    {
        actionSheet = [[UAActionSheet alloc] initWithTitle:nil
                                                  delegate:activeViewController
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Remove photo", nil)
                                         otherButtonTitles:NSLocalizedString(@"View photo", nil), nil];
        actionSheet.tag = kExistingImageActionSheetTag;
    }
    else
    {
        actionSheet = [[UAActionSheet alloc] initWithTitle:nil
                                                  delegate:activeViewController
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
        actionSheet.tag = kImageActionSheetTag;
    }
    
    actionSheet.acceptsFirstResponder = NO;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)presentGeotagOptions:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputBaseViewController *activeViewController = [self activeViewController];
    if((self.event && [self.event.lat doubleValue] != 0.0 && [self.event.lon doubleValue] != 0.0) || ([activeViewController.lat doubleValue] != 0.0 && [activeViewController.lon doubleValue] != 0.0))
    {
        UAActionSheet *actionSheet = nil;
        actionSheet = [[UAActionSheet alloc] initWithTitle:nil
                                                  delegate:activeViewController
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                    destructiveButtonTitle:NSLocalizedString(@"Remove", nil)
                                         otherButtonTitles:NSLocalizedString(@"View on map", nil), NSLocalizedString(@"Update location", nil), nil];
        actionSheet.acceptsFirstResponder = NO;
        actionSheet.tag = kGeotagActionSheetTag;
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add Location", nil)
                                                            message:NSLocalizedString(@"Are you sure you'd like to add location data to this event?" ,nil)
                                                           delegate:activeViewController
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Add", nil), nil];
        alertView.tag = kGeoTagAlertViewTag;
        [alertView show];
    }
}

#pragma mark - UICollectionViewDatasource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewControllers count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UAEventCollectionViewCell *cell = (UAEventCollectionViewCell *)[aCollectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    UAInputBaseViewController *vc = self.viewControllers[indexPath.row];
    if(vc && ![[vc.view superview] isEqual:cell.contentView])
    {
        [cell setViewController:vc];
    }
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    self.isAddingEntry = NO;
    self.isAnimatingAddingEntry = NO;
    
    self.addEntryIndicatorImageView.frame = CGRectMake(self.collectionView.bounds.size.width - self.addEntryIndicatorImageView.frame.size.width, self.collectionView.bounds.size.height/2.0f - self.addEntryIndicatorImageView.frame.size.height/2.0f, self.addEntryIndicatorImageView.frame.size.width, self.addEntryIndicatorImageView.frame.size.height);
}
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat offsetX = [self.viewControllers count] > 1 ? aScrollView.contentOffset.x - ([self.viewControllers count]-1)*aScrollView.frame.size.width : aScrollView.contentOffset.x;
    
    if(aScrollView.isTracking && offsetX > kDragBuffer && [self.viewControllers count] < 8)
    {
        self.addEntryIndicatorImageView.alpha = 1.0f; //((offsetX-kDragBuffer > 20.0f ? 20.0f : offsetX-kDragBuffer)/20.0f)*1.0f;
        //aScrollView.alpha = 1.0f - ((offsetX-kDragBuffer > 20.0f ? 20.0f : offsetX-kDragBuffer)/20.0f)*0.5f;
        
        if(offsetX-kDragBuffer < 20.0f)
        {
            self.addEntryIndicatorImageView.image = [UIImage imageNamed:@"AddEntryMedicineBubble"];
        }
        else if(offsetX-kDragBuffer < 40.0f)
        {
            self.addEntryIndicatorImageView.image = [UIImage imageNamed:@"AddEntryBloodBubble"];
        }
        else if(offsetX-kDragBuffer < 60.0f)
        {
            self.addEntryIndicatorImageView.image = [UIImage imageNamed:@"AddEntryMealBubble"];
        }
        else if(offsetX-kDragBuffer < 80.0f)
        {
            self.addEntryIndicatorImageView.image = [UIImage imageNamed:@"AddEntryActivityBubble"];
        }
        else if(offsetX-kDragBuffer < 100.0f)
        {
            self.addEntryIndicatorImageView.image = [UIImage imageNamed:@"AddEntryNoteBubble"];
        }
    }
    else
    {
        self.addEntryIndicatorImageView.alpha = 0.0f;
    }
    
    if(self.isAddingEntry && !self.isAnimatingAddingEntry && !aScrollView.tracking)
    {
        self.isAnimatingAddingEntry = YES;
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.viewControllers count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    
    /*
    else if(!aScrollView.isTracking && aScrollView.contentOffset.x > aScrollView.contentSize.width-aScrollView.frame.size.width && !isAnimatingAddEntry)
    {
        [aScrollView scrollRectToVisible:CGRectMake(aScrollView.contentSize.width-aScrollView.frame.size.width, 0.0f, aScrollView.frame.size.width, aScrollView.frame.size.height) animated:YES];
        isAnimatingAddEntry = YES;
    }
    */
    
    if(aScrollView.isTracking)
    {
        scrollVelocity = [[aScrollView panGestureRecognizer] velocityInView:aScrollView.superview];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetX = [self.viewControllers count] > 1 ? aScrollView.contentOffset.x - ([self.viewControllers count]-1)*aScrollView.frame.size.width : aScrollView.contentOffset.x;
    if(fabsf(scrollVelocity.x) < 150.0f && offsetX > kDragBuffer && [self.viewControllers count] < 8)
    {
        self.isAddingEntry = YES;
        
        if(offsetX-kDragBuffer < 20.0f)
        {
            UAMedicineInputViewController *vc = [[UAMedicineInputViewController alloc] init];
            [self addVC:vc];
        }
        else if(offsetX-kDragBuffer < 40.0f)
        {
            UABGInputViewController *vc = [[UABGInputViewController alloc] init];
            [self addVC:vc];
        }
        else if(offsetX-kDragBuffer < 60.0f)
        {
            UAMealInputViewController *vc = [[UAMealInputViewController alloc] init];
            [self addVC:vc];
        }
        else if(offsetX-kDragBuffer < 80.0f)
        {
            UAActivityInputViewController *vc = [[UAActivityInputViewController alloc] init];
            [self addVC:vc];
        }
        else if(offsetX-kDragBuffer < 100.0f)
        {
            UANoteInputViewController *vc = [[UANoteInputViewController alloc] init];
            [self addVC:vc];
        }
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    [self activateTargetViewController];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    [self activateTargetViewController];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex > 3) return;
    
    NSInteger minutes = 0;
    switch(buttonIndex)
    {
        case 0:
            minutes = 15;
            break;
        case 1:
            minutes = 30;
            break;
        case 2:
            minutes = 60;
            break;
    }
    
    NSDate *date = [[NSDate date] dateByAddingMinutes:minutes];
    UATimeReminderViewController *vc = [[UATimeReminderViewController alloc] initWithDate:date];
    UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
    nvc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Keyboard handling
- (void)keyboardWillBeShown:(NSNotification *)aNotification
{
    CGRect keyboardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize kbSize = [self.view convertRect:keyboardFrame fromView:nil].size;
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length- kbSize.height);
}
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    CGRect keyboardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize kbSize = [self.view convertRect:keyboardFrame fromView:nil].size;
 
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length- kbSize.height);
}
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length);
}

#pragma mark - Rotation handling methods
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGSize currentSize = self.collectionView.bounds.size;
    float offset = self.currentIndex * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
}

#pragma mark - UIViewController methods
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Helpers
- (UAInputBaseViewController *)activeViewController
{
    return self.viewControllers[self.currentIndex];
}
@end
