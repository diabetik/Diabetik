//
//  UASideMenuHeaderView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 28/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UASideMenuHeaderView.h"
#import "UAMenuAccountAvatarView.h"

#import "UAMediaController.h"

@interface UASideMenuHeaderView ()
{
    UAMenuAccountAvatarView *imageView;
    UILabel *accountLabel;
}

// Logic
- (void)updateView;

@end

@implementation UASideMenuHeaderView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        imageView = [[UAMenuAccountAvatarView alloc] initWithImage:nil];
        [self addSubview:imageView];
        
        [self updateView];
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    imageView.frame = CGRectMake(self.frame.size.width/2.0f - 70.0f/2.0f, self.frame.size.height/2.0f - 70.0f/2.0f, 70.0f, 70.0f);
}

#pragma mark - Logic
- (void)updateView
{
    UIImage *avatar = [UIImage imageNamed:@"DefaultAvatar"];
    
    imageView.image = avatar;
}

@end
