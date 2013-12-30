//
//  UAAddEntryListViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/12/2013.
//  Copyright (c) 2013 UglyApps. All rights reserved.
//

#import "UAAddEntryListViewController.h"
#import "UAInputParentViewController.h"

@interface UAAddEntryListViewController ()

@end

@implementation UAAddEntryListViewController

#pragma mark - Setup
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self)
    {
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[VKRSAppSoundPlayer sharedInstance] playSound:@"tap-significant"];
    
    UAInputParentViewController *vc = [[UAInputParentViewController alloc] initWithEventType:indexPath.row];
    if(vc)
    {
        UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"AddEntryCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddEntryCell"];
    }
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"Medicine";
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"Reading";
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text = @"Food";
    }
    else if(indexPath.row == 3)
    {
        cell.textLabel.text = @"Activity";
    }
    else if(indexPath.row == 4)
    {
        cell.textLabel.text = NSLocalizedString(@"Note", nil);
    }
        
    return cell;
}

@end
