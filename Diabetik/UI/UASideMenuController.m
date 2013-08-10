//
//  UASideMenuController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 09/08/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UASideMenuController.h"

@interface UASideMenuController ()
{
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravityBehaviour;
    UIPushBehavior *pushBehaviour;
    
    UIScreenEdgePanGestureRecognizer *gestureRecognizer;
}

// Logic
- (void)layoutPanels;

@end

@implementation UASideMenuController
@synthesize leftPanel = _leftPanel, centerPanel = _centerPanel;
@synthesize leftPanelContainer = _leftPanelContainer, centerPanelContainer = _centerPanelContainer;
@synthesize menuState = _menuState;

#pragma mark - Setup
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        _menuState = UACenterPanelVisible;
    }
    
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _leftPanelContainer = [[UIView alloc] init];
    _leftPanelContainer.hidden = YES;
    _centerPanelContainer = [[UIView alloc] init];
    [baseView addSubview:_centerPanelContainer];
    [baseView addSubview:_leftPanelContainer];
    
    gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPerformLeftEdgeGesture:)];
    gestureRecognizer.edges = UIRectEdgeLeft;
    gestureRecognizer.maximumNumberOfTouches = 1;
    gestureRecognizer.minimumNumberOfTouches = 1;
    [baseView addGestureRecognizer:gestureRecognizer];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:baseView];
    
    self.view = baseView;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self layoutPanels];
    
    gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[_leftPanelContainer]];
    gravityBehaviour.gravityDirection = CGVectorMake(1.0f, 0.0f);
    
    UIDynamicItemBehavior *dynamicItemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_leftPanelContainer]];
    dynamicItemBehaviour.elasticity = 0.1f;
    dynamicItemBehaviour.allowsRotation = NO;
    dynamicItemBehaviour.density = 1.0f;
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[_leftPanelContainer]];
    [collisionBehaviour addBoundaryWithIdentifier:@"1" fromPoint:CGPointMake(self.view.bounds.size.width+1.0f, 0.0f) toPoint:CGPointMake(self.view.bounds.size.width+1.0f, self.view.bounds.size.height)];
    
    [animator addBehavior:dynamicItemBehaviour];
    [animator addBehavior:collisionBehaviour];
    [animator addBehavior:gravityBehaviour];
}
- (void)layoutPanels
{
    self.leftPanelContainer.frame = self.view.bounds;
    self.leftPanel.view.frame = self.leftPanelContainer.bounds;
 
    self.centerPanelContainer.frame = self.view.bounds;
    self.centerPanel.view.frame = self.centerPanelContainer.bounds;
}

#pragma mark - Gesture
- (void)didPerformLeftEdgeGesture:(UIPanGestureRecognizer *)recognizer
{
    if(self.menuState == UALeftPanelVisible) return;
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.leftPanelContainer.hidden = NO;
        
        [animator removeBehavior:pushBehaviour];
        [animator removeBehavior:gravityBehaviour];
    }
    
    CGPoint translate = [recognizer translationInView:self.centerPanelContainer];
    
    CGRect frame = self.leftPanelContainer.frame;
    frame.origin.x = ceilf(translate.x - self.leftPanelContainer.bounds.size.width);
    self.leftPanelContainer.frame = frame;
    
    [animator updateItemUsingCurrentState:_leftPanelContainer];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        pushBehaviour = [[UIPushBehavior alloc] initWithItems:@[_leftPanelContainer] mode:UIPushBehaviorModeInstantaneous];
        pushBehaviour.pushDirection = CGVectorMake(1.0f, 0.0f);
        pushBehaviour.magnitude = velocity.x;
        pushBehaviour.angle = 0.0f;
        [animator addBehavior:pushBehaviour];
        [animator addBehavior:gravityBehaviour];
        
        self.menuState = UALeftPanelVisible;
    }
}

#pragma mark - Setters
- (void)setLeftPanel:(UIViewController *)aVC
{
    _leftPanel = aVC;
    
    [self layoutPanels];
    
    [aVC willMoveToParentViewController:self];
    [self addChildViewController:aVC];
    [_leftPanelContainer addSubview:aVC.view];
    [aVC didMoveToParentViewController:self];
}
- (void)setCenterPanel:(UIViewController *)aVC
{
    _centerPanel = aVC;
    
    [self layoutPanels];
    
    [aVC willMoveToParentViewController:self];
    [self addChildViewController:aVC];
    [_centerPanelContainer addSubview:aVC.view];
    [aVC didMoveToParentViewController:self];
}

@end