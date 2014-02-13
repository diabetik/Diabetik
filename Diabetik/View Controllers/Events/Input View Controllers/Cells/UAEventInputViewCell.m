//
//  UAEventInputViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 20/02/2013.
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

#import "UAEventInputViewCell.h"

@interface UAEventInputViewCell ()
@end

@implementation UAEventInputViewCell
@synthesize control = _control;
@synthesize label = _label;
@synthesize borderView = _borderView;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 44.0f)];
        _label.font = [UAFont standardRegularFontWithSize:16.0f];
        _label.textAlignment = NSTextAlignmentRight;
        _label.backgroundColor = [UIColor clearColor];
        _label.text = @" ";
        _label.textColor = [UIColor colorWithRed:110.0f/255.0f green:114.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
        _label.adjustsFontSizeToFitWidth = YES;
        _label.minimumScaleFactor = 0.5f;
        [self.contentView addSubview:_label];
        
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1.0f, self.frame.size.width, 1.0f)];
        _borderView.backgroundColor = [UIColor colorWithRed:232.0f/255.0f green:234.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
        _borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:_borderView];
    }
    return self;
}

#pragma mark - Logic
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self resetCell];
}
- (void)resetCell
{
    [self setDrawsBorder:YES];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    id control = self.control;
    if(control)
    {
        // This is a nasty hack for (what appears to be) a nasty Apple bug whereby input accessory views
        // aren't correctly removed when set to nil. Instead, we set an empty UIView instance.
        if([control respondsToSelector:@selector(setInputAccessoryView:)])
        {
            [control setInputAccessoryView:[[UIView alloc] initWithFrame:CGRectZero]];
            if([control respondsToSelector:@selector(reloadInputViews)])
            {
                [control reloadInputViews];
            }
        }
        if([control respondsToSelector:@selector(setInputView:)]) [control setInputView:nil];
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.borderView.frame = CGRectMake(0, self.frame.size.height-1.0f, self.frame.size.width, 1.0f);
    self.control.frame = CGRectMake(85.0f, 0.0f, self.frame.size.width-95.0f, self.frame.size.height);
}
- (void)setControl:(UIView *)aControl
{
    if(self.control)
    {
        [self.control removeFromSuperview];
        _control = nil;
    }
    
    _control = aControl;
    [self.contentView addSubview:self.control];
}
- (void)setDrawsBorder:(BOOL)border
{
    if(border)
    {
        self.borderView.backgroundColor = [UIColor colorWithRed:232.0f/255.0f green:234.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
        self.borderView.hidden = NO;
    }
    else
    {
        self.borderView.hidden = YES;
    }
}

@end
