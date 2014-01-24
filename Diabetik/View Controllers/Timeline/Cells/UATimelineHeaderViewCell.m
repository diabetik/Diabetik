//
//  UATimelineHeaderViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 14/03/2013.
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

#import "UATimelineHeaderViewCell.h"

@interface UATimelineHeaderViewCell ()
{
    UIView *overviewContainer;
    UIView *leftSeparator, *rightSeparator;
}

@end

@implementation UATimelineHeaderViewCell
@synthesize dateLabel = _dateLabel;
@synthesize glucoseStatView = _glucoseStatView;
@synthesize activityStatView = _activityStatView;
@synthesize mealStatView = _mealStatView;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 41.0f)];
        _dateLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        _dateLabel.textColor = [UIColor colorWithRed:98.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_dateLabel];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.0f, self.frame.size.width, 0.5f)];
        topBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        topBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:topBorder];
        
        overviewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.5f, self.frame.size.width, 31.0f)];
        overviewContainer.backgroundColor = [UIColor whiteColor];
        overviewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:overviewContainer];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.5f + overviewContainer.bounds.size.height, self.frame.size.width, 0.5f)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:bottomBorder];
        
        leftSeparator = [[UIView alloc] initWithFrame:CGRectZero];
        leftSeparator.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        leftSeparator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:leftSeparator];
        
        rightSeparator = [[UIView alloc] initWithFrame:CGRectZero];
        rightSeparator.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        rightSeparator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:rightSeparator];
        
        _glucoseStatView = [[UATimelineStatView alloc] initWithFrame:CGRectZero];
        [_glucoseStatView setText:[NSString stringWithFormat:@"0 %@", [NSLocalizedString(@"Avg.", @"Abbreviation for average") lowercaseString]]];
        [_glucoseStatView setImage:[UIImage imageNamed:@"TimelineSummaryIconBlood"]];
        [overviewContainer addSubview:_glucoseStatView];
        
        _activityStatView = [[UATimelineStatView alloc] initWithFrame:CGRectZero];
        [_activityStatView setText:@"00:00"];
        [_activityStatView setImage:[UIImage imageNamed:@"TimelineSummaryIconActivity"]];
        [overviewContainer addSubview:_activityStatView];
   
        _mealStatView = [[UATimelineStatView alloc] initWithFrame:CGRectZero];
        [_mealStatView setText:[NSString stringWithFormat:@"0 %@", [NSLocalizedString(@"Carbs", nil) lowercaseString]]];
        [_mealStatView setImage:[UIImage imageNamed:@"TimelineSummaryIconCarbs"]];
        [overviewContainer addSubview:_mealStatView];
    }
    
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat segmentWidth = floorf((self.bounds.size.width/3.0f)-2.0f);
    
    _glucoseStatView.frame = CGRectMake(0.0f, 0.0f, segmentWidth, overviewContainer.bounds.size.height);
    _activityStatView.frame = CGRectMake(segmentWidth, 0.0f, segmentWidth, overviewContainer.bounds.size.height);
    _mealStatView.frame = CGRectMake((segmentWidth)*2.0f, 0.0f, segmentWidth, overviewContainer.bounds.size.height);
    
    leftSeparator.frame = CGRectMake(segmentWidth+0.5f, 41.5f, 0.5f, overviewContainer.bounds.size.height);
    rightSeparator.frame = CGRectMake((segmentWidth+0.5f)*2.0f, 41.5f, 0.5f, overviewContainer.bounds.size.height);
}
- (void)setDate:(NSString *)text
{
    _dateLabel.text = text;
}

@end
