//
//  UAMenuAccountSelectionView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 28/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UAMenuAccountSelectionView.h"
#import "UAMenuAccountAvatarView.h"

#import "UAAccountController.h"
#import "UAMediaController.h"

@interface UAMenuAccountSelectionView ()
{
    UIScrollView *scrollView;
}

// Logic
- (void)updateAccounts;

@end

@implementation UAMenuAccountSelectionView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:scrollView];
        
        [self updateAccounts];
    }
    
    return self;
}

#pragma mark - Logic
- (void)updateAccounts
{
    for(UIView *subview in scrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    NSArray *accounts = [[UAAccountController sharedInstance] accounts];
    for(UAAccount *account in accounts)
    {
        UIImage *avatar = [[UAMediaController sharedInstance] imageWithFilename:account.photoPath];
        if(!avatar)
        {
            avatar = [UIImage imageNamed:@"DefaultAvatar.png"];
        }
        
        UAMenuAccountAvatarView *imageView = [[UAMenuAccountAvatarView alloc] initWithImage:avatar];
        imageView.frame = CGRectMake(self.frame.size.width/2.0f - 50.0f/2.0f, self.frame.size.height/2.0f - 50.0f/2.0f, 50.0f, 50.0f);
        
        [scrollView addSubview:imageView];
    }
}

@end
