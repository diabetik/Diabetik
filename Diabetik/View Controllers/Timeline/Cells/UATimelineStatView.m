//
//  UATimelineStatView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 24/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UATimelineStatView.h"

@implementation UATimelineStatView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.font = [UAFont standardMediumFontWithSize:11.0f];
        self.textLabel.textColor = [UIColor colorWithRed:147.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        [self addSubview:self.textLabel];
    }
    
    return self;
}

#pragma mark - Accessors
- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    [self layoutSubviews];
}
- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    
    [self layoutSubviews];
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize textSize = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName: self.textLabel.font}];
    self.imageView.frame = CGRectMake(0.0f, 0.0f, self.imageView.image.size.width, self.imageView.image.size.height);
    self.textLabel.frame = CGRectMake(0.0f, 0.0f, textSize.width, textSize.height);
    
    CGFloat x = ceilf(self.bounds.size.width/2.0f - (self.textLabel.bounds.size.width + self.imageView.bounds.size.width + 5.0f)/2.0f);
    self.imageView.frame = CGRectMake(x, ceilf(self.bounds.size.height/2.0f - self.imageView.image.size.height/2.0f), self.imageView.image.size.width, self.imageView.image.size.height);
    self.textLabel.frame = CGRectMake(ceilf(x + self.imageView.bounds.size.width + 5.0f), ceilf(self.bounds.size.height/2.0f - self.textLabel.bounds.size.height/2.0f), self.textLabel.bounds.size.width, self.textLabel.bounds.size.height);
    
}

@end
