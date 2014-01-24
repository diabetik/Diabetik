//
//  UAReminder.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UAAccount;

@interface UAReminder : UAManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * days;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * type;

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSNumber * trigger;

@property (nonatomic, retain) UAAccount *account;

@end
