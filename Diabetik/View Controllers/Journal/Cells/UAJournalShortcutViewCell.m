//
//  UAJournalShortcutViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/04/2013.
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

#import "UAJournalShortcutViewCell.h"

@interface UAJournalShortcutViewCell ()
{
    UIView *borderView;
}

@end

@implementation UAJournalShortcutViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        borderView = [[UIView alloc] initWithFrame:CGRectMake(44.0f, self.bounds.size.height-1.0f, self.bounds.size.width-44.0f, 1.0f)];
        borderView.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
        borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [self.backgroundView addSubview:borderView];
    }
    
    return self;
}


#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(12.0f, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.textLabel.frame = CGRectMake(44.0f, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

@end
