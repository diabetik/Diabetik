//
//  UAGenericTableViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 16/03/2013.
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
        background.backgroundColor = [UIColor whiteColor];
        self.backgroundView = background;
        
        UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:self.bounds];
        selectedBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectedBackground.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:211.0f/255.0f blue:160.0f/255.0f alpha:1.0f];
        self.selectedBackgroundView = selectedBackground;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor colorWithRed:73.0f/255.0f green:76.0f/255.0f blue:76.0f/255.0f alpha:1.0];
        self.textLabel.font = [UAFont standardRegularFontWithSize:16.0f];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.5f;
        
        self.detailTextLabel.font = [UAFont standardRegularFontWithSize:13.0f];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = 16.0f;
    if(self.imageView && self.imageView.image)
    {
        CGFloat y = ceilf(self.contentView.bounds.size.height/2.0f - self.imageView.bounds.size.height/2.0f);
        self.imageView.frame = CGRectMake(x, y, self.imageView.frame.size.width, self.imageView.frame.size.height);
        x += self.imageView.frame.size.width + 10.0f;
    }
    
    if(self.textLabel && self.textLabel.text)
    {
        CGSize titleSize = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:self.textLabel.font}];
        CGSize detailSize = CGSizeZero;
        CGFloat height = titleSize.height;
        
        if(self.detailTextLabel && self.detailTextLabel.text)
        {
            detailSize = [self.detailTextLabel.text sizeWithAttributes:@{NSFontAttributeName:self.detailTextLabel.font}];
            height += detailSize.height;
        }
        
        CGFloat y = ceilf(self.bounds.size.height/2.0f - height/2.0f);
        CGFloat width = titleSize.width > detailSize.width ? titleSize.width : detailSize.width;
        self.textLabel.frame = CGRectMake(x, y, titleSize.width, titleSize.height);
        if(self.detailTextLabel && self.detailTextLabel.text)
        {
            self.detailTextLabel.frame = CGRectMake(x, ceilf(y+titleSize.height), detailSize.width, detailSize.height);
        }
        x += ceilf(width + 10.0f);
    }
    
    if(self.accessoryControl)
    {
        self.accessoryView.frame = CGRectMake(x, 0.0f, self.bounds.size.width-x-16.0f, self.contentView.bounds.size.height);
        
        UIView *control = (UIView *)self.accessoryControl;
        CGRect controlFrame = CGRectZero;
        if(control.bounds.size.width < self.accessoryView.bounds.size.width)
        {
            CGFloat y = ceilf(control.bounds.size.height < self.accessoryView.bounds.size.height ? (self.accessoryView.bounds.size.height-control.bounds.size.height)/2.0f : 0.0f);
            controlFrame = CGRectMake(self.accessoryView.bounds.size.width-control.bounds.size.width, y, control.bounds.size.width, control.bounds.size.height);
        }
        else
        {
            controlFrame = self.accessoryView.bounds;
        }
        [control setFrame:controlFrame];
    }
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
    
    self.cellPosition = position;
}
- (void)setAccessoryView:(UIView *)controlView
{
    self.accessoryControl = controlView;
    
    if(controlView)
    {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [containerView addSubview:controlView];
        [super setAccessoryView:containerView];
    }
    else
    {
        [super setAccessoryView:controlView];
    }
}
@end
