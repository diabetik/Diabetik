//
//  UAIntroductionTooltipView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 29/12/2012.
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

#import "UAIntroductionTooltipView.h"
#import "UAModalView.h"

@interface UAIntroductionTooltipView ()
{
    UIPageControl *pageControl;
}

- (UIView *)pageForIndex:(NSInteger)index;
@end

@implementation UAIntroductionTooltipView

#pragma mark - Logic
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        
        NSInteger numPages = 4;
        
        // Setup pages
        for(int i = 0; i < numPages; i++)
        {
            UIView *view = [self pageForIndex:i];
            [scrollView addSubview:view];
        }
        
        scrollView.contentSize = CGSizeMake((numPages+1) * self.frame.size.width, self.frame.size.height);
        [self addSubview:scrollView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-60, self.frame.size.width, 60)];
        pageControl.numberOfPages = numPages;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        {
            pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
            pageControl.pageIndicatorTintColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:0.25f];
        }
        [self addSubview:pageControl];
    }
    return self;
}

#pragma mark - Logic
- (UIView *)pageForIndex:(NSInteger)index
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(index*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    
    CGFloat contentHeight = 200.0f, headerHeight = 30.0f;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, floorf(self.frame.size.height/2 - ((contentHeight+headerHeight)/2)), self.frame.size.width, contentHeight+headerHeight)];
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(floorf(self.frame.size.width/2 - 20), headerHeight+10, 40, 2)];
    border.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:237.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
    [containerView addSubview:border];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(floorf(self.frame.size.width/2 - 200/2), 0, 200, headerHeight)];
    header.backgroundColor = [UIColor clearColor];
    header.textColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
    header.numberOfLines = 1;
    header.textAlignment = NSTextAlignmentCenter;
    header.font = [UAFont standardBoldFontWithSize:26.0f];
    header.text = NSLocalizedString(@"Hi there!", nil);
    header.adjustsFontSizeToFitWidth = YES;
    header.minimumScaleFactor = 0.5f;
    
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(floorf(self.frame.size.width/2 - 225/2), headerHeight+20, 225, contentHeight)];
    content.backgroundColor = [UIColor clearColor];
    content.textColor = [UIColor colorWithRed:115.0f/255.0f green:128.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
    content.numberOfLines = 0;
    content.textAlignment = NSTextAlignmentCenter;
    content.font = [UAFont standardRegularFontWithSize:16.0f];

    if(index == 0)
    {
        header.text = NSLocalizedString(@"Hi there!", nil);
        content.text = NSLocalizedString(@"Diabetik is a new kind of diabetic journal that lets you track your blood glucose, medication, food and personal activities.\n\nTo learn more swipe your finger to the left.", nil);
    }
    else if(index == 1)
    {
        header.text = NSLocalizedString(@"Nice to meet you", nil);
        content.text = NSLocalizedString(@"Diabetik makes keeping your journal up-to-date as easy as possible by analysing your habits.\n\nIt may take a few days to really get to know you, so please be patient!", nil);
    }
    else if(index == 2)
    {
        header.text = NSLocalizedString(@"Your new journal", nil);
        content.text = NSLocalizedString(@"We've set you up with a new journal. You're welcome to create as many as you'd like.\n\nCheck out the settings screen to manage additional accounts.", nil);
    }
    else if(index == 3)
    {
        header.text = NSLocalizedString(@"Stay safe", nil);
        content.text = NSLocalizedString(@"Diabetik cannot and will not advise you with regards to medical care.\n\nIf you have questions or concerns regarding the state of your health please see a medical professional.", nil);
    }
    [containerView addSubview:header];
    [containerView addSubview:content];
    
    [view addSubview:containerView];
    
    return view;
}

#pragma mark - UIScrollViewDelegate method
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = sender.frame.size.width;
    int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // Dismissing the modal if we scroll past the end
    if(page > 3)
    {
        page = 3;
        UAModalView *modalView = (UAModalView *)[[[self superview] superview] superview];
        [modalView dismiss];
    }
    
    pageControl.currentPage = page;
}

@end
