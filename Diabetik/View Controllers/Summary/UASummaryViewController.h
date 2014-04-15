//
//  UASummaryViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <LXReorderableCollectionViewFlowLayout/LXReorderableCollectionViewFlowLayout.h>
#import "UABaseViewController.h"

@interface UASummaryViewController : UABaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, LXReorderableCollectionViewDataSource>

// Presentation logic
- (void)presentInViewController:(UIViewController *)parentVC;
- (void)dismiss;

@end
