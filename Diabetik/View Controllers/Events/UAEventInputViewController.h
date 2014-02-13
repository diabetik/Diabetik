//
//  UAEventInputViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 11/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UABaseViewController.h"
#import "UAEvent.h"

@interface UAEventInputViewController : UABaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UAEvent *event;

// Setup
- (id)initWithEventType:(NSInteger)eventType;
- (id)initWithEvent:(UAEvent *)aEvent;
- (id)initWithMedicineAmount:(NSNumber *)amount;

// UI
- (void)presentAddReminder:(id)sender;
- (void)presentMediaOptions:(id)sender;
- (void)presentGeotagOptions:(id)sender;
- (void)updateNavigationBar;

@end
