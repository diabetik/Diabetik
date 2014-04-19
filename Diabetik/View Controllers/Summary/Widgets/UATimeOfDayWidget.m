//
//  UATimeOfDayWidget.m
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

#import "UATimeOfDayWidget.h"

@interface UATimeOfDayWidget ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation UATimeOfDayWidget

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text = NSLocalizedString(@"Morning", nil);
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UAFont standardRegularFontWithSize:22.0f];
        self.titleLabel.hidden = YES;
        [self.widgetContentView addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.text = NSLocalizedString(@"9AM - 12AM", nil);
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        self.timeLabel.hidden = YES;
        [self.widgetContentView addSubview:self.timeLabel];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0.0f, 20.0f, self.widgetContentView.bounds.size.width, 24.0f);
    self.timeLabel.frame = CGRectMake(0.0f, 44.0f, self.widgetContentView.bounds.size.width, 16.0f);
}

#pragma mark - Logic
- (void)update
{
    [super update];
    
    [self.titleLabel setHidden:NO];
    [self.timeLabel setHidden:NO];
    [self.activityIndicatorView stopAnimating];
}
- (CGFloat)height
{
    return 60.0f;
}

@end
