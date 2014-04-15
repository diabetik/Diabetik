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

#import "NSDate+Extension.h"
#import <QuartzCore/QuartzCore.h>
#import "UATimelineViewCell.h"
#import "UAMediaController.h"

#import "UATimelineViewController.h"

#import "UATagHighlightTextStorage.h"

#define kNotesFont [UIFont fontWithName:@"Avenir-LightOblique" size:15.0f]
#define kNotesBottomVerticalPadding 13.0f
#define kBottomVerticalPadding 12.0f
#define kHorizontalMargin 16.0f

#define kInlinePhotoHeight 150.0f
#define kInlinePhotoInset 5.0f

@interface UATimelineViewCell ()
{
    NSDate *date;
    UATagHighlightTextStorage *textStorage;
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
        _timestampLabel.textAlignment = NSTextAlignmentLeft;
        _timestampLabel.lineBreakMode = NSLineBreakByClipping;
        _timestampLabel.clipsToBounds = NO;
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
    
    CGFloat x = 43.0f;
    
    CGSize timestampLabelSize = [self.timestampLabel.text sizeWithAttributes:@{NSFontAttributeName:self.timestampLabel.font}];
    self.timestampLabel.frame = CGRectMake(x, 13.0f, timestampLabelSize.width, 19.0f);
    x += timestampLabelSize.width + 6.0f;
    
    CGRect descriptionLabelFrame = CGRectMake(x, 13.0f, ceilf(self.bounds.size.width-96.0f-kHorizontalMargin), 19.0f);
    CGSize valueLabelSize = CGSizeZero;
    if(self.valueLabel && self.valueLabel.text)
    {
        valueLabelSize = [self.valueLabel.text sizeWithAttributes:@{NSFontAttributeName:self.valueLabel.font}];
        self.valueLabel.frame = CGRectMake(self.contentView.bounds.size.width-(valueLabelSize.width+kHorizontalMargin), 13.0f, valueLabelSize.width, 19.0f);

        descriptionLabelFrame = CGRectMake(x, 13.0f, ceilf(self.valueLabel.frame.origin.x-(x+5.0f)), 19.0f);
    }
    self.descriptionLabel.frame = descriptionLabelFrame;
    x += descriptionLabelFrame.size.width;
    
    if(self.notesTextView && self.notesTextView.text)
    {
        CGFloat maxNotesWidth = ceilf(self.contentView.bounds.size.width-self.descriptionLabel.frame.origin.x-kHorizontalMargin);
        CGRect notesFrame = [self.notesTextView.text boundingRectWithSize:CGSizeMake(maxNotesWidth, CGFLOAT_MAX)
                                                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                               attributes:@{NSFontAttributeName:self.notesTextView.font}
                                                                  context:nil];
        
        CGFloat width = notesFrame.size.width < maxNotesWidth ? notesFrame.size.width : maxNotesWidth;
        self.notesTextView.frame = CGRectMake(ceilf(self.descriptionLabel.frame.origin.x), ceilf(self.notesTextView.frame.origin.y), ceilf(width), ceilf(notesFrame.size.height));
    }
    
    if(self.cellPosition == UACellBackgroundViewPositionBottom)
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
    
    if(self.notesTextView)
    {
        [self.notesTextView removeFromSuperview], self.notesTextView = nil;
    }
    [self setPhotoImage:nil];
}
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
          withController:(UIViewController *)controller
               indexPath:(NSIndexPath *)indexPath
            andTableView:(UITableView *)tableView
{
    UITextView *textView = self.notesTextView;
    
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    BOOL didTapTag = NO;
    if (CGRectContainsPoint(textView.bounds, location) && characterIndex < textView.textStorage.length)
    {
        NSRange range;
        NSString *tagValue = [textView.attributedText attribute:@"tag" atIndex:characterIndex effectiveRange:&range];
    
        if(tagValue)
        {
            didTapTag = YES;
            
            UATimelineViewController *timelineVC = [[UATimelineViewController alloc] initWithTag:tagValue];
            [controller.navigationController pushViewController:timelineVC animated:YES];
        }
    }
    
    if(!didTapTag)
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        id<UITableViewDelegate> delegate = tableView.delegate;
        [delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Accessors
- (void)setDate:(NSDate *)aDate
{
    NSDateFormatter *formatter = [UAHelper hhmmTimeFormatter];
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
            if(self.notesTextView)
            {
                [self.notesTextView removeFromSuperview];
                self.notesTextView = nil;
            }
            
            CGRect frame = CGRectMake(96.0f, 36.0f, self.contentView.bounds.size.width-96.0f-kHorizontalMargin, 17.0f);
            CGSize containerSize = CGSizeMake(frame.size.width,  CGFLOAT_MAX);
            
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:containerSize];
            textContainer.widthTracksTextView = YES;
            
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
            [layoutManager addTextContainer:textContainer];
            
            textStorage = [[UATagHighlightTextStorage alloc] init];
            [textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:notes]];
            [textStorage addLayoutManager:layoutManager];
    
            self.notesTextView = [[UITextView alloc] initWithFrame:frame textContainer:textContainer];
            self.notesTextView.backgroundColor = [UIColor clearColor];
            self.notesTextView.font = kNotesFont;
            self.notesTextView.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
            self.notesTextView.editable = NO;
            self.notesTextView.textContainer.lineFragmentPadding = 0;
            self.notesTextView.textContainerInset = UIEdgeInsetsZero;
            self.notesTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.notesTextView.userInteractionEnabled = NO;
            [self addSubview:self.notesTextView];
        }
        else
        {
            if(self.notesTextView)
            {
                [self.notesTextView removeFromSuperview];
                self.notesTextView = nil;
            }
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
    
    if(highlighted)
    {
        if(self.notesTextView)
        {
            self.notesTextView.textColor = [UIColor whiteColor];
        }
        else
        {
            self.notesTextView.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
        }
    }
    
    bottomBorder.hidden = highlighted;
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
