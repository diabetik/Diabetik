//
//  UAReportPreviewView.m
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
        
        [self setAdjustsImageWhenHighlighted:NO];
        [self setBackgroundImage:[UIImage imageNamed:@"ReportsCardBackground"] forState:UIControlStateNormal];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.text = [info valueForKey:@"title"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UAFont standardMediumFontWithSize:16.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor colorWithRed:77.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1.0f];
        [self addSubview:titleLabel];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 45.0f, self.frame.size.width, 0.0f)];
        descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        descriptionLabel.text = [info valueForKey:@"description"];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        [self addSubview:descriptionLabel];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleHeight = ceilf([[info valueForKey:@"title"] sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(self.frame.size.width-60.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    CGFloat descriptionHeight = ceilf([[info valueForKey:@"description"] sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(self.frame.size.width-60.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    
    CGFloat y = ceilf(self.bounds.size.height/2.0f - (titleHeight + descriptionHeight + 10.0f)/2.0f);
    
    titleLabel.frame = CGRectMake(0.0f, y, self.frame.size.width, 20.0f);
    descriptionLabel.frame = CGRectMake(30.0f, y + titleHeight + 10.0f, self.frame.size.width-60.0f, descriptionHeight);
}

@end
