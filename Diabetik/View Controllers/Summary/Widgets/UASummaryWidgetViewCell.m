//
//  UASummaryWidgetViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UASummaryWidgetViewCell.h"
#import "UASummaryWidget.h"

@interface UASummaryWidgetViewCell ()
@end

@implementation UASummaryWidgetViewCell

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor redColor];
    }
    return self;
}

#pragma mark - Logic
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if(self.widget)
    {
        [self.widget.widgetContentView removeFromSuperview];
        [self.widget.widgetSettingsView removeFromSuperview];
        self.widget = nil;
    }
}

#pragma mark - Accessors
- (void)setWidget:(UASummaryWidget *)aWidget
{
    _widget = aWidget;
    _widget.cell = self;
}
- (void)setSettingsVisible:(BOOL)visible animated:(BOOL)animated
{
    if(animated)
    {
        [self.widget.widgetSettingsView removeFromSuperview];
    //    [self.contentView addSubview:self.widget.widgetSettingsView];
        
        /*
        NSLog(@"Settings visible: %@", self.widget);
        [UIView transitionFromView:self.widget.widgetContentView
                            toView:self.widget.widgetSettingsView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromTop
                        completion:nil];
         */
    }
    else
    {
        [self.widget.widgetSettingsView removeFromSuperview];
        [self.widget.widgetContentView removeFromSuperview];
        
        if(visible)
        {
            [self.contentView addSubview:self.widget.widgetSettingsView];
        }
        else
        {
            [self.contentView addSubview:self.widget.widgetContentView];
        }
    }
}

@end
