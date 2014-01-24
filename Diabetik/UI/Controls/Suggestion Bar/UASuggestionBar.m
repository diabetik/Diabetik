//
//  UASuggestionBar.m
//  Diabetik
//
//  Created by Nial Giacomelli on 01/06/2013.
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

#import "UASuggestionBar.h"

@interface UASuggestionBar ()
{
    UIScrollView *scrollView;
}
@end

@implementation UASuggestionBar
@synthesize suggestions = _suggestions;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 12.0f, frame.size.height)];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.directionalLockEnabled = YES;
        [self addSubview:scrollView];
    }
    
    return self;
}
#pragma mark - Logic
- (void)addSuggestions:(NSArray *)theSuggestions
{
    _suggestions = theSuggestions;
    
    CGFloat x = 10.0f, margin = 5.0f;
    for(UIView *suggestion in _suggestions)
    {
        if([suggestion superview]) [suggestion removeFromSuperview];
        
        suggestion.frame = CGRectMake(x, suggestion.frame.origin.y, suggestion.frame.size.width, suggestion.frame.size.height);
        [scrollView addSubview:suggestion];
        x += suggestion.frame.size.width + margin;
    }
    
    scrollView.contentSize = CGSizeMake(x, scrollView.bounds.size.height);
}

@end
