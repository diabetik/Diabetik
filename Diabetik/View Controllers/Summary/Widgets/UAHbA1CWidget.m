//
//  UAHbA1CWidget.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/04/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
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

#import "UAHbA1CWidget.h"

@interface UAHbA1CWidget ()
@property (nonatomic, assign) NSInteger numberOfDays;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, strong) UILabel *settingDaysLabel;
@property (nonatomic, strong) UISlider *settingDaysSlider;
@end

@implementation UAHbA1CWidget

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        self.numberOfDays = 90;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text = NSLocalizedString(@"HbA1C estimate", nil);
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UAFont standardRegularFontWithSize:22.0f];
        self.titleLabel.hidden = YES;
        [self.widgetContentView addSubview:self.titleLabel];
        
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subtitleLabel.text = @"-";
        self.subtitleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.font = [UAFont standardItalicFontWithSize:14.0f];
        self.subtitleLabel.hidden = NO;
        [self.widgetContentView addSubview:self.subtitleLabel];
        
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.text = @"-";
        self.valueLabel.textColor = [UIColor whiteColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.font = [UAFont standardUltraLightFontWithSize:50.0f];
        self.valueLabel.hidden = NO;
        [self.widgetContentView addSubview:self.valueLabel];
        
        // Settings
        self.settingDaysSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        self.settingDaysSlider.minimumValue = 7;
        self.settingDaysSlider.maximumValue = 150;
        self.settingDaysSlider.value = self.numberOfDays;
        [self.widgetSettingsView insertSubview:self.settingDaysSlider belowSubview:self.widgetSettingsCloseButton];
        [self.settingDaysSlider addTarget:self action:@selector(updateNumberOfDaysValue:) forControlEvents:UIControlEventValueChanged];

        self.settingDaysLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.settingDaysLabel.textColor = [UIColor whiteColor];
        self.settingDaysLabel.textAlignment = NSTextAlignmentCenter;
        self.settingDaysLabel.font = [UAFont standardUltraLightFontWithSize:50.0f];
        self.settingDaysLabel.hidden = NO;
        [self.widgetSettingsView insertSubview:self.settingDaysLabel belowSubview:self.widgetSettingsCloseButton];
        [self updateNumberOfDaysLabel];;
    }
    
    return self;
}
- (id)initFromSerializedRepresentation:(NSDictionary *)representation
{
    self = [super initFromSerializedRepresentation:representation];
    if(self)
    {
        self.numberOfDays = [representation[@"settings"][@"days"] integerValue];
        
        self.settingDaysSlider.value = self.numberOfDays;
        [self updateNumberOfDaysLabel];
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0.0f, 20.0f, self.widgetContentView.bounds.size.width, 24.0f);
    self.subtitleLabel.frame = CGRectMake(0.0f, 44.0f, self.widgetContentView.bounds.size.width, 16.0f);
    self.valueLabel.frame = CGRectMake(0.0f, 70.0f, self.widgetContentView.bounds.size.width, 50.0f);
    
    self.settingDaysLabel.frame = CGRectInset(self.widgetSettingsView.bounds, 10.0f, 1.0f);
    self.settingDaysSlider.frame = CGRectMake(10.0f, self.widgetSettingsView.bounds.size.height-40.0f, self.widgetSettingsView.bounds.size.width-20.0f, 40.0f);
}

#pragma mark - Logic
- (void)updateNumberOfDaysLabel
{
    self.settingDaysLabel.text = [NSString stringWithFormat:@"%d", self.numberOfDays];
}
- (void)updateNumberOfDaysValue:(UISlider *)sender
{
    self.numberOfDays = (NSInteger)sender.value;
    [self updateNumberOfDaysLabel];
}
- (void)update
{
    [super update];
    
    NSDate *date = [[NSDate date] dateBySubtractingDays:self.numberOfDays];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType = %@ AND timestamp >= %@", @(ReadingFilterType), date];
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] newPrivateContext];
    if(moc)
    {
        __weak typeof(self) weakSelf = self;
        [moc performBlockAndWait:^{
            NSArray *readings = [[UAEventController sharedInstance] fetchEventsWithPredicate:predicate
                                                                             sortDescriptors:nil
                                                                                   inContext:moc];
            
            NSMutableArray *hourBreakdown = [NSMutableArray array];
            for(NSInteger i = 0; i < 24; i++)
            {
                [hourBreakdown addObject:@{@"total": @0, @"count": @0}];
            }
            
            if(readings)
            {
                double totalOfValues = 0;
                for(UAReading *reading in readings)
                {
                    NSInteger hour = [[reading timestamp] hour];
                    NSNumber *value = [reading mgValue];
                    totalOfValues += [value doubleValue];
                    
                    if(hourBreakdown[hour])
                    {
                        NSNumber *totalValue = [NSNumber numberWithDouble:[hourBreakdown[hour][@"total"] doubleValue] + [value doubleValue]];
                        NSNumber *count = [NSNumber numberWithInteger:[hourBreakdown[hour][@"count"] integerValue]+1];
                        hourBreakdown[hour] = @{@"total": totalValue, @"count": count};
                    }
                    
                    [moc refreshObject:reading mergeChanges:YES];
                }
                
                // Calculate HbA1C
                double avgReading = totalOfValues/[readings count];
                double b = avgReading+46.7;
                double c = 28.7;
                double d = b/c*100;
                double a1c = floor(d)/100;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                    NSNumber *avgBG = [UAHelper convertBGValue:@(avgReading) fromUnit:BGTrackingUnitMG toUnit:[UAHelper userBGUnit]];
                    NSString *avgBGString = [[UAHelper glucoseNumberFormatter] stringFromNumber:avgBG];
                    [strongSelf.subtitleLabel setText:[NSString stringWithFormat:@"with an avg. BG of %@ over %ld days", avgBGString, (long)strongSelf.numberOfDays]];
                    [strongSelf.valueLabel setText:[NSString stringWithFormat:@"%0.2f%%", a1c]];
                    
                    [strongSelf.titleLabel setHidden:NO];
                    [strongSelf.subtitleLabel setHidden:NO];
                    [strongSelf.valueLabel setHidden:NO];
                    [strongSelf.activityIndicatorView stopAnimating];
                });
            }
        }];
    }
}
- (NSDictionary *)serializedRepresentation
{
    return @{@"class": NSStringFromClass([self class]), @"settings": @{@"days": @(self.numberOfDays)}};
}
- (CGFloat)height
{
    return 140.0f;
}

@end
