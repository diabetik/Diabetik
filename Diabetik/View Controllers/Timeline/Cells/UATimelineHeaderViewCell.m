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
        self.backgroundColor = [UIColor clearColor];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40.0f)];
        _dateLabel.font = [UAFont standardDemiBoldFontWithSize:13.0f];
        _dateLabel.shadowOffset = CGSizeMake(0, 1);
        _dateLabel.shadowColor = [UIColor colorWithRed:227.0f/255.0f green:228.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
        _dateLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_dateLabel];
        
        UIImageView *glucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimelineCardHeaderIconBloodGlucose.png"]];
        glucoseImageView.frame = CGRectMake(10.0f + (50 - glucoseImageView.frame.size.width/2), 49.0f, glucoseImageView.frame.size.width, glucoseImageView.frame.size.height);
        [self.contentView addSubview:glucoseImageView];
        
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
    _dateLabel.text = [text uppercaseString];
}

#pragma mark - Rendering
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIImage *background = [UIImage imageNamed:@"TimelineCardHeaderBackground.png"];
    [background drawAtPoint:CGPointMake(self.bounds.size.width/2-background.size.width/2, self.bounds.size.height - background.size.height)];
}

@end
