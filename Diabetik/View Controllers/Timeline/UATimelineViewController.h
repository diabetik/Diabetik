//
//  UATimelineViewController.h
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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "UAHelper.h"
#import "UABaseViewController.h"
#import "UAReportsViewController.h"

#import "UAAddEntryModalView.h"
#import "UATimelineViewCell.h"
#import "UATimelineHeaderViewCell.h"

@class UADetailViewController;
@interface UATimelineViewController : UABaseTableViewController <UAAddEntryModalDelegate, UAReportsDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

// Setup
- (id)initWithRelativeDays:(NSInteger)days;
- (id)initWithDateFrom:(NSDate *)aFromDate to:(NSDate *)aToDate;
- (id)initWithTag:(NSString *)tag;

// Logic
- (void)refreshView;
- (void)performSearchWithText:(NSString *)searchText;
- (void)calculateSectionStats;

// UI
- (void)configureCell:(UITableViewCell *)cell forTableview:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

// Helpers
- (NSDictionary *)metaDataForTableView:(UITableView *)tableView cellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)hasSavedEvents;

@end
