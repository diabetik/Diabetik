//
//  UASettingsTextViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 22/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UASettingsTextViewCell.h"

@implementation UASettingsTextViewCell

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accessoryView.frame = CGRectInset(self.bounds, 15.0f, 0.0f);
}

@end
