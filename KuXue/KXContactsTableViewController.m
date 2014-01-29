//
//  KXContactsViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/12/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXContactsTableViewController.h"

@interface KXContactsTableViewController ()

@end

@protocol KXContact
- (NSString *)getSortableName;
@end

@implementation KXContactsTableViewController

@synthesize contacts = _contacts;

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
    [[self appDelegate] setContactsDelegate:self];
    /* Adds the pull-to-refresh capability. */
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to Refresh", nil)];
    [refreshControl addTarget:self action:@selector(refreshContacts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadContactsFromCoreDataStorage];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BOOL showSection = [[self.contacts objectAtIndex:section] count] != 0;
    return showSection ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.contacts objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactsTableViewCell";
    KXContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    XMPPUserCoreDataStorageObject *contact = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (contact.photo != nil) {
        cell.contactAvatarImageView.image = contact.photo;
    } else {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:contact.jid];
        if (photoData != nil) {
            cell.contactAvatarImageView.image = [UIImage imageWithData:photoData];
        } else {
            cell.contactAvatarImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_NAME];
        }
    }
    if (contact.nickname != nil) {
        cell.contactNameLabel.text = contact.nickname;
    } else {
        cell.contactNameLabel.text = [[contact jid] user];
    }
    
    return cell;
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushContactFromContacts"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        XMPPUserCoreDataStorageObject *contact = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        KXContactTableViewController *contactTableViewController = segue.destinationViewController;
        contactTableViewController.contact = contact;
        contactTableViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Core Data

- (void)loadContactsFromCoreDataStorage
{
    NSManagedObjectContext *context = [[self appDelegate] managedRosterObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    NSMutableArray *raw = [[context executeFetchRequest:request error:nil] mutableCopy];
    self.contacts = [self partitionObjects:raw collationStringSelector:@selector(getSortableName)];
}

#pragma mark - Contacts Partition

-(NSMutableArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    // Section count is taken from sectionTitles, not sectionIndexTitles.
    NSInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    // Creates an array to hold the data for each section.
    for (int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    // Puts each object into a section.
    for (id object in array) {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    // Sorts each section.
    for (NSMutableArray *section in unsortedSections) {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}

#pragma mark - KXContactsDelegate

- (void)xmppRosterDidEndPopulating
{
    NSLog(@"KXContactsDelegate callback: xmpp roster did end populating.");
    [self loadContactsFromCoreDataStorage];
    [self.tableView reloadData];
}

- (void)didReceiveRosterItem
{
    NSLog(@"KXContactsDelegate callback: did receive roster item.");
    [self loadContactsFromCoreDataStorage];
    [self.tableView reloadData];
}

#pragma mark - Pull to Refresh

- (void)refreshContacts
{
    [self.contacts removeAllObjects];
    
    [self loadContactsFromCoreDataStorage];
    [self.tableView reloadData];
    
    [self performSelector:@selector(endRefreshingContacts) withObject:nil afterDelay:0.0f];
}

- (void)endRefreshingContacts
{
    [self.refreshControl endRefreshing];
}

@end
