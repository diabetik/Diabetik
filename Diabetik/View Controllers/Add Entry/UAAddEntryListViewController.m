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
    self.tableView.tableFooterView = [UIView new];
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
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
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
        cell.imageView.image = [UIImage imageNamed:@"TimelineIconMedicine"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"TimelineIconMedicineHighlighted"];
        cell.textLabel.text = NSLocalizedString(@"Medicine", nil);
    }
    else if(indexPath.row == 1)
    {
        cell.imageView.image = [UIImage imageNamed:@"TimelineIconBlood"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"TimelineIconBloodHighlighted"];
        cell.textLabel.text = NSLocalizedString(@"Reading", nil);
    }
    else if(indexPath.row == 2)
    {
        cell.imageView.image = [UIImage imageNamed:@"TimelineIconMeal"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"TimelineIconMealHighlighted"];
        cell.textLabel.text = NSLocalizedString(@"Food", nil);
    }
    else if(indexPath.row == 3)
    {
        cell.imageView.image = [UIImage imageNamed:@"TimelineIconActivity"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"TimelineIconActivityHighlighted"];
        cell.textLabel.text = NSLocalizedString(@"Activity", nil);
    }
    else if(indexPath.row == 4)
    {
        cell.imageView.image = [UIImage imageNamed:@"TimelineIconNote"];
        cell.imageView.highlightedImage = [UIImage imageNamed:@"TimelineIconNoteHighlighted"];
        cell.textLabel.text = NSLocalizedString(@"Note", nil);
    }
        
    return cell;
}

@end
