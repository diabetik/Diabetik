//
//  UATagsViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 25/01/2014.
//  Copyright (c) 2014 UglyApps. All rights reserved.
//

#import "UATagsViewController.h"
#import "UATimelineViewController.h"

#import "UATag.h"

@interface UATagsViewController ()
{
    UAAlertMessageView *noTagsView;
}
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
    
    if(!noTagsView)
    {
        noTagsView = [[UAAlertMessageView alloc] initWithFrame:CGRectZero
                                                         andTitle:NSLocalizedString(@"No Tags", @"Title of message shown when the user has yet to create any tags")
                                                       andMessage:NSLocalizedString(@"You haven't tagged any entries yet!", nil)];
        [self.view addSubview:noTagsView];
    }
    
    [self refreshView];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    noTagsView.frame = CGRectMake(0.0f, self.topLayoutGuide.length, self.view.bounds.size.width, self.view.bounds.size.height-self.topLayoutGuide.length);
}

#pragma mark - Logic
- (void)refreshView
{
    // Finally, if we have no data hide our tableview
    if([[[self fetchedResultsController] fetchedObjects] count])
    {
        self.tableView.alpha = 1.0f;
        noTagsView.alpha = 0.0f;
    }
    else
    {
        self.tableView.alpha = 0.0f;
        noTagsView.alpha = 1.0f;
    }
}
- (void)configureCell:(UITableViewCell *)aCell forTableview:(UITableView *)aTableView atIndexPath:(NSIndexPath *)indexPath
{
    UATag *tag = (UATag *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    aCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    aCell.textLabel.text = [NSString stringWithFormat:@"%@ %d", tag.name, [tag.events count]];
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
    UAGenericTableViewCell *cell = nil;
    cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UATimelineViewCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UATimelineViewCell"];
    }
    [(UAGenericTableViewCell *)cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
    
    [self configureCell:(UAGenericTableViewCell *)cell forTableview:aTableView atIndexPath:indexPath];
    
    return cell;
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
}


@end
