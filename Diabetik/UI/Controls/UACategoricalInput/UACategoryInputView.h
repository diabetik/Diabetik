//
//  UACategoryInputView.h
//  Diabetik
//
//  Created by Nial Giacomelli on 02/02/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UACategorySelectorButton.h"

@class UACategoryInputView;
@protocol UACategoryInputViewDelegate <NSObject>

- (void)categoryInputView:(UACategoryInputView *)categoryInputView didSelectOption:(NSUInteger)index;

@end

@interface UACategoryInputView : UIView <UIActionSheetDelegate>
@property (nonatomic, weak) id<UACategoryInputViewDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UACategorySelectorButton *selectorButton;
@property (nonatomic, assign) NSUInteger selectedIndex;

// Setup
- (id)initWithCategories:(NSArray *)categories;

@end
