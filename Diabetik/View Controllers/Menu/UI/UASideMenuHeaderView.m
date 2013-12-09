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
    
    id accountSwitchNotifier;
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
        
        __weak typeof(self) weakSelf = self;
        accountSwitchNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:kAccountsSwitchedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf updateView];
        }];
        
        [self updateView];
    }
    
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:accountSwitchNotifier];
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
