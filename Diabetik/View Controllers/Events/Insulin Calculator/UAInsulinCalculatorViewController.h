//
//  UAInsulinCalculatorViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 28/06/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UABaseViewController.h"

@interface UAInsulinCalculatorViewController : UABaseTableViewController
@property (nonatomic, retain) NSManagedObjectContext *moc;

// Setup
- (id)initWithMOC:(NSManagedObjectContext *)aMOC andAccount:(UAAccount *)anAccount;

@end
