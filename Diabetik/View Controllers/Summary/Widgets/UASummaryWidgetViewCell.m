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
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Logic
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for(UIView *subview in self.contentView.subviews)
    {
        [subview removeFromSuperview];
    }
    
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
        UIView *toView = visible ? self.widget.widgetSettingsView : self.widget.widgetContentView;
        UIView *fromView = visible ? self.widget.widgetContentView : self.widget.widgetSettingsView;
        
        if(fromView.superview != self.contentView)
        {
            fromView.frame = self.contentView.bounds;
            [self.contentView addSubview:fromView];
        }
        
        NSLog(@"Settings visible: %@", self.widget);
        [UIView transitionFromView:fromView
                            toView:toView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromTop
                        completion:nil];
    }
    else
    {
        UIView *activeView = visible ? self.widget.widgetSettingsView : self.widget.widgetContentView;
        
        if(activeView.superview != self.contentView)
        {
            activeView.frame = self.contentView.bounds;
            [self.contentView addSubview:activeView];
        }
        
    }
}

@end
