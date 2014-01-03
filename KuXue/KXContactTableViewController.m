//
//  KXContactTableViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/17/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXContactTableViewController.h"

@interface KXContactTableViewController ()

@end

@implementation KXContactTableViewController

@synthesize contactAvatarImageView = _contactAvatarImageView;
@synthesize contactNameLabel = _contactNameLabel;
@synthesize messageButton = _messageButton;
@synthesize summaryLabel = _summaryLabel;

@synthesize contact = _contact;

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
    [self initTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initializations

- (void)initTableView
{
    if (self.contact.photo != nil) {
        self.contactAvatarImageView.image = self.contact.photo;
    } else {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:self.contact.jid];
        if (photoData != nil) {
            self.contactAvatarImageView.image = [UIImage imageWithData:photoData];
        } else {
            self.contactAvatarImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_NAME];
        }
    }
    if (self.contact.nickname != nil) {
        self.contactNameLabel.text = self.contact.nickname;
    } else {
        self.contactNameLabel.text = [[self.contact jid] user];
    }
}

#pragma mark - Navigations

- (IBAction)pushChatViewController:(id)sender
{
    KXChatViewController *chatViewController = [[KXChatViewController alloc] init];
    chatViewController.contact = self.contact;
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

@end
