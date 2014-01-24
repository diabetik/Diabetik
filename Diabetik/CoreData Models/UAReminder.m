//
//  UAReminder.m
//  Diabetik
//
//  Created by Nial Giacomelli on 03/03/2013.
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

#import "UAReminder.h"
#import "UAReminderController.h"

@implementation UAReminder

@dynamic active;
@dynamic created;
@dynamic date;
@dynamic days;
@dynamic message;
@dynamic type;
@dynamic account;
@dynamic lat, lng, locationName;
@dynamic trigger;

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    
    [[UAReminderController sharedInstance] deleteNotificationsWithID:self.guid];
}

@end
