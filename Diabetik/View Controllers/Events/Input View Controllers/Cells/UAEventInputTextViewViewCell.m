//
//  UAEventInputTextViewViewCell.m
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

#import "UAEventInputTextViewViewCell.h"
#import "UAEventNotesTextView.h"

@implementation UAEventInputTextViewViewCell

#pragma mark - Setup
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UAEventNotesTextView *textView = [[UAEventNotesTextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.scrollEnabled = NO;
        textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textView.autocorrectionType = UITextAutocorrectionTypeYes;
        textView.font = [UAFont standardMediumFontWithSize:16.0f];
        textView.textColor = [UIColor colorWithRed:49.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
        textView.text = @"";
        textView.inputView = nil;
        textView.inputAccessoryView = nil;
        
        self.control = textView;
    }
    
    return self;
}

#pragma mark - Logic
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.control.frame = CGRectMake(78.0f, 0.0f, self.frame.size.width-88.0f, self.frame.size.height);
}

@end
