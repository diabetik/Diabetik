//
//  UAMenuAccountAvatarView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 29/11/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UAMenuAccountAvatarView.h"

@implementation UAMenuAccountAvatarView

#pragma mark - Setup
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if(self)
    {
        self.contentMode = UIViewContentModeScaleAspectFit;
        //imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.layer.cornerRadius = 25.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2.0f;
        self.clipsToBounds = YES;
    }
    
    return self;
}
@end
