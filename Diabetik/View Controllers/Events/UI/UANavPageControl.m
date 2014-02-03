//
//  UANavPageControl.m
//  Diabetik
//
//  Created by Nial Giacomelli on 26/04/2013.
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

#import "UANavPageControl.h"
#import "UAInputParentViewController.h"
#import "UAMedicineInputViewController.h"
#import "UAMealInputViewController.h"
#import "UABGInputViewController.h"
#import "UAActivityInputViewController.h"
#import "UANoteInputViewController.h"

#define kIconSpacing 7.0f

@interface UANavPageControl ()
@property (nonatomic, retain) NSMutableArray *icons;

@end

@implementation UANavPageControl
@synthesize viewControllers = _viewControllers;
@synthesize icons = _icons;
@synthesize currentPage = _currentPage;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _icons = [NSMutableArray array];
        _viewControllers = nil;
        _currentPage = 0;
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.icons && [self.icons count])
    {
        CGSize iconSize = CGSizeMake(10.0f, 11.0f);
        CGFloat x = self.bounds.size.width/2.0f - (((iconSize.width+kIconSpacing)*[self.icons count])-kIconSpacing)/2.0f;
        
        for(UIImageView *icon in self.icons)
        {
            icon.frame = CGRectMake(x, 0.0f, iconSize.width, iconSize.height);
            x += iconSize.width + kIconSpacing;
        }
    }
}
- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = page;
    
    NSInteger pageIndex = 0;
    for(UIImageView *icon in self.icons)
    {
        [icon setImage:[UIImage imageNamed:[self iconForPage:pageIndex]]];
        pageIndex ++;
    }
}

#pragma mark - Accessors
- (void)setViewControllers:(NSArray *)controllers
{
    // Remove previous icons
    for(UIImageView *icon in self.icons)
    {
        [icon removeFromSuperview];
    }
    [self.icons removeAllObjects];
    
    _viewControllers = controllers;
    for(UAInputBaseViewController *vc in _viewControllers)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 11.0f)];
        [self addSubview:imageView];
        [self.icons addObject:imageView];
    }
    
    [self setNeedsLayout];
}

#pragma mark - Helper
- (NSString *)iconForPage:(NSInteger)page
{
    UAInputBaseViewController *vc = (UAInputBaseViewController  *)[self.viewControllers objectAtIndex:page];
    
    NSString *filename = @"";
    if([vc isKindOfClass:[UAMedicineInputViewController class]])
    {
        filename = @"NavBarIconMedicine";
    }
    else if([vc isKindOfClass:[UANoteInputViewController class]])
    {
        filename = @"NavBarIconNote";
    }
    else if([vc isKindOfClass:[UAMealInputViewController class]])
    {
        filename = @"NavBarIconMeal";
    }
    else if([vc isKindOfClass:[UABGInputViewController class]])
    {
        filename = @"NavBarIconBlood";
    }
    else if([vc isKindOfClass:[UAActivityInputViewController class]])
    {
        filename = @"NavBarIconActivity";
    }
    
    if(page == self.currentPage)
    {
        return filename;
    }
    else
    {
        return [filename stringByAppendingString:@"Inactive"];
    }
}

@end
