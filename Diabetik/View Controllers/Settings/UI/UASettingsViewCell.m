//
//  UASettingsViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UASettingsViewCell.h"

@implementation UASettingsViewCell

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.imageView.image)
    {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.frame = CGRectMake(15.0f, self.bounds.size.height/2.0f - 30.0f/2.0f, 30.0f, 30.0f);
        self.imageView.layer.cornerRadius = 15.0f;
        self.imageView.layer.masksToBounds = YES;
        
        CGRect textLabelFrame = self.textLabel.frame;
        textLabelFrame.origin.x = 55.0f;
        self.textLabel.frame = textLabelFrame;
        
        UIEdgeInsets customSeparatorInset = self.separatorInset;
        customSeparatorInset.left = 55.0f;
        self.separatorInset = customSeparatorInset;
    }
}

@end
