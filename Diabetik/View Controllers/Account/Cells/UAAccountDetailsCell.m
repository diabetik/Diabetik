//
//  UAAccountDetailsCell.m
//  Diabetik
//
//  Created by Nial Giacomelli on 16/04/2013.
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

#import "UAAccountDetailsCell.h"

@implementation UAAccountDetailsCell
@synthesize avatarButton = _avatarButton;
@synthesize nameTextField = _nameTextField;
@synthesize metadataLabel = _metadataLabel;

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _avatarButton = [[UAAccountAvatarButton alloc] initWithFrame:CGRectMake(8.0f, 10.0f, 58.0f, 58.0f)];
        [self.contentView addSubview:_avatarButton];
        
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(80.0f, 8.0f, 210.0f, 44.0f)];
        _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _nameTextField.font = [UAFont standardDemiBoldFontWithSize:16.0f];
        _nameTextField.textColor = [UIColor colorWithRed:114.0f/255.0f green:118.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
        _nameTextField.keyboardType = UIKeyboardTypeDefault;
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextField.adjustsFontSizeToFitWidth = NO;
        _nameTextField.keyboardType = UIKeyboardTypeAlphabet;
        _nameTextField.textAlignment = NSTextAlignmentLeft;
        _nameTextField.placeholder = NSLocalizedString(@"Your name", nil);
        [self.contentView addSubview:_nameTextField];
        
        _metadataLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 28.0f, 210.0f, 44.0f)];
        _metadataLabel.font = [UAFont standardRegularFontWithSize:14.0f];
        _metadataLabel.textColor = [UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        _metadataLabel.adjustsFontSizeToFitWidth = NO;
        _metadataLabel.textAlignment = NSTextAlignmentLeft;
        _metadataLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_metadataLabel];
    }
    return self;
}

@end
