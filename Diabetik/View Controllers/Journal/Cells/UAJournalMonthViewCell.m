//
//  UAJournalMonthViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/12/2012.
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

#import "UAJournalMonthViewCell.h"

@interface UAJournalMonthViewCell ()
{
    UIImageView *deviationImageView;
    UIImageView *mealImageView;
    UIImageView *activityImageView;
    UIImageView *glucoseImageView;
    UIImageView *lowGlucoseImageView;
    UIImageView *highGlucoseImageView;
    
    UILabel *glucoseLabel;
    UILabel *activityLabel;
    UILabel *mealLabel;
    UILabel *deviationLabel;
    UILabel *lowGlucoseLabel;
    UILabel *highGlucoseLabel;
    UILabel *glucoseDetailLabel;
    UILabel *activityDetailLabel;
    UILabel *mealDetailLabel;
    UILabel *deviationDetailLabel;
    UILabel *lowGlucoseDetailLabel;
    UILabel *highGlucoseDetailLabel;
}
@end

@implementation UAJournalMonthViewCell
@synthesize monthLabel = _monthLabel;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 196.0f)];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        background.backgroundColor = [UIColor clearColor];
        background.image = [UIImage imageNamed:@"JournalCardBackground.png"];
        [view addSubview:background];
        self.backgroundView = view;
        
        view = [[UIView alloc] initWithFrame:self.bounds];
        UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 196.0f)];
        selectedBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        selectedBackground.backgroundColor = [UIColor clearColor];
        selectedBackground.image = [UIImage imageNamed:@"JournalCardBackgroundPressed.png"];
        [view addSubview:selectedBackground];
        self.selectedBackgroundView = view;
        
        CGFloat y = 60.0f;
        
        // Month label
        _monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 15.0f, self.frame.size.width, 18.0f)];
        _monthLabel.backgroundColor = [UIColor clearColor];
        _monthLabel.textColor = [UIColor colorWithRed:128.0f/255.0f green:127.0f/255.0f blue:127.0f/255.0f alpha:1.0];
        _monthLabel.font = [UAFont standardDemiBoldFontWithSize:16.0f];
        _monthLabel.shadowColor = [UIColor whiteColor];
        _monthLabel.shadowOffset = CGSizeMake(0, 1);
        _monthLabel.highlightedTextColor = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:_monthLabel];
        
        // Glucose
        glucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconAverageBloodInactive.png"]];
        glucoseImageView.frame = CGRectMake((50 - glucoseImageView.frame.size.width/2), y, glucoseImageView.frame.size.width, glucoseImageView.frame.size.height);
        [self.contentView addSubview:glucoseImageView];
        
        glucoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y + 18.0f, 100.0f, 16.0f)];
        glucoseLabel.backgroundColor = [UIColor clearColor];
        glucoseLabel.text = @"0.0";
        glucoseLabel.font = [UAFont standardMediumFontWithSize:13.0f];
        glucoseLabel.textAlignment = NSTextAlignmentCenter;
        glucoseLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:glucoseLabel];
        
        glucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y + 32.0f, 100.0f, 16.0f)];
        glucoseDetailLabel.backgroundColor = [UIColor clearColor];
        glucoseDetailLabel.text = NSLocalizedString(@"AVERAGE", @"Label for average blood glucose reading");
        glucoseDetailLabel.font = [UAFont standardDemiBoldFontWithSize:11.0f];
        glucoseDetailLabel.textAlignment = NSTextAlignmentCenter;
        glucoseDetailLabel.textColor = [UIColor colorWithRed:167.0f/255.0f green:179.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:glucoseDetailLabel];
        
        // Activity
        activityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconActivityInactive.png"]];
        activityImageView.frame = CGRectMake(101.0f + (50 - activityImageView.frame.size.width/2), y, activityImageView.frame.size.width, activityImageView.frame.size.height);
        [self.contentView addSubview:activityImageView];
        
        activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, y + 18.0f, 100.0f, 16.0f)];
        activityLabel.backgroundColor = [UIColor clearColor];
        activityLabel.text = @"0";
        activityLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        activityLabel.textAlignment = NSTextAlignmentCenter;
        activityLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:activityLabel];
        
        activityDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(101.0f, y + 32.0f, 100.0f, 16.0f)];
        activityDetailLabel.backgroundColor = [UIColor clearColor];
        activityDetailLabel.text = NSLocalizedString(@"ACTIVITY", @"Label for total amount of activity (physical exercise)");
        activityDetailLabel.font = [UAFont standardDemiBoldFontWithSize:11.0f];
        activityDetailLabel.textAlignment = NSTextAlignmentCenter;
        activityDetailLabel.textColor = [UIColor colorWithRed:167.0f/255.0f green:179.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:activityDetailLabel];
        
        // Meal
        mealImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconFoodInactive.png"]];
        mealImageView.frame = CGRectMake(201.0f + (50 - mealImageView.frame.size.width/2), y, mealImageView.frame.size.width, mealImageView.frame.size.height);
        [self.contentView addSubview:mealImageView];
        
        mealLabel = [[UILabel alloc] initWithFrame:CGRectMake(201.0f, y + 18.0f, 100.0f, 16.0f)];
        mealLabel.backgroundColor = [UIColor clearColor];
        mealLabel.text = @"0";
        mealLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        mealLabel.textAlignment = NSTextAlignmentCenter;
        mealLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:mealLabel];
        
        mealDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(201.0f, y + 32.0f, 100.0f, 16.0f)];
        mealDetailLabel.backgroundColor = [UIColor clearColor];
        mealDetailLabel.text = NSLocalizedString(@"GRAMS", @"Label for the amount of grams of carbohydrate eaten");
        mealDetailLabel.font = [UAFont standardDemiBoldFontWithSize:11.0f];
        mealDetailLabel.textAlignment = NSTextAlignmentCenter;
        mealDetailLabel.textColor = [UIColor colorWithRed:167.0f/255.0f green:179.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:mealDetailLabel];
        
        y += 72.0f;
        
        // Deviation
        deviationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconDeviationInactive.png"]];
        deviationImageView.frame = CGRectMake((50 - deviationImageView.frame.size.width/2), y, deviationImageView.frame.size.width, deviationImageView.frame.size.height);
        [self.contentView addSubview:deviationImageView];
        
        deviationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y + 18.0f, 100.0f, 16.0f)];
        deviationLabel.backgroundColor = [UIColor clearColor];
        deviationLabel.text = @"0.0";
        deviationLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        deviationLabel.textAlignment = NSTextAlignmentCenter;
        deviationLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:deviationLabel];
        
        deviationDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y + 32.0f, 100.0f, 16.0f)];
        deviationDetailLabel.backgroundColor = [UIColor clearColor];
        deviationDetailLabel.text = NSLocalizedString(@"DEVIATION", @"Label for the statistical deviation in blood glucose values");
        deviationDetailLabel.font = [UAFont standardDemiBoldFontWithSize:11.0f];
        deviationDetailLabel.textAlignment = NSTextAlignmentCenter;
        deviationDetailLabel.textColor = [UIColor colorWithRed:167.0f/255.0f green:179.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:deviationDetailLabel];
        
        // Low Glucose
        lowGlucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconLowestBloodInactive.png"]];
        lowGlucoseImageView.frame = CGRectMake(101.0f + (50 - lowGlucoseImageView.frame.size.width/2), y, lowGlucoseImageView.frame.size.width, lowGlucoseImageView.frame.size.height);
        [self.contentView addSubview:lowGlucoseImageView];
        
        lowGlucoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(101.0f, y + 18.0f, 100.0f, 16.0f)];
        lowGlucoseLabel.backgroundColor = [UIColor clearColor];
        lowGlucoseLabel.text = @"0";
        lowGlucoseLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        lowGlucoseLabel.textAlignment = NSTextAlignmentCenter;
        lowGlucoseLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:lowGlucoseLabel];
        
        lowGlucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(101.0f, y + 32.0f, 100.0f, 16.0f)];
        lowGlucoseDetailLabel.backgroundColor = [UIColor clearColor];
        lowGlucoseDetailLabel.text = NSLocalizedString(@"LOWEST", @"Label for the lowest blood glucose reading in a given month");
        lowGlucoseDetailLabel.font = [UAFont standardDemiBoldFontWithSize:11.0f];
        lowGlucoseDetailLabel.textAlignment = NSTextAlignmentCenter;
        lowGlucoseDetailLabel.textColor = [UIColor colorWithRed:167.0f/255.0f green:179.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:lowGlucoseDetailLabel];
        
        // High Glucose
        highGlucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconHighestBloodInactive.png"]];
        highGlucoseImageView.frame = CGRectMake(201.0f + (50 - highGlucoseImageView.frame.size.width/2), y, highGlucoseImageView.frame.size.width, highGlucoseImageView.frame.size.height);
        [self.contentView addSubview:highGlucoseImageView];
        
        highGlucoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(201.0f, y + 18.0f, 100.0f, 16.0f)];
        highGlucoseLabel.backgroundColor = [UIColor clearColor];
        highGlucoseLabel.text = @"0";
        highGlucoseLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        highGlucoseLabel.textAlignment = NSTextAlignmentCenter;
        highGlucoseLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:highGlucoseLabel];
        
        highGlucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(201.0f, y + 32.0f, 100.0f, 16.0f)];
        highGlucoseDetailLabel.backgroundColor = [UIColor clearColor];
        highGlucoseDetailLabel.text = NSLocalizedString(@"HIGHEST", @"Label for highest blood glucose reading in a given month");
        highGlucoseDetailLabel.font = [UAFont standardDemiBoldFontWithSize:11.0f];
        highGlucoseDetailLabel.textAlignment = NSTextAlignmentCenter;
        highGlucoseDetailLabel.textColor = [UIColor colorWithRed:167.0f/255.0f green:179.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:highGlucoseDetailLabel];
    }
    
    return self;
}

#pragma mark - Accessors
- (void)setDeviationValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if(value > 0)
    {
        deviationImageView.image = [UIImage imageNamed:@"JournalIconDeviation.png"];
        deviationLabel.text = [valueFormatter stringFromNumber:value];
        deviationLabel.alpha = 1.0f;
        deviationDetailLabel.alpha = 1.0f;
    }
    else
    {
        deviationImageView.image = [UIImage imageNamed:@"JournalIconDeviationInactive.png"];
        deviationLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        deviationLabel.alpha = 0.5f;
        deviationDetailLabel.alpha = 0.5f;
    }
}
- (void)setAverageGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if(value > 0)
    {
        glucoseImageView.image = [UIImage imageNamed:@"JournalIconAverageBlood.png"];
        glucoseLabel.text = [valueFormatter stringFromNumber:value];
        glucoseLabel.alpha = 1.0f;
        glucoseDetailLabel.alpha = 1.0f;
    }
    else
    {
        glucoseLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        glucoseImageView.image = [UIImage imageNamed:@"JournalIconAverageBloodInactive.png"];
        glucoseLabel.alpha = 0.5f;
        glucoseDetailLabel.alpha = 0.5f;        
    }
}
- (void)setLowGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if(value > 0)
    {
        lowGlucoseImageView.image = [UIImage imageNamed:@"JournalIconLowestBlood.png"];
        lowGlucoseLabel.text = [valueFormatter stringFromNumber:value];
        lowGlucoseLabel.alpha = 1.0f;
        lowGlucoseDetailLabel.alpha = 1.0f;
    }
    else
    {
        lowGlucoseImageView.image = [UIImage imageNamed:@"JournalIconLowestBloodInactive.png"];
        lowGlucoseLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        lowGlucoseLabel.alpha = 0.5f;
        lowGlucoseDetailLabel.alpha = 0.5f;        
    }
}
- (void)setHighGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if(value > 0)
    {
        highGlucoseImageView.image = [UIImage imageNamed:@"JournalIconHighestBlood.png"];
        highGlucoseLabel.text = [valueFormatter stringFromNumber:value];
        highGlucoseLabel.alpha = 1.0f;
        highGlucoseDetailLabel.alpha = 1.0f;
    }
    else
    {
        highGlucoseImageView.image = [UIImage imageNamed:@"JournalIconHighestBloodInactive.png"];
        highGlucoseLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        highGlucoseLabel.alpha = 0.5f;
        highGlucoseDetailLabel.alpha = 0.5f;        
    }
}
- (void)setActivityValue:(NSInteger)value
{
    if(value > 0)
    {
        activityImageView.image = [UIImage imageNamed:@"JournalIconActivity.png"];
        activityLabel.text = [UAHelper formatMinutes:value];
        activityLabel.alpha = 1.0f;
        activityDetailLabel.alpha = 1.0f;
    }
    else
    {
        activityImageView.image = [UIImage imageNamed:@"JournalIconActivityInactive.png"];        
        activityLabel.text = @"00:00";
        activityLabel.alpha = 0.5f;
        activityDetailLabel.alpha = 0.5f;
    }
}
- (void)setMealValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if(value > 0)
    {
        mealImageView.image = [UIImage imageNamed:@"JournalIconFood.png"];
        mealLabel.text = [valueFormatter stringFromNumber:value];
        mealLabel.alpha = 1.0f;
        mealDetailLabel.alpha = 1.0f;        
    }
    else
    {
        mealImageView.image = [UIImage imageNamed:@"JournalIconFoodInactive.png"];        
        mealLabel.text = @"0";
        mealLabel.alpha = 0.5f;
        mealDetailLabel.alpha = 0.5f;
    }
}

@end
