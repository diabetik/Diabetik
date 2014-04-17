//
//  UASideMenuCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/12/2012.
//  Copyright (c) 2013-2014 Nial Giacomelli
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "UASideMenuCell.h"

@interface UASideMenuCell ()
@end

@implementation UASideMenuCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        
        self.textLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.45f];
        self.textLabel.font = [UAFont standardMediumFontWithSize:16.0f];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.autoresizingMask = UIViewAutoresizingNone;
        
        self.detailTextLabel.font = [UAFont standardRegularFontWithSize:12.0f];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
        
        self.accessoryIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 28.0f, self.bounds.size.height)];
        self.accessoryIcon.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.accessoryIcon];
        
        UIEdgeInsets customSeparatorInset = self.separatorInset;
        customSeparatorInset.left = 0.0f;
        self.separatorInset = customSeparatorInset;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleHeight = 18.0f;
    CGFloat detailHeight = 16.0f;
    CGFloat height = titleHeight;
    if(self.detailTextLabel.text)
    {
        height += 3.0f + detailHeight;
    }
    CGFloat y = ceilf(self.contentView.bounds.size.height/2.0f - height/2.0f);
    
    self.textLabel.frame = CGRectMake(45.0f, y, 198.0f, titleHeight);
    self.detailTextLabel.frame = CGRectMake(45.0f, y + 3.0f + self.textLabel.frame.size.height, 198.0f, detailHeight);
    self.accessoryIcon.frame = CGRectMake(self.accessoryIcon.frame.origin.x, ceilf(self.frame.size.height/2 - self.accessoryIcon.frame.size.height/2), self.accessoryIcon.frame.size.width, self.accessoryIcon.frame.size.height);
}

@end