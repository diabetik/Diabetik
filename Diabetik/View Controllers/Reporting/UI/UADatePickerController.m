//
//  UADatePickerController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/05/2013.
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
#import "UADatePickerController.h"

@interface UADatePickerController ()
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *backingView;

- (void)selectDate;
- (void)didChangeDate:(UIDatePicker *)sender;
@end

@implementation UADatePickerController
@synthesize pickerView = _pickerView;
@synthesize containerView = _containerView;
@synthesize backingView = _backingView;
@synthesize datePicker = _datePicker;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame andDate:(NSDate *)date
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _backingView = [[UIView alloc] initWithFrame:frame];
        _backingView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.55];
        _backingView.alpha = 0.0f;
        [self addSubview:_backingView];
        
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = [UIColor whiteColor];
        [_datePicker setClipsToBounds:YES];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_datePicker setDate:date];
        [_datePicker setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_datePicker addTarget:self action:@selector(didChangeDate:) forControlEvents:UIControlEventValueChanged];
        
        _pickerView = [[UIView alloc] initWithFrame:frame];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_pickerView];
        
        CGRect pickerFrame = CGRectMake(floorf(self.bounds.size.width/2.0f - 338.0f/2.0f), floorf(self.bounds.size.height/2.0f - 247.0f/2.0f), 338.0f, 247.0f);
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(pickerFrame.origin.x, pickerFrame.origin.y, 338.0f, 247.0f)];
        self.containerView.clipsToBounds = YES;
        self.containerView.layer.masksToBounds = YES;
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.cornerRadius = 5;
        [_containerView addSubview:_datePicker];
        [_pickerView addSubview:_containerView];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(floorf(pickerFrame.origin.x + 17.0f), floorf(pickerFrame.origin.y + pickerFrame.size.height - (41.0f + 19.0f)), 150.0f, 41.0f)];
        [[cancelButton titleLabel] setFont:[UAFont standardMediumFontWithSize:19.0f]];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [cancelButton setAdjustsImageWhenHighlighted:NO];
        [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setBackgroundColor:[UIColor whiteColor]];
        [self.pickerView addSubview:cancelButton];
        
        UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(floorf(pickerFrame.origin.x + pickerFrame.size.width - 150.0f - 17.0f), floorf(pickerFrame.origin.y + pickerFrame.size.height - (41.0f + 19.0f)), 150.0f, 41.0f)];
        [[doneButton titleLabel] setFont:[UAFont standardMediumFontWithSize:19.0f]];
        [doneButton setTitleColor:[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(selectDate) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setBackgroundColor:[UIColor whiteColor]];
        [self.pickerView addSubview:doneButton];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.datePicker.frame = CGRectMake(self.containerView.bounds.size.width/2-(self.datePicker.frame.size.width/2), 17.0f, self.datePicker.frame.size.width, self.datePicker.frame.size.height+1);
}

#pragma mark - Logic
- (void)selectDate
{
    [self.delegate datePicker:self didSelectDate:self.datePicker.date];
    [self dismiss];
}
- (void)present
{
    self.pickerView.frame = CGRectMake(self.pickerView.frame.origin.x, -self.pickerView.bounds.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.backingView.alpha = 1.0f;
        self.pickerView.frame = CGRectMake(self.pickerView.frame.origin.x, self.bounds.size.height/2.0f - self.pickerView.bounds.size.height/2.0f, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
- (void)dismiss
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"pop-view"];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backingView.alpha = 0.0f;
        self.pickerView.frame = CGRectMake(self.pickerView.frame.origin.x, -self.pickerView.bounds.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)didChangeDate:(UIDatePicker *)sender
{
    // STUB
}

@end
