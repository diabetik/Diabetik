//
//  UAGenericTableViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 16/03/2013.
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

#import "UAGenericTableViewCell.h"

#define kMaxAccessoryWidth 200.0f

@implementation UAGenericTableViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImageView *background = [[UIImageView alloc] initWithFrame:self.bounds];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        background.backgroundColor = [UIColor clearColor];
        self.backgroundView = background;
        
        UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:self.bounds];
        selectedBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectedBackground.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBackground;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor colorWithRed:115.0f/255.0f green:127.0f/255.0f blue:123.0f/255.0f alpha:1.0];
        self.textLabel.font = [UAFont standardDemiBoldFontWithSize:16.0f];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.highlightedTextColor = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.5f;
        
        self.detailTextLabel.font = [UAFont standardRegularFontWithSize:13.0f];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.highlightedTextColor = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x+3.0f, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
}

#pragma mark - Logic
- (void)setCellStyleWithIndexPath:(NSIndexPath *)indexPath andTotalRows:(NSInteger)totalRows
{
    UACellPosition position = UACellBackgroundViewPositionMiddle;
    if(totalRows == 1)
    {
        position = UACellBackgroundViewPositionSingle;
    }
    else
    {
        if(indexPath.row == 0)
        {
            position = UACellBackgroundViewPositionTop;
        }
        else if(indexPath.row == totalRows-1)
        {
            position = UACellBackgroundViewPositionBottom;
        }
    }
}
- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    if(accessoryType == UITableViewCellAccessoryDisclosureIndicator)
    {
        UIImageView *chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chevron.png"]];
        [chevronImageView setHighlightedImage:[UIImage imageNamed:@"ChevronPressed.png"]];
        self.accessoryView = chevronImageView;
    }
    else
    {
        [super setAccessoryType:accessoryType];
    }
}
- (void)setAccessoryView:(UIView *)controlView
{
    self.accessoryControl = controlView;
    
    if(controlView)
    {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (controlView.frame.size.width < kMaxAccessoryWidth ? controlView.frame.size.width+10.0f : kMaxAccessoryWidth), self.frame.size.height)];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        controlView.frame = CGRectMake(floorf(containerView.frame.size.width - controlView.frame.size.width - 15.0f), floorf(containerView.frame.size.height/2-controlView.frame.size.height/2), controlView.frame.size.width, controlView.frame.size.height);
        [containerView addSubview:controlView];
        
        [super setAccessoryView:containerView];
    }
    else
    {
        [super setAccessoryView:controlView];
    }
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(highlighted)
    {
        self.textLabel.shadowColor = [UIColor clearColor];
    }
    else
    {
        self.textLabel.shadowColor = [UIColor whiteColor];
    }
    
    [super setHighlighted:highlighted animated:animated];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if(selected)
    {
        self.textLabel.shadowColor = [UIColor clearColor];
    }
    else
    {
        self.textLabel.shadowColor = [UIColor whiteColor];
    }
    
    [super setSelected:selected animated:animated];
}
@end
