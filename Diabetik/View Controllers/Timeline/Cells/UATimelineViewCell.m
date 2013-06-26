//
//  UATimelineViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 23/01/2013.
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

#import <QuartzCore/QuartzCore.h>
#import "UATimelineViewCell.h"
#import "UAMediaController.h"

#define kNotesFont [UAFont standardMediumFontWithSize:13.0f]
#define kNotesBottomVerticalPadding 13.0f
#define kBottomVerticalPadding 12.0f
#define kHorizontalMargin 8.0f

@interface UATimelineViewCell ()
{
    NSDate *date;
    BOOL isFooter;
}
@end

@implementation UATimelineViewCell
@synthesize iconImageView = _iconImageView;
@synthesize metadata = _metadata;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize valueLabel = _valueLabel;
@synthesize timestampLabel = _timestampLabel;
@synthesize notesLabel = _notesLabel;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        isFooter = NO;
        
        UIImageView *background = [[UIImageView alloc] initWithFrame:self.bounds];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        background.backgroundColor = [UIColor clearColor];
        self.backgroundView = background;
        
        UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:self.bounds];
        selectedBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectedBackground.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBackground;
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 15.0f, 15.0f, 15.0f)];
        _iconImageView.image = [UIImage imageNamed:@"TimelineMealIcon.png"];
        _iconImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconImageView];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(89.0f, 15.0f, 175.0f, 17.0f)];
        _descriptionLabel.text = @"Entry description";
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = [UAFont standardDemiBoldFontWithSize:15.0f];
        _descriptionLabel.textColor = [UIColor colorWithRed:115.0f/255.0f green:128.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
        _descriptionLabel.highlightedTextColor = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
        _descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_descriptionLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 15.0f, 240.0f, 17.0f)];
        _valueLabel.text = @"0.0";
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.font = [UAFont standardDemiBoldFontWithSize:15.0f];
        _valueLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        _valueLabel.highlightedTextColor = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
        _valueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_valueLabel];

        _timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0f, 15.0f, 50.0f, 17.0f)];
        _timestampLabel.text = @"00:00";
        _timestampLabel.backgroundColor = [UIColor clearColor];
        _timestampLabel.font = [UAFont standardMediumFontWithSize:15.0f];
        _timestampLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        _timestampLabel.highlightedTextColor = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
        [self addSubview:_timestampLabel];
    }
    return self;
}

#pragma mark - Logic
- (void)setDate:(NSDate *)aDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *formattedTimestamp = [formatter stringFromDate:aDate];

    self.timestampLabel.text = formattedTimestamp;
    date = aDate;
    
    [self setNeedsDisplay];
}
- (void)setMetaData:(NSDictionary *)data
{
    _metadata = data;
    
    if(_metadata)
    {
        NSString *notes = [data valueForKey:@"notes"];
        if(notes)
        {
            if(!self.notesLabel)
            {
                self.notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(89.0f, 36.0f, 205.0f, 17.0f)];
                self.notesLabel.text = @"Entry description";
                self.notesLabel.backgroundColor = [UIColor clearColor];
                self.notesLabel.font = kNotesFont;
                self.notesLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
                self.notesLabel.highlightedTextColor = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
                self.notesLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
                self.notesLabel.numberOfLines = 0;
                self.notesLabel.lineBreakMode = NSLineBreakByWordWrapping;
                self.notesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [self addSubview:self.notesLabel];
            }
            
            CGSize notesSize = [notes sizeWithFont:kNotesFont constrainedToSize:CGSizeMake(205.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            self.notesLabel.frame = CGRectMake(self.notesLabel.frame.origin.x, self.notesLabel.frame.origin.y, self.notesLabel.frame.size.width, notesSize.height);
            self.notesLabel.text = notes;
        }
        else
        {
            [self.notesLabel removeFromSuperview], self.notesLabel = nil;
        }
        
        [self setNeedsDisplay];
    }
}

#pragma mark - Logic
- (void)setCellStyleWithIndexPath:(NSIndexPath *)indexPath andTotalRows:(NSInteger)totalRows
{
    UACellPosition position = UACellBackgroundViewPositionMiddle;
    if(indexPath.row == 1)
    {
        position = UACellBackgroundViewPositionTop;
    }
    else if(indexPath.row == totalRows-1)
    {
        position = UACellBackgroundViewPositionBottom;
    }
    
    UIImageView *background = (UIImageView *)self.backgroundView;
    UIImageView *selectedBackground = (UIImageView *)self.selectedBackgroundView;
    switch(position)
    {
        case UACellBackgroundViewPositionTop:
            if(totalRows > 2)
            {
                background.image = [[UIImage imageNamed:@"TimelineCardCellTop.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(43, 159, 1, 159)];
                selectedBackground.image = [[UIImage imageNamed:@"TimelineCardCellTopPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(43, 159, 1, 159)];
            }
            else
            {
                background.image = [[UIImage imageNamed:@"TimelineCardCellTopRounded.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 159, 5, 159)];
                selectedBackground.image = [[UIImage imageNamed:@"TimelineCardCellTopRoundedPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 159, 5, 159)];
            }
            
            break;
        case UACellBackgroundViewPositionMiddle:
            background.image = [[UIImage imageNamed:@"TimelineCardCellMiddle.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 1, 7)];
            selectedBackground.image = [[UIImage imageNamed:@"TimelineCardCellMiddlePressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 1, 7)];
            
            break;
        case UACellBackgroundViewPositionBottom:
            background.image = [[UIImage imageNamed:@"TimelineCardCellBottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 6, 14)];
            selectedBackground.image = [[UIImage imageNamed:@"TimelineCardCellBottomPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 6, 14)];
            
            break;
        case UACellBackgroundViewPositionSingle:
            // Not possible
            break;
    }
}

#pragma mark - Helpers
+ (CGFloat)additionalHeightWithMetaData:(NSDictionary *)data
{
    CGFloat height = 0.0f;

    NSString *notes = [data objectForKey:@"notes"];
    if(notes)
    {
        CGSize notesSize = [notes sizeWithFont:kNotesFont constrainedToSize:CGSizeMake(205.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        height += notesSize.height+kNotesBottomVerticalPadding - 8.0f;
    }
    
    return height;
}

@end
