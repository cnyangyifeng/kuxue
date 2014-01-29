//
//  KXUserProfileTableViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 12/15/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXUserProfileTableViewController.h"

@interface KXUserProfileTableViewController ()

@end

@implementation KXUserProfileTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self appDelegate] setUserProfileDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    XMPPvCardTemp *vCardTemp = [[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    [self showUserInfo:vCardTemp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushNicknameFromUserProfile"]) {
        KXNicknameTableViewController *nicknameController = segue.destinationViewController;
        nicknameController.nickname = self.nicknameLabel.text;
    }
}

#pragma mark - KXUserProfileDelegate

- (void)didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
{
    NSLog(@"KXUserProfileDelegate callback: did receive vcard temp.");
}

#pragma mark - Private Methods

- (void)showUserInfo:(XMPPvCardTemp *)vCardTemp
{
    if (vCardTemp.photo != nil) {
        self.avatarImageView.image = [UIImage imageWithData:vCardTemp.photo];
    } else {
        self.avatarImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_NAME];
    }
    if (vCardTemp.nickname != nil) {
        self.nicknameLabel.text = vCardTemp.nickname;
    } else if (vCardTemp.jid != nil) {
        self.nicknameLabel.text = [[vCardTemp jid] user];
    } else {
        self.nicknameLabel.text = [[[[self appDelegate] xmppStream] myJID] user];
    }
    if (vCardTemp.jid != nil) {
        self.userIdLabel.text = [[vCardTemp jid] user];
    } else {
        self.userIdLabel.text = [[[[self appDelegate] xmppStream] myJID] user];
    }
}

@end
