//
//  UAReportPreviewView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/05/2013.
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

#import <QuartzCore/QuartzCore.h>
#import "UAReportPreviewView.h"

@interface UAReportPreviewView ()
{
    NSDictionary *info;
    
    UILabel *titleLabel;
    UILabel *descriptionLabel;
}

@end

@implementation UAReportPreviewView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame andInfo:(NSDictionary *)theInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        info = theInfo;
        
        [self setBackgroundImage:[UIImage imageNamed:@"ReportModalButton.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"ReportModalButtonPressed.png"] forState:UIControlStateHighlighted];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 20.0f)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.text = [info valueForKey:@"title"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UAFont standardDemiBoldFontWithSize:16.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor colorWithRed:102.0f/255.0f green:112.0f/255.0f blue:109.0f/255.0f alpha:1.0f];
        [self addSubview:titleLabel];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 45.0f, self.frame.size.width, 0.0f)];
        descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        descriptionLabel.text = [info valueForKey:@"description"];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.font = [UAFont standardMediumFontWithSize:14.0f];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.textColor = [UIColor colorWithRed:156.0f/255.0f green:166.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
        [self addSubview:descriptionLabel];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = [[info valueForKey:@"description"] sizeWithFont:[UAFont standardRegularFontWithSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width-60.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    descriptionLabel.frame = CGRectMake(30.0f, self.frame.size.height/2.0f - height/2.0f + 20.0f, self.frame.size.width-60.0f, height);
    titleLabel.frame = CGRectMake(0.0f, 15.0f, self.frame.size.width, 20.0f);
}

@end
