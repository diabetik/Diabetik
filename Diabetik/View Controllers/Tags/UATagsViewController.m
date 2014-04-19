//
//  UATagsViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 25/01/2014.
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

#import "UATagsViewController.h"
#import "UATimelineViewController.h"

#import "UATagController.h"
#import "UATagTableViewCell.h"
#import "UATag.h"

@interface UATagsViewController ()
@property (nonatomic, strong) UAViewControllerMessageView *noTagsMessageView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// Logic
- (void)configureCell:(UITableViewCell *)aCell forTableview:(UITableView *)aTableView atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation UATagsViewController

#pragma mark - Setup
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.title = NSLocalizedString(@"Tags", nil);
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.noTagsMessageView)
    {
        self.noTagsMessageView = [UAViewControllerMessageView addToViewController:self
                                                                        withTitle:NSLocalizedString(@"No Tags", @"Title of message shown when the user has yet to create any tags")
                                                                       andMessage:NSLocalizedString(@"You haven't tagged any entries yet!", nil)];
    }
    
    [self refreshView];
}

#pragma mark - Logic
- (void)refreshView
{
    if([[[self fetchedResultsController] fetchedObjects] count])
    {
        self.tableView.alpha = 1.0f;
        self.noTagsMessageView.alpha = 0.0f;
    }
    else
    {
        self.tableView.alpha = 0.0f;
        self.noTagsMessageView.alpha = 1.0f;
    }
}
- (void)configureCell:(UITableViewCell *)aCell forTableview:(UITableView *)aTableView atIndexPath:(NSIndexPath *)indexPath
{
    UATagTableViewCell *cell = (UATagTableViewCell *)aCell;
    UATag *tag = (UATag *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = tag.name;
    cell.badgeView.value = [NSString stringWithFormat:@"%lu", (unsigned long)[tag.events count]];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UATagTableViewCell *cell = nil;
    cell = (UATagTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UATagTableViewCell"];
    if (cell == nil)
    {
        cell = [[UATagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UATagTableViewCell"];
    }
    [self configureCell:(UATagTableViewCell *)cell forTableview:aTableView atIndexPath:indexPath];
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UATag *tag = (UATag *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSError *error = nil;
    NSRegularExpression *regex = [UATagController tagRegularExpression];
    if(!error)
    {
        for(UAEvent *event in tag.events)
        {
            __block NSUInteger removedTags = 0;
            __block NSString *notes = event.notes;
            [regex enumerateMatchesInString:event.notes
                                    options:kNilOptions
                                      range:NSMakeRange(0, [event.notes length])
                                 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                
                NSString *tagValue = [event.notes substringWithRange:[match rangeAtIndex:1]];
                if([[tagValue lowercaseString] isEqualToString:tag.nameLC])
                {
                    NSRange adjustedRange = NSMakeRange(match.range.location+removedTags, match.range.length);
                    notes = [notes stringByReplacingCharactersInRange:adjustedRange withString:tagValue];
                    removedTags ++;
                }

                
            }];
            event.notes = notes;
        }
        
        NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            [moc deleteObject:tag];
            [moc save:&error];
        }
    }
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    UATag *tag = (UATag *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UATimelineViewController *vc = [[UATimelineViewController alloc] initWithTag:tag.nameLC];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UATag" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                    managedObjectContext:moc
                                                                                                      sectionNameKeyPath:nil
                                                                                                               cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        if (![aFetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _fetchedResultsController;
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forTableview:self.tableView atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self.tableView reloadData];
    [self refreshView];
}


@end
