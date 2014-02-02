//
//  UAKeyboardShortcutButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 31/01/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UAKeyboardShortcutButton.h"

@implementation UAKeyboardShortcutButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:219.0f/255.0f alpha:1.0f].CGColor;
        self.layer.cornerRadius = 3.0f;
        self.layer.borderWidth = 0.5f;
        self.layer.masksToBounds = YES;
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.tintColor = [UIColor redColor];
    }
    return self;
}

#pragma mark - Logic
- (void)setHighlighted:(BOOL)highlighted
{
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Accessors
- (UIImageView *)fullsizeImageView
{
    if(!_fullsizeImageView)
    {
        _fullsizeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _fullsizeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fullsizeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self insertSubview:_fullsizeImageView aboveSubview:self.imageView];
    }
    
    return _fullsizeImageView;
}

@end
