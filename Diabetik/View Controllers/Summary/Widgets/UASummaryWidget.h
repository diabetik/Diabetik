//
//  UASummaryWidget.h
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UASummaryWidgetViewCell.h"

@interface UASummaryWidget : NSObject
@property (nonatomic, weak) UASummaryWidgetViewCell *cell;
@property (nonatomic, assign) BOOL showingSettings;

@property (nonatomic, strong) UIView *widgetContentView;
@property (nonatomic, strong) UIView *widgetSettingsView;

// Helpers
- (CGFloat)height;

@end
