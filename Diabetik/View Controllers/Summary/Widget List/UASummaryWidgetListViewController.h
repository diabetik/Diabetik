//
//  UASummaryWidgetListViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 17/04/2014.
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

#import "UABaseViewController.h"
#import "UASummaryWidget.h"

@class UASummaryWidgetListViewController;
@protocol UASummaryWidgetListViewDelegate <NSObject>
- (void)summaryList:(UASummaryWidgetListViewController*)summaryListVC didSelectWidgetClass:(Class)widgetClass;
@end

@interface UASummaryWidgetListViewController : UABaseTableViewController
@property (nonatomic, weak) id<UASummaryWidgetListViewDelegate> delegate;

// Presentation logic
- (void)dismiss;

@end
