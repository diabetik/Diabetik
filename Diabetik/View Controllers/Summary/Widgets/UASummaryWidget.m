//
//  UASummaryWidget.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UASummaryWidget.h"

@implementation UASummaryWidget

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        _showingSettings = NO;
        
        self.widgetSettingsView = [[UIView alloc] initWithFrame:CGRectZero];
        self.widgetSettingsView.backgroundColor = [UIColor colorWithRed:55/255.0f green:55/255.0f blue:55/255.0f alpha:0.5f];
        self.widgetContentView = [[UIView alloc] initWithFrame:CGRectZero];
        self.widgetContentView.backgroundColor = [UIColor colorWithRed:55/255.0f green:55/255.0f blue:55/255.0f alpha:0.5f];
    }
    
    return self;
}

#pragma mark - Accessors
- (void)showSettings
{
    [self setShowingSettings:YES];
}
- (void)setShowingSettings:(BOOL)state
{
    _showingSettings = state;
    
    if(self.cell)
    {
        [self.cell setSettingsVisible:_showingSettings animated:YES];
    }
}
- (void)setCell:(UASummaryWidgetViewCell *)aCell
{
    _cell = aCell;
    
    self.widgetSettingsView.frame = _cell.contentView.bounds;
    self.widgetContentView.frame = _cell.contentView.bounds;
    
    [self.cell setSettingsVisible:self.showingSettings animated:NO];
}
- (CGFloat)height
{
    return 180.0f;
}

@end
