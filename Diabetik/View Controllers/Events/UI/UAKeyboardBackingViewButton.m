//
//  UAKeyboardBackingViewButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 18/03/2013.
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

#import "UAKeyboardBackingViewButton.h"

#define kLabelSpacing 13.0f

@interface UAKeyboardBackingViewButton ()
{
    UIView *highlightOverlay;
}
@end

@implementation UAKeyboardBackingViewButton
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize fullsizeImageView = _fullsizeImageView;
@synthesize highlightColor = _highlightColor;
@synthesize textColor = _textColor;

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)aTextColor highlightColor:(UIColor *)aHighlightColor
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _highlightColor = aHighlightColor;
        _textColor = aTextColor;
        
        highlightOverlay = [[UIView alloc] initWithFrame:CGRectZero];
        highlightOverlay.backgroundColor = aHighlightColor;
        highlightOverlay.layer.cornerRadius = 3;
        highlightOverlay.hidden = YES;
        [self insertSubview:highlightOverlay belowSubview:self.imageView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        _activityIndicatorView.hidesWhenStopped = YES;
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_activityIndicatorView];
        
        _fullsizeImageView = [[UIImageView alloc] initWithFrame:frame];
        _fullsizeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fullsizeImageView.clipsToBounds = YES;
        _fullsizeImageView.layer.cornerRadius = 4;
        [self addSubview:_fullsizeImageView];
        
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.font = [UAFont standardDemiBoldFontWithSize:13.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5f;
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.adjustsImageWhenHighlighted = NO;
        
        [self setTitleColor:_textColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithWhite:0.0f alpha:0.15f] forState:UIControlStateDisabled];
    }
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.fullsizeImageView.frame = CGRectInset(self.bounds, 5, 5);
    self.imageView.frame = CGRectMake(floorf(self.frame.size.width/2-self.imageView.image.size.width/2), floorf(self.frame.size.height/2 - (self.imageView.image.size.height)), self.imageView.image.size.width, self.imageView.image.size.height);
    self.titleLabel.frame = CGRectMake(0.0f, floorf(self.frame.size.height/2 + kLabelSpacing), self.frame.size.width, 16.0f);
    
    highlightOverlay.frame = CGRectInset(self.bounds, 4, 4);
}
- (void)setTextColor:(UIColor *)color
{
    _textColor = color;
}
- (void)setHighlightColor:(UIColor *)color
{
    _highlightColor = color;
    
    highlightOverlay.backgroundColor = _highlightColor;
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    highlightOverlay.hidden = !highlighted;
}

@end
