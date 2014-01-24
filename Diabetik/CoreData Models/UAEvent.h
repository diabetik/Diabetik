//
//  Event.h
//  Diabetik
//
//  Created by Nial Giacomelli on 17/02/2013.
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
@interface UAEvent : UAManagedObject
@property (nonatomic, retain) NSString *externalGUID;
@property (nonatomic, retain) NSString *externalSource;
@property (nonatomic, retain) NSNumber *filterType;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *sectionIdentifier;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *lon;
@property (nonatomic, retain) NSString *photoPath;
@property (nonatomic, retain) UAAccount *account;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSDate *primitiveTimestamp;
@property (nonatomic, retain) NSString *primitiveSectionIdentifier;

// Transient properties
- (NSString *)humanReadableName;

@end

@interface UAEvent (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
