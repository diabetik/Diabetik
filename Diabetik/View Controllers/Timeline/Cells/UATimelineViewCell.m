//
//  UATimelineViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 23/01/2013.
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

#import <QuartzCore/QuartzCore.h>
#import "UATimelineViewCell.h"
#import "UAMediaController.h"

#define kNotesFont [UAFont standardRegularFontWithSize:13.0f]
#define kNotesBottomVerticalPadding 13.0f
#define kBottomVerticalPadding 12.0f
#define kHorizontalMargin 16.0f

#define kInlinePhotoHeight 150.0f
#define kInlinePhotoInset 5.0f

@interface UATimelineViewCell ()
{
    NSDate *date;
    UACellPosition cellPosition;
    
    UIView *bottomBorder;
}
@end

@implementation UATimelineViewCell
@synthesize iconImageView = _iconImageView;
@synthesize metadata = _metadata;
@synthesize photoImageView = _photoImageView;
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
        self.backgroundColor = [UIColor whiteColor];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 15.0f, 16.0f, 16.0f)];
        _iconImageView.image = [UIImage imageNamed:@"TimelineMealIcon.png"];
        _iconImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_iconImageView];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.text = @"Entry description";
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = [UAFont standardMediumFontWithSize:16.0f];
        _descriptionLabel.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        _descriptionLabel.highlightedTextColor = [UIColor whiteColor];
        _descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_descriptionLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.text = @"0.0";
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.font = [UAFont standardRegularFontWithSize:16.0f];
        _valueLabel.textColor = [UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        _valueLabel.highlightedTextColor = [UIColor whiteColor];
        _valueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:_valueLabel];

        _timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(43.0f, 13.0f, 50.0f, 19.0f)];
        _timestampLabel.text = @"00:00";
        _timestampLabel.backgroundColor = [UIColor clearColor];
        _timestampLabel.font = [UAFont standardRegularFontWithSize:16.0f];
        _timestampLabel.textColor = [UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        _timestampLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_timestampLabel];
        
        bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bottomBorder];
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect descriptionLabelFrame = CGRectMake(96.0f, 13.0f, ceilf(self.bounds.size.width-96.0f-kHorizontalMargin), 19.0f);
    if(self.valueLabel && self.valueLabel.text)
    {
        CGRect valueFrame = [self.valueLabel.text boundingRectWithSize:CGSizeMake(self.valueLabel.bounds.size.width, CGFLOAT_MAX)
                                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                            attributes:@{NSFontAttributeName:self.valueLabel.font}
                                                               context:nil];
        descriptionLabelFrame.size.width -= ceilf(valueFrame.size.width + 10.0f);
    }
    _descriptionLabel.frame = descriptionLabelFrame;
    _valueLabel.frame = CGRectMake(96.0f, 13.0f, ceilf(self.bounds.size.width-96.0f-kHorizontalMargin), 19.0f);

    if(self.notesLabel && self.notesLabel.text)
    {
        CGRect notesFrame = [self.notesLabel.text boundingRectWithSize:CGSizeMake(self.notesLabel.bounds.size.width, CGFLOAT_MAX)
                                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                            attributes:@{NSFontAttributeName:self.notesLabel.font}
                                                               context:nil];
        
        self.notesLabel.frame = CGRectMake(ceilf(self.notesLabel.frame.origin.x), ceilf(self.notesLabel.frame.origin.y), ceilf(self.notesLabel.frame.size.width), ceilf(notesFrame.size.height));
    }
    
    if(cellPosition == UACellBackgroundViewPositionBottom)
    {
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-0.5f, self.bounds.size.width, 0.5f);
    }
    else
    {
        bottomBorder.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        bottomBorder.frame = CGRectMake(44.0f, self.bounds.size.height-0.5f, self.bounds.size.width, 0.5f);
    }
    
    if(self.photoImageView)
    {
        self.photoImageView.frame = CGRectMake(kInlinePhotoInset, self.contentView.bounds.size.height-(kInlinePhotoHeight+kInlinePhotoInset), self.contentView.bounds.size.width-(kInlinePhotoInset*2.0f), kInlinePhotoHeight-kInlinePhotoInset);
    }
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.notesLabel removeFromSuperview], self.notesLabel = nil;
    [self setPhotoImage:nil];
}
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
                self.notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(96.0f, 36.0f, self.bounds.size.width-96.0f-kHorizontalMargin, 17.0f)];
                self.notesLabel.text = @"Entry description";
                self.notesLabel.backgroundColor = [UIColor clearColor];
                self.notesLabel.font = kNotesFont;
                self.notesLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
                self.notesLabel.highlightedTextColor = [UIColor whiteColor];
                self.notesLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
                self.notesLabel.numberOfLines = 0;
                self.notesLabel.lineBreakMode = NSLineBreakByWordWrapping;
                self.notesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [self addSubview:self.notesLabel];
            }
            
            self.notesLabel.text = notes;
        }
        else
        {
            [self.notesLabel removeFromSuperview], self.notesLabel = nil;
        }

        [self setNeedsLayout];
    }
}

#pragma mark - Setters
- (void)setPhotoImage:(UIImage *)image
{
    if(!image)
    {
        if(self.photoImageView)
        {
            [self.photoImageView removeFromSuperview], self.photoImageView = nil;
        }
        return;
    }
    
    if(!self.photoImageView)
    {
        self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.photoImageView.clipsToBounds = YES;
        self.photoImageView.layer.cornerRadius = 4;
        [self.contentView addSubview:self.photoImageView];
    }
    self.photoImageView.image = image;
    
    [self setNeedsLayout];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    bottomBorder.hidden = highlighted;
}
- (void)setCellStyleWithIndexPath:(NSIndexPath *)indexPath andTotalRows:(NSInteger)totalRows
{
    UACellPosition position = UACellBackgroundViewPositionMiddle;
    if(indexPath.row == totalRows-1)
    {
        position = UACellBackgroundViewPositionBottom;
    }
    else if(indexPath.row == 1)
    {
        position = UACellBackgroundViewPositionTop;
    }
    
    cellPosition = position;
}

#pragma mark - Helpers
+ (CGFloat)additionalHeightWithMetaData:(NSDictionary *)data width:(CGFloat)width
{
    CGFloat height = 0.0f;

    NSString *notes = [data objectForKey:@"notes"];
    if(notes)
    {
        CGRect notesFrame = [notes boundingRectWithSize:CGSizeMake(width-96.0f-kHorizontalMargin, CGFLOAT_MAX)
                                                options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                             attributes:@{NSFontAttributeName:kNotesFont}
                                                context:nil];
        
        height += notesFrame.size.height+kNotesBottomVerticalPadding - 8.0f;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kShowInlineImages])
    {
        NSString *photoPath = [data valueForKey:@"photoPath"];
        if(photoPath)
        {
            height += kInlinePhotoHeight + kInlinePhotoInset;
        }
    }
    
    return height;
}

@end
