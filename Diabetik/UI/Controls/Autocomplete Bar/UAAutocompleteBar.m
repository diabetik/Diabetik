//
//  UAAutocompleteBar.m
//  Diabetik
//
//  Created by Nial Giacomelli on 27/12/2012.
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

#import "UAHelper.h"
#import "UAAutocompleteBar.h"
#import "UAAutocompleteBarButton.h"

@interface UAAutocompleteBar ()
- (void)buttonPressed:(UIButton *)sender;
@end

@implementation UAAutocompleteBar

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 12.0f, frame.size.height)];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.directionalLockEnabled = YES;
        [self addSubview:scrollView];
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        self.suggestions = nil;
        self.shouldFetchSuggestions = YES;
        
        buttons = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Logic
- (BOOL)showSuggestionsForInput:(NSString *)input
{
    // Lazy-load from our datasource if necessary
    if(self.shouldFetchSuggestions)
    {
        [self fetchSuggestions];
    }
    
    // Remove previous suggestions
    if([buttons count])
    {
        for(UIView *view in scrollView.subviews)
        {
            [view removeFromSuperview];
        }
        [buttons removeAllObjects];
    }
    
    // Don't bother re-populating our options if we're not searching for anything
    if(!input) return NO;
    
    // Generate new suggestions
    NSInteger totalSuggestions = 0;
    if(input && [input length])
    {
        NSString *lowercaseInput = [input lowercaseString];

        // Generate new suggestions
        CGFloat x = 10.0f;
        CGFloat margin = 5.0f;
        for(NSString *suggestion in self.suggestions)
        {
            // Determine whether this word is valid for the input'd text
            NSString *lowercaseSuggestions = [suggestion lowercaseString];
            if([lowercaseSuggestions hasPrefix:lowercaseInput] && ![lowercaseSuggestions isEqualToString:lowercaseInput])
            {
                UAAutocompleteBarButton *button = [[UAAutocompleteBarButton alloc] initWithFrame:CGRectMake(x, scrollView.bounds.size.height/2.0f - 28.0f/2.0f, 0.0f, 28.0f)];
                [button setTitle:suggestion forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [scrollView addSubview:button];
                [buttons addObject:button];
                
                x += button.frame.size.width + margin;
                totalSuggestions ++;
            }
        }
        
        scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
        scrollView.contentSize = CGSizeMake(x, 45.0f);
    }
    return totalSuggestions ? YES : NO;
}
- (void)fetchSuggestions
{
    self.suggestions = [self.delegate suggestionsForAutocompleteBar:self];
    self.shouldFetchSuggestions = NO;
}
- (void)addTag:(UIButton *)sender
{
    [self.delegate addTagCaret];
    [self showSuggestionsForInput:@""];
}
- (void)buttonPressed:(UIButton *)sender
{
    if([self.delegate respondsToSelector:@selector(autocompleteBar:didSelectSuggestion:)])
    {
        NSString *suggestion = [sender titleForState:UIControlStateNormal];
        [self.delegate autocompleteBar:self didSelectSuggestion:suggestion];
        
        [self showSuggestionsForInput:@""];
    }
}

@end
