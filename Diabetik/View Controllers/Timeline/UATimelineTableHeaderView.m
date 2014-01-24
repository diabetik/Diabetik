//
//  UATimelineTableHeaderView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 23/01/2013.
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

#import "UATimelineTableHeaderView.h"

@implementation UATimelineTableHeaderView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)aTitle
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UAFont standardDemiBoldFontWithSize:12.0f];
        label.text = [aTitle uppercaseString];
        label.textColor = [UIColor colorWithRed:154.0f/255.0f green:152.0f/255.0f blue:147.0f/255.0f alpha:1.0f];
        label.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        
        self.clipsToBounds = NO;
    }
    
    return self;
}

#pragma mark - Rendering
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIImage *bg = [UIImage imageNamed:@"GeneralSectionHeader.png"];
    [bg drawInRect:self.frame];
}

@end