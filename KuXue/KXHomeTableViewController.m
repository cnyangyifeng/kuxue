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

@synthesize messages = _messages;

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
    [[self appDelegate] setMessageDelegate:self];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initializations

- (void)initData
{
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXMessage"];
    self.messages = [[context executeFetchRequest:request error:nil] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"homeTableViewCell";
    KXHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    KXMessage *message = [self.messages objectAtIndex:indexPath.row];
    cell.contactAvatarImageView.image = [UIImage imageNamed:message.contactAvatar];
    cell.contactNameLabel.text = message.contactName;
    cell.messageBodyLabel.text = message.messageContent;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Deletes the selected record from core data.
        [context deleteObject:[self.messages objectAtIndex:indexPath.row]];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Data not deleted. %@, %@", error, [error userInfo]);
            return;
        }
        // Removes the selected row from table view.
        [self.messages removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)scrollTableView
{
    if (self.messages.count > 1) {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - KXMessageDelegate

- (void)newMessageReceived:(XMPPMessage *)message
{
    NSLog(@"Callback: New messsage received, home view updated.");
    XMPPUserCoreDataStorageObject *contact = [[[self appDelegate] xmppRosterCoreDataStorage] userForJID:[message from] xmppStream:[[self appDelegate] xmppStream] managedObjectContext:[[self appDelegate] managedRosterObjectContext]];
    NSString *body = [[message elementForName:@"body"] stringValue];
    
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    KXMessage *msg = [NSEntityDescription insertNewObjectForEntityForName:@"KXMessage" inManagedObjectContext:context];
    msg.contactAvatar = DEFAULT_AVATAR_NAME;
    if (contact.nickname != nil) {
        msg.contactName = contact.nickname;
    } else {
        msg.contactName = [[contact jid] user];
    }
    msg.messageContent = body;
    msg.messageReceivedTime = [NSDate date];
    msg.messageType = @"incoming";
    [context insertObject:msg];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Data not inserted. %@, %@", error, [error userInfo]);
        return;
    }
    [self.messages addObject:msg];
    [self.tableView reloadData];
    [self scrollTableView];
}

@end
