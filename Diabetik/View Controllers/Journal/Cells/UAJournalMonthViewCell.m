//
//  UAJournalMonthViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/12/2012.
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
    UILabel *glucoseDetailLabel;
    UILabel *activityDetailLabel;
    UILabel *mealDetailLabel;
    UILabel *deviationDetailLabel;
    UILabel *lowGlucoseDetailLabel;
    UILabel *highGlucoseDetailLabel;
    
    UIView *cellBottomBorder;
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
        UIView *cellTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.5f)];
        cellTopBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cellTopBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:cellTopBorder];
        
        cellBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height-0.5f, self.frame.size.width, 0.5f)];
        cellBottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cellBottomBorder.backgroundColor = [UIColor colorWithRed:204.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:cellBottomBorder];
        
        // Header/month label
        _monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 1.0f, self.frame.size.width-40.0f, 44.0f)];
        _monthLabel.backgroundColor = [UIColor whiteColor];
        _monthLabel.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        _monthLabel.font = [UAFont standardRegularFontWithSize:21.0f];
        _monthLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_monthLabel];
        
        UIView *monthBorder = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 44.0f, self.frame.size.width-20.0f, 0.5f)];
        monthBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        monthBorder.backgroundColor = [UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:monthBorder];
        
        UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconChevron"]];
        chevron.frame = CGRectMake(self.bounds.size.width - 30.0f, 12.0f, 13.0f, 20.0f);
        chevron.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:chevron];
        
        CGFloat y = 46.0f;
        
        // Glucose
        glucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBlood.png"]];
        glucoseImageView.frame = CGRectMake(20.0f, y + 10.0f, glucoseImageView.frame.size.width, glucoseImageView.frame.size.height);
        [self.contentView addSubview:glucoseImageView];
        
        glucoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
        glucoseLabel.backgroundColor = [UIColor whiteColor];
        glucoseLabel.text = @"0.0";
        glucoseLabel.font = [UAFont standardRegularFontWithSize:18.0f];
        glucoseLabel.textAlignment = NSTextAlignmentLeft;
        glucoseLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        glucoseLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:glucoseLabel];
        
        glucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
        glucoseDetailLabel.backgroundColor = [UIColor whiteColor];
        glucoseDetailLabel.text = [NSLocalizedString(@"Avg. Blood Glucose", @"Label for average blood glucose reading") uppercaseString];
        glucoseDetailLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        glucoseDetailLabel.textAlignment = NSTextAlignmentLeft;
        glucoseDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        glucoseDetailLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:glucoseDetailLabel];
        
        highGlucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodHigh"]];
        highGlucoseImageView.frame = CGRectMake(self.bounds.size.width - 87.0f, 53.0f, 15.0f, 15.0f);
        [self.contentView addSubview:highGlucoseImageView];
        
        highGlucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 67.0f, 53.0f, 67.0f, 16.0f)];
        highGlucoseDetailLabel.backgroundColor = [UIColor whiteColor];
        highGlucoseDetailLabel.text = @"0";
        highGlucoseDetailLabel.font = [UAFont standardRegularFontWithSize:13.0f];
        highGlucoseDetailLabel.textAlignment = NSTextAlignmentLeft;
        highGlucoseDetailLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        highGlucoseDetailLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:highGlucoseDetailLabel];
        
        lowGlucoseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconBloodLow"]];
        lowGlucoseImageView.frame = CGRectMake(self.bounds.size.width - 87.0f, 75.0f, 15.0f, 15.0f);
        [self.contentView addSubview:lowGlucoseImageView];
        
        lowGlucoseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 67.0f, 75.0f, 67.0f, 16.0f)];
        lowGlucoseDetailLabel.backgroundColor = [UIColor whiteColor];
        lowGlucoseDetailLabel.text = @"0";
        lowGlucoseDetailLabel.font = [UAFont standardRegularFontWithSize:13.0f];
        lowGlucoseDetailLabel.textAlignment = NSTextAlignmentLeft;
        lowGlucoseDetailLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        lowGlucoseDetailLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:lowGlucoseDetailLabel];
        
        UIView *horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        
        y += 56.0f;
        
        // Activity
        activityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconActivity.png"]];
        activityImageView.frame = CGRectMake(20.0f, y + 10.0f, activityImageView.frame.size.width, activityImageView.frame.size.height);
        [self.contentView addSubview:activityImageView];
        
        activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
        activityLabel.backgroundColor = [UIColor whiteColor];
        activityLabel.text = @"0";
        activityLabel.font = [UAFont standardRegularFontWithSize:18.0f];
        activityLabel.textAlignment = NSTextAlignmentLeft;
        activityLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        activityLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:activityLabel];
        
        activityDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
        activityDetailLabel.backgroundColor = [UIColor whiteColor];
        activityDetailLabel.text = [NSLocalizedString(@"Activity", @"Activity (physical exercise)") uppercaseString];
        activityDetailLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        activityDetailLabel.textAlignment = NSTextAlignmentLeft;
        activityDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        activityDetailLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:activityDetailLabel];
        
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        
        y += 56.0f;
        
        // Meal
        mealImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconCarbs.png"]];
        mealImageView.frame = CGRectMake(20.0f, y + 10.0f, mealImageView.frame.size.width, mealImageView.frame.size.height);
        [self.contentView addSubview:mealImageView];
        
        mealLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
        mealLabel.backgroundColor = [UIColor whiteColor];
        mealLabel.text = @"0";
        mealLabel.font = [UAFont standardRegularFontWithSize:18.0f];
        mealLabel.textAlignment = NSTextAlignmentLeft;
        mealLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        mealLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:mealLabel];
        
        mealDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
        mealDetailLabel.backgroundColor = [UIColor whiteColor];
        mealDetailLabel.text = [NSLocalizedString(@"Grams", @"Unit of measurement") uppercaseString];
        mealDetailLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        mealDetailLabel.textAlignment = NSTextAlignmentLeft;
        mealDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        mealDetailLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:mealDetailLabel];
        
        horizontalBorder = [[UIView alloc] initWithFrame:CGRectMake(72.0f, y + 52.0f, self.frame.size.width-72.0f, 0.5f)];
        horizontalBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        horizontalBorder.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15];
        [self.contentView addSubview:horizontalBorder];
        
        y += 56.0f;
        
        // Deviation
        deviationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JournalIconDeviation.png"]];
        deviationImageView.frame = CGRectMake(20.0f, y + 10.0f, deviationImageView.frame.size.width, deviationImageView.frame.size.height);
        [self.contentView addSubview:deviationImageView];
        
        deviationLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 9.0f, 100.0f, 16.0f)];
        deviationLabel.backgroundColor = [UIColor whiteColor];
        deviationLabel.text = @"0.0";
        deviationLabel.font = [UAFont standardRegularFontWithSize:18.0f];
        deviationLabel.textAlignment = NSTextAlignmentLeft;
        deviationLabel.textColor = [UIColor colorWithRed:134.0f/255.0f green:143.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        deviationLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:deviationLabel];
        
        deviationDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0f, y + 29.0f, self.bounds.size.width-72.0f, 16.0f)];
        deviationDetailLabel.backgroundColor = [UIColor whiteColor];
        deviationDetailLabel.text = [NSLocalizedString(@"Blood Glucose Deviation", @"Label for the statistical deviation in blood glucose values") uppercaseString];
        deviationDetailLabel.font = [UAFont standardMediumFontWithSize:12.0f];
        deviationDetailLabel.textAlignment = NSTextAlignmentLeft;
        deviationDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        deviationDetailLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:deviationDetailLabel];
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    cellBottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-0.5f, self.frame.size.width, 0.5f);
}

#pragma mark - Accessors
- (void)setDeviationValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if([value doubleValue] > 0)
    {
        deviationImageView.image = [UIImage imageNamed:@"JournalIconDeviation"];
        deviationLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        deviationLabel.text = [valueFormatter stringFromNumber:value];
        deviationDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    }
    else
    {
        deviationImageView.image = [UIImage imageNamed:@"JournalIconDeviationInactive"];
        deviationLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        deviationLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        deviationLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        deviationDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}
- (void)setAverageGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if([value doubleValue] > 0)
    {
        glucoseImageView.image = [UIImage imageNamed:@"JournalIconBlood"];
        glucoseLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:79.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
        glucoseLabel.text = [valueFormatter stringFromNumber:value];
        glucoseDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    }
    else
    {
        glucoseImageView.image = [UIImage imageNamed:@"JournalIconBloodInactive"];
        glucoseLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        glucoseLabel.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
        glucoseLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        glucoseDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}
- (void)setLowGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if([value doubleValue] > 0)
    {
        lowGlucoseDetailLabel.text = [valueFormatter stringFromNumber:value];
        lowGlucoseDetailLabel.hidden = NO;
        lowGlucoseImageView.hidden = NO;
    }
    else
    {
        lowGlucoseDetailLabel.hidden = YES;
        lowGlucoseImageView.hidden = YES;
    }
}
- (void)setHighGlucoseValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if([value doubleValue] > 0)
    {
        highGlucoseDetailLabel.text = [valueFormatter stringFromNumber:value];
        highGlucoseDetailLabel.hidden = NO;
        highGlucoseImageView.hidden = NO;
    }
    else
    {
        highGlucoseDetailLabel.hidden = YES;
        highGlucoseImageView.hidden = YES;
    }
}
- (void)setActivityValue:(NSInteger)value
{
    if(value > 0)
    {
        activityImageView.image = [UIImage imageNamed:@"JournalIconActivity"];
        activityLabel.textColor = [UIColor colorWithRed:113.0f/255.0f green:185.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        activityDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        activityLabel.text = [UAHelper formatMinutes:value];
    }
    else
    {
        activityImageView.image = [UIImage imageNamed:@"JournalIconActivityInactive"];
        activityLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        activityLabel.text = @"00:00";
        activityLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        activityDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    }
}
- (void)setMealValue:(NSNumber *)value withFormatter:(NSNumberFormatter *)valueFormatter
{
    if([value doubleValue] > 0)
    {
        mealImageView.image = [UIImage imageNamed:@"JournalIconCarbs"];
        mealLabel.textColor = [UIColor colorWithRed:254.0f/255.0f green:196.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
        mealDetailLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:163.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
        mealLabel.text = [valueFormatter stringFromNumber:value];
    }
    else
    {
        mealImageView.image = [UIImage imageNamed:@"JournalIconCarbsInactive"];
        mealLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        mealDetailLabel.textColor = [UIColor colorWithRed:223.0f/255.0f green:225.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
        mealLabel.text = @"0";
    }
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    mealImageView.tintColor = [UIColor redColor];
}
@end
