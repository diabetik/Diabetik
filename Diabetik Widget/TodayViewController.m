//
//  TodayViewController.m
//  Diabetik Widget
//
//  Created by Nial Giacomelli on 04/06/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <NotificationCenter/NotificationCenter.h>

#import "TodayViewController.h"
#import "UAEventController.h"
#import "UACoreDataController.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)fetchData {
    NSLog(@"Fetching");
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSLog(@"Got moc");
        NSManagedObjectContext *childMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        childMOC.parentContext = moc;
        
        [childMOC performBlock:^{
            
            NSArray *events = [[UAEventController sharedInstance] fetchEventsWithPredicate:nil sortDescriptors:nil inContext:childMOC];
            if(events)
            {
                for(UAEvent *event in events)
                {
                    NSLog(@"%@", event);
                }
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self fetchData];

    completionHandler(NCUpdateResultNewData);
}

@end
