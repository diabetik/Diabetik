//
//  UASideMenuCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/12/2012.
//  Copyright 2013 Nial Giacomelli
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
{
    UIView *bottomBorder;
}
@end

@implementation UASideMenuCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.textColor = [UIColor colorWithRed:92.0f/255.0f green:102.0f/255.0f blue:99.0f/255.0f alpha:1.0f];
        self.textLabel.font = [UAFont standardMediumFontWithSize:16.0f];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
        self.selectedBackgroundView = selectedBackgroundView;
        
        self.accessoryIcon = [[UIImageView alloc] initWithFrame:CGRectMake(14.0f, 0.0f, 28.0f, self.bounds.size.height)];
        self.accessoryIcon.contentMode = UIViewContentModeCenter|UIViewContentModeLeft;
        [self.contentView addSubview:self.accessoryIcon];
        
        self.rightAccessoryIcon = [[UIImageView alloc] initWithFrame:CGRectMake(246.0f, 0.0f, 10.0f, self.bounds.size.height)];
        self.rightAccessoryIcon.contentMode = UIViewContentModeCenter;
        self.rightAccessoryIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.rightAccessoryIcon];
        
        // Borders
        /*
        topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, self.bounds.size.width, 1.0f)];
        topBorder.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        topBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        topBorder.hidden = YES;
        [self.contentView addSubview:topBorder];
         */
        
        bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(40.0f, self.bounds.size.height-1.0f, self.bounds.size.width, 0.5f)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
        bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:bottomBorder];

    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(43.0f, 0.0f, 198.0f, 44.0f);
    self.detailTextLabel.frame = CGRectMake(43.0f, 22.0f, 198.0f, 44.0f);
    self.accessoryIcon.frame = CGRectMake(self.accessoryIcon.frame.origin.x, self.frame.size.height/2 - self.accessoryIcon.frame.size.height/2, self.accessoryIcon.frame.size.width, self.accessoryIcon.frame.size.height);
}

#pragma mark - Logic
- (void)showBottomBorder:(BOOL)state
{
    bottomBorder.hidden = !state;
}

@end