//
//  UAEventCollectionViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 11/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UAEventCollectionViewCell.h"

@implementation UAEventCollectionViewCell

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.viewController = nil;
}

#pragma mark - Setters
- (void)setViewController:(UIViewController *)theVC
{
    if(_viewController)
    {
        [_viewController.view removeFromSuperview];
        
    }
    
    if(theVC)
    {
        _viewController = theVC;
        _viewController.view.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewController.view];
    }
}

@end
