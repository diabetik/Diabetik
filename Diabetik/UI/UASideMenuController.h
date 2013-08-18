//
//  UASideMenuController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 09/08/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum UASideMenuState {
    UACenterPanelVisible = 0,
    UALeftPanelVisible = 1
} UASideMenuState;

@interface UASideMenuController : UIViewController <UICollisionBehaviorDelegate>
@property (nonatomic, assign) UASideMenuState menuState;

@property (nonatomic, strong) UIViewController *leftPanel;
@property (nonatomic, strong) UIViewController *centerPanel;
@property (nonatomic, strong) UIView *leftPanelContainer;
@property (nonatomic, strong) UIView *centerPanelContainer;

@end
