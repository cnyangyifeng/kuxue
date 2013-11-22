//
//  KXHomeTableViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/12/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXHomeTableViewController.h"

@interface KXHomeTableViewController ()

@end

@implementation KXHomeTableViewController

@synthesize ideas = _ideas;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Fetches the application mock data.
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXIdea"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"sid" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
    self.ideas = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    // Reloads table data every time this view appears.
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ideas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"homeTableViewCell";
    
    KXHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    KXIdea *idea = [self.ideas objectAtIndex:indexPath.row];
    cell.contactAvatarImageView.image = [UIImage imageNamed:idea.contactAvatar];
    cell.contactNameLabel.text = idea.contactName;
    cell.ideaThumbnailImageView.image = [UIImage imageNamed:idea.ideaThumbnail];
    cell.ideaTitleLabel.text = idea.ideaTitle;
    cell.ideaTimeReceivedLabel.text = idea.ideaTimeReceived;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Deletes the selected record from core data.
        [context deleteObject:[self.ideas objectAtIndex:indexPath.row]];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Data not deleted. %@, %@", error, [error userInfo]);
            return;
        }
        // Removes the selected row from table view.
        [self.ideas removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushContactFromHome"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        KXIdea *idea = [self.ideas objectAtIndex:indexPath.row];
        
        KXContactTableViewController *contactTableViewController = segue.destinationViewController;
        contactTableViewController.theme = idea.theme;
        contactTableViewController.contactName = idea.contactName;
        contactTableViewController.contactAvatar = idea.contactAvatar;
        
        contactTableViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

@end
