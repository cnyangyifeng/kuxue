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

@synthesize conversations = _conversations;

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
    [[self appDelegate] setHomeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadConversationsFromCoreDataStorage];
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
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"homeTableViewCell";
    KXHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    XMPPMessageArchiving_Contact_CoreDataObject *conversation = [self.conversations objectAtIndex:indexPath.row];
    KXAppDelegate *delegate = [self appDelegate];
    XMPPUserCoreDataStorageObject *contact = [[delegate xmppRosterCoreDataStorage] userForJID:[conversation bareJid] xmppStream:[delegate xmppStream] managedObjectContext:[delegate managedRosterObjectContext]];
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
    cell.contactNameLabel.text = [[conversation bareJid] user];
    cell.messageTimestampLabel.text = [NSDateFormatter localizedStringFromDate:conversation.mostRecentMessageTimestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    cell.messageTypeImageView.image = [UIImage imageNamed:@"MessageTypeVoice"];
    cell.messageBodyLabel.text = conversation.mostRecentMessageBody;
    cell.unreadLabel.text = [contact.unreadMessages stringValue];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [[self appDelegate] managedMessageArchivingObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // FIXME: Should also delete related messages.
        /* Deletes the selected record from core data. */
        [context deleteObject:[self.conversations objectAtIndex:indexPath.row]];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Data not deleted. %@, %@", error, [error userInfo]);
            return;
        }
        /* Removes the selected row from table view. */
        [self.conversations removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KXChatViewController *chatViewController = [[KXChatViewController alloc] init];
    
    XMPPMessageArchiving_Contact_CoreDataObject *conversation = [self.conversations objectAtIndex:indexPath.row];
    KXAppDelegate *delegate = [self appDelegate];
    XMPPUserCoreDataStorageObject *contact = [[delegate xmppRosterCoreDataStorage] userForJID:[conversation bareJid] xmppStream:[delegate xmppStream] managedObjectContext:[delegate managedRosterObjectContext]];
    chatViewController.contact = contact;
    chatViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - Core Data

- (void)loadConversationsFromCoreDataStorage
{
    NSManagedObjectContext *context = [[self appDelegate] managedMessageArchivingObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr==%@", [[[[self appDelegate] xmppStream] myJID] bare]];
    [request setPredicate:predicate];
    self.conversations = [[context executeFetchRequest:request error:nil] mutableCopy];
}

#pragma mark - KXHomeDelegate

- (void)didConnect
{
    NSLog(@"KXHomeDelegate callback: User did connect.");
    self.navigationItem.title = @"KuXue";
}

- (void)didDisconnect
{
    NSLog(@"KXHomeDelegate callback: User did disconnect.");
    self.navigationItem.title = @"Disconnected";
}

- (void)didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"KXHomeDelegate callback: New messsage received, home view updated.");
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PROGRESS_VERY_SHORT_TIME_IN_SECONDS * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadConversationsFromCoreDataStorage];
        [self.tableView reloadData];
    });
}

@end
