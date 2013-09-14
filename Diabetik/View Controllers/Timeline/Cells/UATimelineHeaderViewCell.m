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
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40.0f)];
        _dateLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        _dateLabel.textColor = [UIColor colorWithRed:98.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_dateLabel];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.0f, self.frame.size.width, 0.5f)];
        topBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:topBorder];
        
        UIView *overviewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.5f, self.frame.size.width, 31.0f)];
        overviewContainer.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:overviewContainer];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 41.5f + overviewContainer.bounds.size.height, self.frame.size.width, 0.5f)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:bottomBorder];
        
        UIView *leftSeparator = [[UIView alloc] initWithFrame:CGRectMake(101.5f, 41.5f, 0.5f, overviewContainer.bounds.size.height)];
        leftSeparator.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:leftSeparator];
        
        UIView *rightSeparator = [[UIView alloc] initWithFrame:CGRectMake(213.0f, 41.5f, 0.5f, overviewContainer.bounds.size.height)];
        rightSeparator.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:rightSeparator];
        
        UIImageView *glucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineSummaryIconBlood"]];
        glucoseImageView.frame = CGRectMake(23.0f, 10.0f, glucoseImageView.frame.size.width, glucoseImageView.frame.size.height);
        [overviewContainer addSubview:glucoseImageView];
        
        _glucoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0f, 9.0f, 100.0f, 16.0f)];
        _glucoseLabel.backgroundColor = [UIColor clearColor];
        _glucoseLabel.text = [NSString stringWithFormat:@"0 %@", [NSLocalizedString(@"Avg.", @"Abbreviation for average") lowercaseString]];
        _glucoseLabel.font = [UAFont standardMediumFontWithSize:11.0f];
        _glucoseLabel.textColor = [UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        [overviewContainer addSubview:_glucoseLabel];
        
        UIImageView *activityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineSummaryIconActivity"]];
        activityImageView.frame = CGRectMake(136.0f, 10.0f, activityImageView.frame.size.width, activityImageView.frame.size.height);
        [overviewContainer addSubview:activityImageView];
        
        _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(151.0f, 9.0f, 100.0f, 16.0f)];
        _activityLabel.backgroundColor = [UIColor clearColor];
        _activityLabel.text = @"00:00";
        _activityLabel.font = [UAFont standardMediumFontWithSize:11.0f];
        _activityLabel.textColor = [UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        [overviewContainer addSubview:_activityLabel];
        
        UIImageView *mealImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineSummaryIconCarbs"]];
        mealImageView.frame = CGRectMake(239.0f, 10.0f, mealImageView.frame.size.width, mealImageView.frame.size.height);
        [overviewContainer addSubview:mealImageView];
        
        _mealLabel = [[UILabel alloc] initWithFrame:CGRectMake(253.0f, 9.0f, 100.0f, 16.0f)];
        _mealLabel.backgroundColor = [UIColor clearColor];
        _mealLabel.text = [NSString stringWithFormat:@"0 %@", [NSLocalizedString(@"Carbs", nil) lowercaseString]];
        _mealLabel.font = [UAFont standardMediumFontWithSize:11.0f];
        _mealLabel.textColor = [UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        [overviewContainer addSubview:_mealLabel];
    }
    
    return self;
}

#pragma mark - Logic
- (void)setDate:(NSString *)text
{
    _dateLabel.text = text;
}

@end
