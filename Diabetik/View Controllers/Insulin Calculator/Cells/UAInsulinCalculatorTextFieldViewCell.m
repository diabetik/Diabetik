//
//  UAInsulinCalculatorTextFieldViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 29/06/2013.
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

#import "UAInsulinCalculatorTextFieldViewCell.h"

@interface UAInsulinCalculatorTextFieldViewCell ()
@end

@implementation UAInsulinCalculatorTextFieldViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, self.contentView.frame.size.height)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.backgroundColor = [UIColor clearColor];
        textField.adjustsFontSizeToFitWidth = NO;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.font = [UAFont standardRegularFontWithSize:16.0f];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.textAlignment = NSTextAlignmentRight;
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textField.text = @"";
        
        [self setAccessoryView:textField];
    }
    return self;
}

@end
