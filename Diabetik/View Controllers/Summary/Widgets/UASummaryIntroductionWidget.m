//
//  UASummaryIntroductionWidget.m
//  Diabetik
//
//  Created by Nial Giacomelli on 14/04/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UASummaryIntroductionWidget.h"

@implementation UASummaryIntroductionWidget

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.label.text = @"Good Morning";
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UAFont standardRegularFontWithSize:24.0f];
        [self.widgetContentView addSubview:self.label];
    }
    
    return self;
}
@end
