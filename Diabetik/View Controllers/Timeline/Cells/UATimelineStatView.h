//
//  UATimelineStatView.h
//  Diabetik
//
//  Created by Nial Giacomelli on 24/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UATimelineStatView.h"

@interface UATimelineStatView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

// Accessors
- (void)setImage:(UIImage *)image;
- (void)setText:(NSString *)text;
@end