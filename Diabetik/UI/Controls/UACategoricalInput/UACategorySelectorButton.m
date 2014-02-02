//
//  UACategorySelectorButton.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UACategorySelectorButton.h"

@implementation UACategorySelectorButton

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UAFont standardMediumFontWithSize:16.0f];
        self.titleLabel.contentMode = UIViewContentModeCenter;
        
        [self setImage:[UIImage imageNamed:@"DropdownDisclosureIcon"] forState:UIControlStateNormal];
        
        [self setTitleColor:[UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    
    return self;
}

#pragma mark - Accessors
- (void)setTitle:(NSString *)aTitle
{
    [self setTitle:aTitle forState:UIControlStateNormal];
    
    CGSize titleSize = [aTitle sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.bounds = CGRectMake(0.0f, 0.0f, titleSize.width+self.imageView.bounds.size.width+20.0f, self.bounds.size.height);
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(10.0f, 0.0f, self.bounds.size.width - self.imageView.image.size.width, self.bounds.size.height);
    self.imageView.frame = CGRectMake(self.bounds.size.width - self.imageView.image.size.width, self.bounds.size.height/2.0f - self.imageView.image.size.height/2.0f, self.imageView.image.size.width, self.imageView.image.size.height);
}

#pragma mark - Rendering
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0,0);
    CGContextAddLineToPoint(context, 0.0f, self.bounds.size.height);
    
    CGContextStrokePath(context);
}

@end
