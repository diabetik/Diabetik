//
//  UAEventInputTextFieldViewCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 20/02/2013.
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

#import "UAEventInputTextFieldViewCell.h"

@implementation UAEventInputTextFieldViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 0.0f, self.contentView.frame.size.width-10.0f, self.contentView.frame.size.height)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.backgroundColor = [UIColor clearColor];
        textField.adjustsFontSizeToFitWidth = NO;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.font = [UAFont standardDemiBoldFontWithSize:16.0f];
        textField.textColor = [UIColor colorWithRed:114.0f/255.0f green:118.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.text = @"";
        
        self.control = textField;
    }
    
    return self;
}

@end
