//
//  UATimelineViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 05/12/2012.
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

#import "NSDate+Extension.h"
#import "NSString+Extension.h"

#import "UAAppDelegate.h"
#import "UATimelineViewController.h"
#import "UASettingsViewController.h"
#import "UABGInputViewController.h"
#import "UAMealInputViewController.h"
#import "UAMedicineInputViewController.h"
#import "UAActivityInputViewController.h"
#import "UANoteInputViewController.h"
#import "UAInsightsViewController.h"
#import "UATagController.h"

#import "UAMeal.h"
#import "UAReading.h"
#import "UAMedicine.h"
#import "UAActivity.h"

#define kEventActionSheetTag 0
#define kDateRangeActionSheetTag 1

@interface UATimelineViewController ()
{
    UISearchDisplayController *searchDisplayController;
    
    NSArray *sectionStats;
    NSArray *searchResults;
    NSArray *searchResultHeaders;
    NSArray *searchResultSectionStats;
    
    NSDateFormatter *dateFormatter;
    BOOL allowReportRotation;
    BOOL isShowingChart;
    
    id settingsChangeNotifier;
    id applicationResumeNotifier;
    id orientationChangeNotifier;
}
@property (nonatomic, strong) UAReportsViewController *reportsVC;
@property (nonatomic, strong) UADetailViewController *detailViewController;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSPredicate *timelinePredicate;
@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, assign) NSInteger relativeDays;

@property (nonatomic, strong) UAViewControllerMessageView *noEntriesMessageView;
@property (nonatomic, strong) UIView *searchBarHeaderView;
@property (nonatomic, strong) UISearchBar *searchBar;

// Setup
- (void)commonInit;

// Logic
- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer;

// UI
- (void)addEvent:(id)sender;
- (void)showReports:(id)sender;

@end

@implementation UATimelineViewController
@synthesize moc = _moc;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize detailViewController = _detailViewController;
@synthesize reportsVC = _reportsVC;
@synthesize relativeDays = _relativeDays;

#pragma mark - Setup
- (id)initWithRelativeDays:(NSInteger)days
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        [self commonInit];
        
        NSDate *fromDate = nil;
        if(days > 0)
        {
            fromDate = [[[[NSDate date] dateAtStartOfDay] dateBySubtractingDays:days-1] dateAtEndOfDay];
        }
        else
        {
            fromDate = [[NSDate date] dateAtStartOfDay];
        }
        self.timelinePredicate = [NSPredicate predicateWithFormat:@"timestamp >= %@", fromDate];
    }
    
    return self;
}
- (id)initWithDateFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        [self commonInit];
        _relativeDays = -1;
        
        self.timelinePredicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ && timestamp <= %@", fromDate, toDate];
    }
    return self;
}
- (id)initWithTag:(NSString *)tag
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        [self commonInit];
        _relativeDays = -1;
        
        self.title = [NSString stringWithFormat:@"#%@", tag];
        self.timelinePredicate = [NSPredicate predicateWithFormat:@"ANY tags.nameLC = %@", [tag lowercaseString]];
    }
    return self;
}
- (void)commonInit
{
    self.screenName = @"Timeline";
    
    _reportsVC = nil;
    allowReportRotation = YES;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMMM yyyy"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    // Setup our nav bar buttons
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconAdd"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(addEvent:)];
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        [self.navigationItem setRightBarButtonItem:addBarButtonItem animated:NO];
    }
    else
    {
        UIBarButtonItem *reportBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"NavBarIconReport"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(showReports:)];
        
        [self.navigationItem setRightBarButtonItems:@[addBarButtonItem, reportBarButtonItem] animated:NO];
    }
    
    // Setup our gesture recognisers
    UITapGestureRecognizer *tagTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    UITapGestureRecognizer *searchTagTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    
    // Configure our table view
    [self.tableView addGestureRecognizer:tagTapGesture];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Setup our search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 44.0f)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.delegate = self;
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.delegate = self;
    searchDisplayController.displaysSearchBarInNavigationBar = NO;
    searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
    searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [searchDisplayController.searchResultsTableView addGestureRecognizer:searchTagTapGesture];
    
    self.searchBarHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 44.0f)];
    self.searchBarHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.searchBarHeaderView addSubview:self.searchBar];
    
    // Footer view
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:footerView.frame];
        footerLabel.text = NSLocalizedString(@"Rotate to view reports", nil);
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        footerLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [footerView addSubview:footerLabel];
        self.tableView.tableFooterView = footerView;
    }
    
    // Notifications
    applicationResumeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:@"applicationResumed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if(strongSelf.relativeDays > -1)
        {
            [strongSelf reloadViewData:note];
        }
    }];
    settingsChangeNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kSettingsChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf reloadViewData:note];
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIColor *defaultBarTintColor = kDefaultBarTintColor;
    UIColor *defaultTintColor = kDefaultTintColor;
    self.navigationController.navigationBar.barTintColor = defaultBarTintColor;
    self.navigationController.navigationBar.tintColor = defaultTintColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UAFont standardDemiBoldFontWithSize:17.0f]};
    
    self.tableView.tableHeaderView = self.searchBar;
    
    // Only listen out for orientation changes if we're not using an iPad
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:@"UIDeviceOrientationDidChangeNotification"
                                                   object:nil];
    }
    
    // Setup other table styling
    if(!self.noEntriesMessageView)
    {
        self.noEntriesMessageView = [UAViewControllerMessageView addToViewController:self
                                                                           withTitle:NSLocalizedString(@"No Entries", @"Title of message shown when the user has yet to add any entries to their journal")
                                                                          andMessage:NSLocalizedString(@"You currently don't have any entries in your timeline. To add one, tap the + icon.", nil)];
    }
    
    [self refreshView];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:settingsChangeNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationResumeNotifier];
}

#pragma mark - Logic
- (void)reloadViewData:(NSNotification *)note
{
    [super reloadViewData:note];
    
    self.fetchedResultsController = nil;
    [[self.fetchedResultsController fetchRequest] setPredicate:[self timelinePredicate]];
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
    
    [self refreshView];
}
- (void)refreshView
{
    // If we're actively searching refresh our data
    if([self.searchDisplayController isActive])
    {
        [self performSearchWithText:[self.searchBar text]];
        [[[self searchDisplayController] searchResultsTableView] reloadData];
    }
    
    // Finally, if we have no data hide our tableview
    if([self hasSavedEvents])
    {
        self.tableView.alpha = 1.0f;
        self.noEntriesMessageView.alpha = 0.0f;
    }
    else
    {
        self.tableView.alpha = 0.0f;
        self.noEntriesMessageView.alpha = 1.0f;
    }
}
- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    UITableView *targetTableView = (UITableView *)gestureRecognizer.view;
    
    CGPoint point = [gestureRecognizer locationInView:targetTableView];
    NSIndexPath *indexPath = [targetTableView indexPathForRowAtPoint:point];
    if(indexPath)
    {
        UITableViewCell *cell = [targetTableView cellForRowAtIndexPath:indexPath];
        if(cell && [cell isKindOfClass:[UATimelineViewCell class]])
        {
            [(UATimelineViewCell *)cell handleTapGesture:gestureRecognizer withController:self indexPath:indexPath andTableView:self.tableView];
        }
    }
}
- (void)performSearchWithText:(NSString *)searchText
{
    if(searchText && searchText.length)
    {
        NSString *regex = [NSString stringWithFormat:@".*?%@.*?", [searchText lowercaseString]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name MATCHES[cd] %@ OR self.notes MATCHES[cd] %@", regex, regex];

        if(predicate)
        {
            NSMutableArray *newResults = [NSMutableArray array];
            NSMutableArray *newHeaders = [NSMutableArray array];
            if(self.fetchedResultsController && [[self.fetchedResultsController fetchedObjects] count])
            {
                for(id<NSFetchedResultsSectionInfo> section in [self.fetchedResultsController sections])
                {
                    NSArray *matchingObjects = [[section objects] filteredArrayUsingPredicate:predicate];
                    if(matchingObjects && [matchingObjects count])
                    {
                        NSMutableArray *objects = [NSMutableArray array];
                        for(id object in [section objects])
                        {
                            NSInteger indexOfObject = [matchingObjects indexOfObject:object];
                            BOOL relevant = indexOfObject != NSNotFound;
                            if(![[NSUserDefaults standardUserDefaults] boolForKey:kFilterSearchResultsKey] || ([[NSUserDefaults standardUserDefaults] boolForKey:kFilterSearchResultsKey] && relevant))
                            {
                                [objects addObject:[NSDictionary dictionaryWithObjectsAndKeys:object, @"object", [NSNumber numberWithBool:relevant], @"relevant", nil]];
                            }
                        }
                        
                        [newHeaders addObject:[section name]];
                        [newResults addObject:objects];
                    }
                }
                
                searchResults = newResults;
                searchResultHeaders = newHeaders;
                
                NSMutableArray *stats = [NSMutableArray array];
                for(NSArray *results in searchResults)
                {
                    [stats addObject:[self calculatedStatsForObjects:results]];
                }
                searchResultSectionStats = [NSArray arrayWithArray:stats];
                
                return;
            }
        }
    }
    
    searchResults = nil;
    searchResultHeaders = nil;
    searchResultSectionStats = nil;
}
- (void)calculateSectionStats
{
    NSMutableArray *stats = [NSMutableArray array];
    
    if(self.fetchedResultsController && [[self.fetchedResultsController fetchedObjects] count])
    {
        for(id<NSFetchedResultsSectionInfo> section in [self.fetchedResultsController sections])
        {
            [stats addObject:[self calculatedStatsForObjects:[section objects]]];
        }
    }
    
    sectionStats = stats;
}
- (NSDictionary *)calculatedStatsForObjects:(NSArray *)objects
{
    NSInteger activityCount = 0, readingCount = 0, mealCount = 0;
    double activityTotal = 0, readingTotal = 0, mealTotal = 0;
    
    for(id object in objects)
    {
        UAEvent *event = nil;
        if([object isKindOfClass:[NSDictionary class]])
        {
            event = (UAEvent *)[object valueForKey:@"object"];
        }
        else
        {
            event = (UAEvent *)object;
        }
        
        if([event isKindOfClass:[UAReading class]])
        {
            readingCount++;
            readingTotal += [[(UAReading *)event value] doubleValue];
        }
        else if([event isKindOfClass:[UAActivity class]])
        {
            activityCount++;
            activityTotal += [[(UAActivity *)event minutes] doubleValue];
        }
        else if([event isKindOfClass:[UAMeal class]])
        {
            mealCount++;
            mealTotal += [[(UAMeal *)event grams] doubleValue];
        }
    }
    
    // Calculate our reading average
    if(readingCount) readingTotal /= readingCount;

    return @{
        @"reading": [NSNumber numberWithDouble:readingTotal],
        @"activity": [NSNumber numberWithDouble:activityTotal],
        @"meal": [NSNumber numberWithDouble:mealTotal]
    };
}

#pragma mark - UI
- (void)addEvent:(id)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    allowReportRotation = NO;
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        UAAddEntryModalView *modalView = [[UAAddEntryModalView alloc] initWithFrame:self.navigationController.view.bounds];
        modalView.delegate = self;
        [self.navigationController.view addSubview:modalView];
        [modalView present];
    }
    else
    {
        UAAppDelegate *delegate = (UAAppDelegate*)[[UIApplication sharedApplication] delegate];
        UAAddEntryiPadView *modalView = [UAAddEntryiPadView presentInView:delegate.viewController.view];
        modalView.delegate = self;
    }
}
- (void)showReports:(id)sender
{
    if(!self.reportsVC)
    {
        NSArray *entries = [[self fetchedResultsController] fetchedObjects];
        NSDate *_fromDate = [(UAEvent *)[entries lastObject] timestamp];
        NSDate *_toDate = [(UAEvent *)[entries firstObject] timestamp];
        
        self.reportsVC = [[UAReportsViewController alloc] initFromDate:_fromDate toDate:_toDate];
        self.reportsVC.delegate = self;
        self.reportsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self presentViewController:self.reportsVC animated:YES completion:nil];
    }
    else
    {
        self.reportsVC.view.frame = self.parentViewController.view.frame;
        [self presentViewController:self.reportsVC animated:NO completion:nil];
    }
}
- (void)configureCell:(UITableViewCell *)aCell forTableview:(UITableView *)aTableView atIndexPath:(NSIndexPath *)indexPath
{
    NSNumberFormatter *valueFormatter = [UAHelper standardNumberFormatter];
    NSNumberFormatter *glucoseFormatter = [UAHelper glucoseNumberFormatter];
    
    if([[aCell class] isEqual:[UATimelineViewCell class]])
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        
        UATimelineViewCell *cell = (UATimelineViewCell *)aCell;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.valueLabel.text = @"";
        
        BOOL dimCellContents = NO;
        NSManagedObject *object = nil;
        if(aTableView == self.tableView)
        {
            object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        else
        {
            NSArray *section = [searchResults objectAtIndex:indexPath.section];
            NSDictionary *objectData = (NSDictionary *)[section objectAtIndex:indexPath.row];
            object = [objectData valueForKey:@"object"];
            
            dimCellContents = ![[objectData valueForKey:@"relevant"] boolValue];
        }
        
        // Dim the contents of cells which contain non-relevant search content
        if(dimCellContents)
        {
            cell.valueLabel.alpha = 0.35f;
            cell.iconImageView.alpha = 0.35f;
            cell.timestampLabel.alpha = 0.35f;
            cell.descriptionLabel.alpha = 0.35f;
            cell.notesTextView.alpha = 0.35f;
            cell.photoImageView.alpha = 0.35f;
        }
        else
        {
            cell.valueLabel.alpha = 1.0f;
            cell.iconImageView.alpha = 1.0f;
            cell.timestampLabel.alpha = 1.0f;
            cell.descriptionLabel.alpha = 1.0f;
            cell.notesTextView.alpha = 1.0f;
            cell.photoImageView.alpha = 1.0f;
        }
        
        if([object isKindOfClass:[UAMeal class]])
        {
            UAMeal *meal = (UAMeal *)object;
            cell.valueLabel.text = [valueFormatter stringFromNumber:[meal grams]];
            cell.valueLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
            cell.iconImageView.image = [UIImage imageNamed:@"TimelineIconMeal"];
            cell.iconImageView.highlightedImage = [UIImage imageNamed:@"TimelineIconMealHighlighted"];
            cell.descriptionLabel.text = [meal name];
        }
        else if([object isKindOfClass:[UAReading class]])
        {
            UAReading *reading = (UAReading *)object;
            
            cell.descriptionLabel.text = NSLocalizedString(@"Blood glucose level", nil);
            cell.valueLabel.text = [glucoseFormatter stringFromNumber:[reading value]];
            cell.iconImageView.image = [UIImage imageNamed:@"TimelineIconBlood"];
            cell.iconImageView.highlightedImage = [UIImage imageNamed:@"TimelineIconBloodHighlighted"];
            
            if(![UAHelper isBGLevelSafe:[[reading value] doubleValue]])
            {
                cell.valueLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
            }
            else
            {
                cell.valueLabel.textColor = [UIColor colorWithRed:24.0f/255.0f green:197.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
            }
        }
        else if([object isKindOfClass:[UAMedicine class]])
        {
            UAMedicine *medicine = (UAMedicine *)object;
            
            cell.valueLabel.text = [valueFormatter stringFromNumber:[medicine amount]];
            cell.valueLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
            cell.iconImageView.image = [UIImage imageNamed:@"TimelineIconMedicine"];
            cell.iconImageView.highlightedImage = [UIImage imageNamed:@"TimelineIconMedicineHighlighted"];
            cell.descriptionLabel.text = [NSString stringWithFormat:@"%@ (%@)", [medicine name], [[UAEventController sharedInstance] medicineTypeHR:[[medicine type] integerValue]]];
        }
        else if([object isKindOfClass:[UAActivity class]])
        {
            UAActivity *activity = (UAActivity *)object;
            
            cell.descriptionLabel.text = [activity name];
            cell.iconImageView.image = [UIImage imageNamed:@"TimelineIconActivity"];
            cell.iconImageView.highlightedImage = [UIImage imageNamed:@"TimelineIconActivityHighlighted"];
            cell.valueLabel.text = [UAHelper formatMinutes:[[activity minutes] doubleValue]];
            cell.valueLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        }
        else if([object isKindOfClass:[UANote class]])
        {
            UANote *note = (UANote *)object;
            cell.iconImageView.image = [UIImage imageNamed:@"TimelineIconNote"];
            cell.iconImageView.highlightedImage = [UIImage imageNamed:@"TimelineIconNoteHighlighted"];
            cell.descriptionLabel.text = [note name];
        }
        
        NSDictionary *metadata = [self metaDataForTableView:aTableView cellAtIndexPath:indexPath];
        [cell setMetaData:metadata];
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:kShowInlineImages] && metadata[@"photoPath"])
        {
            [[UAMediaController sharedInstance] imageWithFilenameAsync:metadata[@"photoPath"] success:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setPhotoImage:image];
                });
            } failure:nil];
        }
        else
        {
            [cell setPhotoImage:nil];
        }
        
        NSDate *date = (NSDate *)[object valueForKey:@"timestamp"];
        [cell setDate:date];
        
        [cell setNeedsDisplay];
    }
    else if([[aCell class] isEqual:[UATimelineHeaderViewCell class]])
    {
        UATimelineHeaderViewCell *cell = (UATimelineHeaderViewCell *)aCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDate:[self tableView:aTableView titleForHeaderInSection:indexPath.section]];
        
        NSArray *stats = ([self.searchDisplayController isActive]) ? searchResultSectionStats : sectionStats;
        if([stats count] && indexPath.section <= [stats count]-1)
        {
            NSDictionary *section = [stats objectAtIndex:indexPath.section];
            [cell.glucoseStatView setText:[NSString stringWithFormat:@"%@ %@", [glucoseFormatter stringFromNumber:section[@"reading"]], [NSLocalizedString(@"Avg.", @"Abbreviation for average") lowercaseString]]];
            [cell.activityStatView setText:[UAHelper formatMinutes:[[section valueForKey:@"activity"] integerValue]]];
            [cell.mealStatView setText:[NSString stringWithFormat:@"%@ %@", [valueFormatter stringFromNumber:section[@"meal"]], [NSLocalizedString(@"Carbs", nil) lowercaseString]]];
        }
    }
}

#pragma mark - UAAddEntryModalDelegate methods
- (void)addEntryModal:(UAAddEntryModalView *)modalView didSelectEntryOption:(NSInteger)buttonIndex
{
    [modalView dismiss];
    allowReportRotation = YES;
    
    if(buttonIndex < 5)
    {
        UAInputParentViewController *vc = [[UAInputParentViewController alloc] initWithEventType:buttonIndex];
        if(vc)
        {
            UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:nil];
        }
    }
}

#pragma mark - UITableViewDelegate functions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if(indexPath.row == 0) return;
    [self.view endEditing:YES];
    
    NSManagedObject *object = nil;
    indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    if(tableView == self.tableView)
    {
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    else
    {
        NSArray *section = [searchResults objectAtIndex:indexPath.section];
        NSDictionary *objectData = (NSDictionary *)[section objectAtIndex:indexPath.row];
        object = [objectData valueForKey:@"object"];
    }
    
    if(object)
    {
        UAInputParentViewController *vc = [[UAInputParentViewController alloc] initWithEvent:(UAEvent *)object];
        
        /*if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
            nvc.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:nvc animated:YES completion:nil];
        }
        else*/
        {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row > 0)
    {
        NSInteger totalRows = [self tableView:self.tableView numberOfRowsInSection:indexPath.section]-1;
        NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        
        CGFloat baseHeight = 45.0f;
        if(indexPath.row == 1 || indexPath.row == totalRows)
        {
            baseHeight = 46.0f;
        }
        
        CGFloat height = baseHeight + [UATimelineViewCell additionalHeightWithMetaData:[self metaDataForTableView:tableView cellAtIndexPath:adjustedIndexPath] width:self.tableView.bounds.size.width];
        return height;
    }
    
    return 73.0f;
}

#pragma mark - UITableViewDataSource functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tableView)
    {
        return [[self.fetchedResultsController sections] count];
    }
    else
    {    
        return [searchResultHeaders count];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tableView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects]+1;
    }
    else
    {
        return [[searchResults objectAtIndex:section] count]+1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.row > 0)
    {
        cell = (UATimelineViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UATimelineViewCell"];
        if (cell == nil)
        {
            cell = [[UATimelineViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UATimelineViewCell"];
        }
        [(UATimelineViewCell *)cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
    }
    else
    {
        cell = (UATimelineHeaderViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UATimelineHeaderViewCell"];
        if (cell == nil)
        {
            cell = [[UATimelineHeaderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UATimelineHeaderViewCell"];
        }
    }
    [self configureCell:(UATimelineViewCell *)cell forTableview:aTableView atIndexPath:indexPath];
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *timestampStr = nil;
    if(tableView == self.tableView)
    {
        timestampStr = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    }
    else
    {
        timestampStr = [searchResultHeaders objectAtIndex:section];
    }
    
    if(timestampStr)
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestampStr integerValue]];
        
        if([date isEqualToDate:[[NSDate date] dateWithoutTime]])
        {
            return NSLocalizedString(@"Today", nil);
        }
        else if([date isEqualToDateIgnoringTime:[NSDate dateYesterday]])
        {
            return NSLocalizedString(@"Yesterday", nil);
        }

        return [dateFormatter stringFromDate:date];
    }
    return @"";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[UATimelineHeaderViewCell class]];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        
        NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSError *error = nil;
            if(object)
            {
                [moc deleteObject:object];
                [moc save:&error];
                
                [self refreshView];
            }
            
            // Turn off the UITableView's edit mode to avoid having it 'freeze'
            tableView.editing = NO;
            
            if(error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh oh!", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"There was an error while trying to delete this event: %@", nil), [error localizedDescription]]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

#pragma mark - UISearchBarDelegate functions
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    [self.searchDisplayController setActive:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSearchWithText:searchText];
}

#pragma mark - UISearchDisplayDelegate functions
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    // Background view
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Footer view
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 22.0f)];
    controller.searchResultsTableView.tableFooterView = footerView;
}

#pragma mark - NSFetchedResultsControllerDelegate functions
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }

    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAEvent" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPredicate:[self timelinePredicate]];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                    managedObjectContext:moc
                                                                                                      sectionNameKeyPath:@"sectionIdentifier"
                                                                                                               cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![aFetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self calculateSectionStats];
    }
    
    return _fetchedResultsController;
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forTableview:self.tableView atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self calculateSectionStats];
    [self.tableView endUpdates];
    [self.tableView reloadData];
    
    // Are there any remaining events to use while calculating?
    if(![self hasSavedEvents])
    {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5
                         animations:^{
                             weakSelf.tableView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

#pragma mark - Helpers
- (NSDictionary *)metaDataForTableView:(UITableView *)tableView cellAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = nil;
    if(tableView == self.tableView)
    {
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    else
    {
        NSArray *section = [searchResults objectAtIndex:indexPath.section];
        object = [[section objectAtIndex:indexPath.row] valueForKey:@"object"];
    }
    
    NSMutableDictionary *metaData = [NSMutableDictionary dictionary];
    NSString *notes = [object valueForKey:@"notes"];
    NSString *photoPath = [object valueForKey:@"photoPath"];    
    if(notes) [metaData setObject:notes forKey:@"notes"];
    if(photoPath) [metaData setObject:photoPath forKey:@"photoPath"];
    
    return [NSDictionary dictionaryWithDictionary:metaData];
}
- (BOOL)hasSavedEvents
{
    if(self.fetchedResultsController)
    {
        if([[self.fetchedResultsController fetchedObjects] count])
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - UAReportsDelegate methods
- (BOOL)shouldDismissReportsOnRotation:(UAReportsViewController *)controller
{
    return YES;
}
- (void)didDismissReportsController:(UAReportsViewController *)controller
{
    self.reportsVC = nil;
}

#pragma mark - Autorotation
- (void)orientationChanged:(NSNotification *)note
{
    if(!allowReportRotation) return;
    
    UIDeviceOrientation appOrientation = [[UIDevice currentDevice] orientation];
    if(UIInterfaceOrientationIsLandscape(appOrientation) && !self.reportsVC)
    {
        [self showReports:nil];
    }
}

@end