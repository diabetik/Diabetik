//
//  UATimelineHeaderViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 14/03/2013.
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

#import "UATimelineHeaderViewCell.h"

@implementation UATimelineHeaderViewCell
@synthesize dateLabel = _dateLabel;
@synthesize glucoseLabel = _glucoseLabel;
@synthesize activityLabel = _activityLabel;
@synthesize mealLabel = _mealLabel;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
        
        UIView *statsBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.0f, self.frame.size.width, 31.0f)];
        statsBackgroundView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:statsBackgroundView];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.0f, self.frame.size.width, 0.5f)];
        topBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:topBorder];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineSummaryBackgroundArrow"]];
        arrow.frame = CGRectMake(self.frame.size.width/2.0f - arrow.image.size.width/2.0f, 41.5f-arrow.image.size.height, arrow.image.size.width, arrow.image.size.height);
        [self.contentView addSubview:arrow];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40.0f)];
        _dateLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        _dateLabel.textColor = [UIColor colorWithRed:98.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_dateLabel];
        
        UIImageView *glucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineCardHeaderIconBloodGlucose.png"]];
        glucoseImageView.frame = CGRectMake(46.0f, 19.0f, glucoseImageView.frame.size.width, glucoseImageView.frame.size.height);
        [statsBackgroundView addSubview:glucoseImageView];
        
        _glucoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 66.0f, 100.0f, 16.0f)];
        _glucoseLabel.backgroundColor = [UIColor clearColor];
        _glucoseLabel.text = @"0.0 avg";
        _glucoseLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        _glucoseLabel.textAlignment = NSTextAlignmentCenter;
        _glucoseLabel.textColor = [UIColor colorWithRed:148.0f/255.0f green:158.0f/255.0f blue:155.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:_glucoseLabel];
        
        UIImageView *activityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineCardHeaderIconSummary.png"]];
        activityImageView.frame = CGRectMake(111.0f + (50 - activityImageView.frame.size.width/2), 49.0f, activityImageView.frame.size.width, activityImageView.frame.size.height);
        [self.contentView addSubview:activityImageView];
        
        _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(111.0f, 66.0f, 100.0f, 16.0f)];
        _activityLabel.backgroundColor = [UIColor clearColor];
        _activityLabel.text = @"00:00";
        _activityLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        _activityLabel.textAlignment = NSTextAlignmentCenter;
        _activityLabel.textColor = [UIColor colorWithRed:148.0f/255.0f green:158.0f/255.0f blue:155.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:_activityLabel];
        
        UIImageView *mealImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineCardHeaderIconMeals.png"]];
        mealImageView.frame = CGRectMake(211.0f + (50 - mealImageView.frame.size.width/2), 49.0f, mealImageView.frame.size.width, mealImageView.frame.size.height);
        [self.contentView addSubview:mealImageView];
        
        _mealLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0f, 66.0f, 100.0f, 16.0f)];
        _mealLabel.backgroundColor = [UIColor clearColor];
        _mealLabel.text = @"0 g";
        _mealLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        _mealLabel.textAlignment = NSTextAlignmentCenter;
        _mealLabel.textColor = [UIColor colorWithRed:148.0f/255.0f green:158.0f/255.0f blue:155.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:_mealLabel];
    }
    
    return self;
}

#pragma mark - Logic
- (void)setDate:(NSString *)text
{
    _dateLabel.text = text;
}

@end
