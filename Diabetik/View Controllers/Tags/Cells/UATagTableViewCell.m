//
//  UATagTableViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 26/01/2014.
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

#import "UATagTableViewCell.h"

@implementation UATagTableViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.badgeView = [[UABadgeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 25.0f)];
        [self.contentView addSubview:self.badgeView];
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.badgeView.frame = CGRectMake(self.contentView.bounds.size.width - self.badgeView.bounds.size.width, ceilf(self.contentView.bounds.size.height/2.0f - self.badgeView.bounds.size.height/2.0f), self.badgeView.bounds.size.width, self.badgeView.bounds.size.height);
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self.badgeView setHighlighted:highlighted];
}
@end
