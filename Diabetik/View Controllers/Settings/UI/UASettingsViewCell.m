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
    
    CGFloat indent = 16.0f;
    if(self.imageView.image)
    {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.frame = CGRectMake(15.0f, self.bounds.size.height/2.0f - 30.0f/2.0f, 30.0f, 30.0f);
        self.imageView.layer.cornerRadius = 15.0f;
        self.imageView.layer.masksToBounds = YES;
        
        indent = 55.0f;
    }
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = indent;
    self.textLabel.frame = textLabelFrame;
    
    UIEdgeInsets customSeparatorInset = self.separatorInset;
    customSeparatorInset.left = indent;
    self.separatorInset = customSeparatorInset;
}

@end
