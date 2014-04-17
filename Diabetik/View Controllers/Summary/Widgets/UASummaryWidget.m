//
//  UASummaryWidget.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/02/2014.
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

#import "UASummaryWidget.h"

@implementation UASummaryWidget

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        _showingSettings = NO;
        
        self.backgroundColor = [UIColor yellowColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.widgetSettingsView = [[UIView alloc] initWithFrame:CGRectZero];
        self.widgetSettingsView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.widgetSettingsView];
        
        self.widgetContentView = [[UIView alloc] initWithFrame:CGRectZero];
        self.widgetContentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.widgetContentView];
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.hidesWhenStopped = YES;
        [self.widgetContentView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
    
    return self;
}
- (id)initFromSerializedRepresentation:(NSDictionary *)representation
{
    self = [self init];
    if(self)
    {
        // STUB
    }
    
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.widgetSettingsView.frame = self.bounds;
    self.widgetContentView.frame = self.bounds;
    self.activityIndicatorView.center = self.widgetContentView.center;
}

#pragma mark - Logic
- (void)update
{
    NSLog(@"Updating widget of type: %@", [self class]);
}
- (NSDictionary *)serializedRepresentation
{
    return nil;
}

#pragma mark - Accessors
- (void)setBeingDragged:(BOOL)state
{
    _beingDragged = state;
    
    NSLog(@"Setting hidden: %@", state ? @"Y" : @"N");
    
    [self.widgetContentView setHidden:state];
    [self.widgetSettingsView setHidden:state];
}
- (CGFloat)height
{
    return 180.0f;
}

@end
