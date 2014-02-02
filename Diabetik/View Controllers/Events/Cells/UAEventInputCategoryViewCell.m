//
//  UAEventInputCategoryViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UAEventInputCategoryViewCell.h"
#import "UACategoryInputView.h"

@implementation UAEventInputCategoryViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.control = [[UACategoryInputView alloc] initWithCategories:@[NSLocalizedString(@"units", nil), NSLocalizedString(@"mg", nil), NSLocalizedString(@"pills", nil), NSLocalizedString(@"puffs", nil)]];
    }
    return self;
}

@end
