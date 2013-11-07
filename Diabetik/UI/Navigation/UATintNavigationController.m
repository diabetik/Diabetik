//
//  UATintNavigationController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 10/10/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UATintNavigationController.h"

@interface UANavigationBar ()
@property (nonatomic, strong) CALayer *colorLayer;
@end

@implementation UANavigationBar
static CGFloat const kDefaultColorLayerOpacity = 0.8f;
static CGFloat const kSpaceToCoverStatusBars = 20.0f;

/*
- (void)setBarTintColor:(UIColor *)barTintColor
{
    [super setBarTintColor:barTintColor];
    if (self.colorLayer == nil)
    {
        self.colorLayer = [CALayer layer];
        self.colorLayer.opacity = kDefaultColorLayerOpacity;
        [self.layer addSublayer:self.colorLayer];
    }
    self.colorLayer.backgroundColor = barTintColor.CGColor;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.colorLayer != nil)
    {
        self.colorLayer.frame = CGRectMake(0, 0 - kSpaceToCoverStatusBars, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + kSpaceToCoverStatusBars);
        [self.layer insertSublayer:self.colorLayer atIndex:1];
    }
}
*/

@end

@implementation UATintNavigationController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNavigationBarClass:[UANavigationBar class] toolbarClass:nil];
    if(self) {
        // Custom initialization here, if needed.
    }
    return self;
}
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:[UANavigationBar class] toolbarClass:nil];
    if(self)
    {
        self.viewControllers = @[rootViewController];
    }
    
    return self;
}

@end
