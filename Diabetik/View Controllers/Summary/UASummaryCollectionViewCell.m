//
//  UASummaryCollectionViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/04/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UASummaryCollectionViewCell.h"

@implementation UASummaryCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.widgetView.frame = self.contentView.bounds;
}
- (void)setWidgetView:(UIView *)view
{
    _widgetView = view;
    if(view.superview && ![view.superview isEqual:self])
    {
        [view removeFromSuperview];
    }
    [self.contentView addSubview:view];
    
    [self setNeedsLayout];
}
@end
