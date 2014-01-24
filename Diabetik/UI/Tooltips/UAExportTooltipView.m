//
//  UAExportTooltipView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 06/04/2013.
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

#import "UAExportTooltipView.h"

@interface UAExportTooltipView ()
{
    UIView *containerView, *border;
    UILabel *header, *content;
}
@end

@implementation UAExportTooltipView

#pragma mark - Logic
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        border = [[UIView alloc] initWithFrame: CGRectZero];
        border.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:237.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
        [containerView addSubview:border];
        
        header = [[UILabel alloc] initWithFrame:CGRectZero];
        header.backgroundColor = [UIColor clearColor];
        header.textColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
        header.numberOfLines = 1;
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UAFont standardBoldFontWithSize:26.0f];
        header.text = NSLocalizedString(@"Export", nil);
        header.adjustsFontSizeToFitWidth = YES;
        header.minimumScaleFactor = 0.5f;
        [containerView addSubview:header];
        
        content = [[UILabel alloc] initWithFrame:CGRectZero];
        content.backgroundColor = [UIColor clearColor];
        content.textColor = [UIColor colorWithRed:115.0f/255.0f green:128.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
        content.numberOfLines = 0;
        content.textAlignment = NSTextAlignmentCenter;
        content.font = [UAFont standardRegularFontWithSize:16.0f];
        content.text = NSLocalizedString(@"Diabetik is capable of exporting your data in CSV or PDF format.\n\nPerfect for importing into other software or for printing to show your health care provider!", nil);
        [containerView addSubview:content];
        [self addSubview:containerView];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentHeight = 200.0f, headerHeight = 30.0f;
    
    border.frame = CGRectMake(floorf(self.frame.size.width/2 - 20), headerHeight+10, 40, 2);
    containerView.frame = CGRectMake(0, floorf(self.frame.size.height/2 - ((contentHeight+headerHeight)/2)), self.frame.size.width, contentHeight+headerHeight);
    header.frame = CGRectMake(floorf(self.frame.size.width/2 - 225/2), 0, 225, headerHeight);
    content.frame = CGRectMake(floorf(self.frame.size.width/2 - 225/2), headerHeight+20, 225, contentHeight);
    
}
@end
