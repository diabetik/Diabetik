//
//  UAAddEntryListViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 30/12/2013.
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

#import "UAAddEntryListViewController.h"
#import "UAInputParentViewController.h"

@interface UAAddEntryListViewController ()
@end

@implementation UAAddEntryListViewController

#pragma mark - Setup
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
        [self.parentPopoverController dismissPopoverAnimated:YES];
        
        // We need to present this view controller from the app delegate to stop the
        // UIPopoverController from complaining about being in the progress of dismissal
        UIViewController *rootVC = [[UAAppDelegate sharedAppDelegate] viewController];
        
        if(rootVC)
        {
            UANavigationController *nvc = [[UANavigationController alloc] initWithRootViewController:vc];
            nvc.modalPresentationStyle = UIModalPresentationFormSheet;
            [rootVC presentViewController:nvc animated:YES completion:nil];
        }
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
