//
//  UAInsightsViewController.h
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

#import "LXReorderableCollectionViewFlowLayout.h"
#import "UABaseViewController.h"
#import "UASummaryWidgetListViewController.h"

@interface UAInsightsViewController : UABaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, LXReorderableCollectionViewDataSource, UASummaryWidgetListViewDelegate>

// Presentation logic
- (void)presentInViewController:(UIViewController *)parentVC;
- (void)dismiss;

@end
