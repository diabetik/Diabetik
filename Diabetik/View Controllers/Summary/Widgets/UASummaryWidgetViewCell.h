//
//  UASummaryWidgetViewCell.h
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UASummaryWidget;
@interface UASummaryWidgetViewCell : UICollectionViewCell
@property (nonatomic, weak) UASummaryWidget *widget;

// Accessors
- (void)setSettingsVisible:(BOOL)state animated:(BOOL)animated;

@end
