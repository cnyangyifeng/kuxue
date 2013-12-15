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

@synthesize progressHud = _progressHud;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadContactsFromLocalStorage];
    
    // [self loadContacts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initializations

- (void)loadContacts
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *jid = [[[self appDelegate] xmppStream] myJID];
    [iq addAttributeWithName:@"from" stringValue:jid.description];
    [iq addAttributeWithName:@"to" stringValue:jid.domain];
    [iq addAttributeWithName:@"id" stringValue:@"123456"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    
    NSLog(@"Sending IQ: %@", iq);
    
    [[self xmppStream] sendElement:iq];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    
    self.progressHud = hud;
}

- (void)loadContactsFromLocalStorage
{
    // Fetches the application mock data.
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXContact"];
    NSMutableArray *raw = [[context executeFetchRequest:request error:nil] mutableCopy];
    self.contacts = [self partitionObjects:raw collationStringSelector:@selector(getSortableName)];
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
    
    KXContact *contact = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.contactAvatarImageView.image = [UIImage imageNamed:contact.avatar];
    cell.contactNameLabel.text = contact.nickname;
    
    return cell;
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushContactFromContacts"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        KXContact *contact = [[self.contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        KXContactTableViewController *contactTableViewController = segue.destinationViewController;
        contactTableViewController.theme = contact.theme;
        contactTableViewController.contactName = contact.nickname;
        contactTableViewController.contactAvatar = contact.avatar;
        
        contactTableViewController.hidesBottomBarWhenPushed = YES;
    }
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

- (void)contactsUpdated:(NSArray *)items
{
    NSLog(@"Callback: Contacts updated.");
    
    for (NSXMLElement *item in items) {
        NSString *jid = [item attributeStringValueForName:@"jid"];
        NSString *name = [item attributeStringValueForName:@"name"];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSManagedObject *contact = [NSEntityDescription insertNewObjectForEntityForName:@"KXContact" inManagedObjectContext:context];
        [contact setValue:@"new_yorker.jpg" forKey:@"avatar"];
        [contact setValue:name forKey:@"nickname"];
        [contact setValue:@"theme-1.jpg" forKey:@"theme"];
        [contact setValue:jid forKey:@"userId"];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Data not saved. %@, %@", error, [error userInfo]);
        }
    }
    
    [self loadContactsFromLocalStorage];
    
    // Reloads table data every time this view appears.
    [self.tableView reloadData];
    
    [self.progressHud hide:YES];
}

@end
