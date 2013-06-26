//
//  UAKeyboardController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/03/2013.
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

#import "UAKeyboardController.h"

@interface UAKeyboardController ()
@property (nonatomic, strong) UITextField *dummyTextField;
@end

@implementation UAKeyboardController
@synthesize dummyTextField = _dummyTextField;

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        self.keyboardSize = CGSizeZero;
        
        // Create an invisible UITextField and add it to our root window's view hierarchy
        _dummyTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _dummyTextField.hidden = YES;
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:_dummyTextField];
    }
    
    return self;
}

#pragma mark - Logic
- (void)fetchKeyboardSize
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillPresent:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    // Ask the keyboard to appear
    [self.dummyTextField becomeFirstResponder];
}
- (void)keyboardWillPresent:(NSNotification *)notification
{
    // Dismiss the keyboard immediately so that it remains unseen
    [self.dummyTextField resignFirstResponder];
    
    // Fetch and cache the keyboard size
    NSDictionary *info = [notification userInfo];
    self.keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Remove ourselves as an observer to avoid interrupting legitimate keyboard usage
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

@end