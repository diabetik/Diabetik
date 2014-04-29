//
//  UANavigationController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/04/2013.
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

#import "UANavigationController.h"
#import "UAInsightsViewController.h"

@implementation UANavigationController

#pragma mark - Setup
- (void)viewDidLoad
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
    
    // Setup a double tap gesture recogniser
    UITapGestureRecognizer *doubleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(didDoubleTapNavigationBar:)];
    doubleTapRecogniser.numberOfTapsRequired = 2;
    doubleTapRecogniser.delaysTouchesBegan = NO;
    doubleTapRecogniser.delaysTouchesEnded = NO;
    [self.navigationBar addGestureRecognizer:doubleTapRecogniser];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - UINavigationControllerDelegate
// A nasty hack found here: http://keighl.com/post/ios7-interactive-pop-gesture-custom-back-button/
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - Logic
- (void)didDoubleTapNavigationBar:(UIGestureRecognizer*)recognizer
{
    [self.view endEditing:YES];
    
    UAInsightsViewController *summaryVC = [[UAInsightsViewController alloc] init];
    [summaryVC presentInViewController:self];
}
- (NSUInteger)supportedInterfaceOrientations
{
    if([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return [self.topViewController supportedInterfaceOrientations];
    }
    
    return 0;
}
- (BOOL)shouldAutorotate
{
    if([self.topViewController respondsToSelector:@selector(shouldAutorotate)]) 
    {
        return [self.topViewController shouldAutorotate];
    }
    
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if([self.topViewController respondsToSelector:@selector(preferredStatusBarStyle)])
    {
        return [self.topViewController preferredStatusBarStyle];
    }
    
    return UIStatusBarStyleDefault;
}

@end