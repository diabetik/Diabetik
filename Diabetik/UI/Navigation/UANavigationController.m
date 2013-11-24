//
//  UANavigationController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/04/2013.
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

#import "UANavigationController.h"

@implementation UANavigationController

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
