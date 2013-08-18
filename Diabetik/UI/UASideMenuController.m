//
//  UASideMenuController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 09/08/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UASideMenuController.h"
#import "UIImage+ImageEffects.h"

@interface UASideMenuController ()
{
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravityBehaviour;
    UIPushBehavior *pushBehaviour;
    
    UIImageView *snapshotView;
    UIPanGestureRecognizer *gestureRecognizer;
}

// Logic
- (void)layoutPanels;
- (UIImage *)snapshotCenterPanel;

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
        
        snapshotView = [[UIImageView alloc] init];
        snapshotView.alpha = 0.0f;
        
        gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPerformLeftEdgeGesture:)];
        gestureRecognizer.maximumNumberOfTouches = 1;
        gestureRecognizer.minimumNumberOfTouches = 1;
        
        _leftPanelContainer = [[UIView alloc] init];
        _leftPanelContainer.hidden = YES;
        [_leftPanelContainer addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionOld context:NULL];
        [_leftPanelContainer addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
        
        _centerPanelContainer = [[UIView alloc] init];
    }
    
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [baseView addSubview:_centerPanelContainer];
    [baseView addSubview:snapshotView];
    [baseView addSubview:_leftPanelContainer];
    [baseView addGestureRecognizer:gestureRecognizer];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:baseView];
    
    self.view = baseView;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutPanels];
    
    gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[_leftPanelContainer]];
    gravityBehaviour.gravityDirection = CGVectorMake(1.0f, 0.0f);
    
    UIDynamicItemBehavior *dynamicItemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_leftPanelContainer]];
    dynamicItemBehaviour.elasticity = 0.1f;
    dynamicItemBehaviour.allowsRotation = NO;
    dynamicItemBehaviour.density = 1.0f;
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[_leftPanelContainer]];
    collisionBehaviour.collisionDelegate = self;
    [collisionBehaviour addBoundaryWithIdentifier:@"right-boundary" fromPoint:CGPointMake(self.view.bounds.size.width+1.0f, 0.0f) toPoint:CGPointMake(self.view.bounds.size.width+1.0f, self.view.bounds.size.height)];
    [collisionBehaviour addBoundaryWithIdentifier:@"left-boundary" fromPoint:CGPointMake(-(self.view.bounds.size.width+1.0f), 0.0f) toPoint:CGPointMake(-(self.view.bounds.size.width+1.0f), self.view.bounds.size.height)];
    
    [animator addBehavior:dynamicItemBehaviour];
    [animator addBehavior:collisionBehaviour];
    [animator addBehavior:gravityBehaviour];
}
- (void)dealloc
{
    [self.leftPanelContainer removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - Logic
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"center"] || [keyPath isEqualToString:@"frame"])
    {
        CGFloat progress = (self.leftPanelContainer.frame.origin.x+self.leftPanelContainer.bounds.size.width)/(self.centerPanelContainer.bounds.size.width/2);
        if(progress < 0.0f) progress = 0.0f;
        if(progress > 1.0f) progress = 1.0f;
        snapshotView.alpha = progress;
    }
}
- (void)layoutPanels
{
    self.leftPanelContainer.frame = self.view.bounds;
    self.leftPanel.view.frame = self.leftPanelContainer.bounds;
    
    self.centerPanelContainer.frame = self.view.bounds;
    self.centerPanel.view.frame = self.centerPanelContainer.bounds;
}
- (UIImage *)snapshotCenterPanel
{
    UIGraphicsBeginImageContextWithOptions(self.centerPanelContainer.bounds.size, NO, 0);
    [self.centerPanelContainer drawViewHierarchyInRect:self.centerPanelContainer.bounds afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    snapshot = [snapshot applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.5 maskImage:nil];
    
    return snapshot;
}

#pragma mark - Gesture
- (void)didPerformLeftEdgeGesture:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        snapshotView.image = [self snapshotCenterPanel];
        snapshotView.frame = self.centerPanelContainer.frame;
        
        self.leftPanelContainer.hidden = NO;
        
        [animator removeBehavior:pushBehaviour];
        [animator removeBehavior:gravityBehaviour];
    }
    
    CGPoint translate = [recognizer locationInView:self.view];
    
    CGRect frame = self.leftPanelContainer.frame;
    frame.origin.x = ceilf(translate.x) - self.leftPanelContainer.bounds.size.width;
    self.leftPanelContainer.frame = frame;
    
    [animator updateItemUsingCurrentState:_leftPanelContainer];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [recognizer velocityInView:self.centerPanelContainer];
        if(velocity.x < 0) velocity.x = 0.0f;
        if(velocity.x > 350) velocity.x = 350;
        
        pushBehaviour = [[UIPushBehavior alloc] initWithItems:@[_leftPanelContainer] mode:UIPushBehaviorModeInstantaneous];
        pushBehaviour.pushDirection = CGVectorMake(1.0f, 0.0f);
        pushBehaviour.magnitude = velocity.x;
        pushBehaviour.angle = 0.0f;
        [animator addBehavior:pushBehaviour];
        [animator addBehavior:gravityBehaviour];
        
        self.menuState = UALeftPanelVisible;
    }
}

#pragma mark - UICollisionBehaviourDelegate methods
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
    if([(NSString *)identifier isEqualToString:@"right-boundary"])
    {
        self.menuState = UALeftPanelVisible;
    }
    else if([(NSString *)identifier isEqualToString:@"left-boundary"])
    {
        self.menuState = UACenterPanelVisible;
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