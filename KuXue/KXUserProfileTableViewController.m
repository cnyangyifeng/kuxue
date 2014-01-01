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
    
    self.avatarImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_NAME];
    self.nicknameLabel.text = @"Anonymous";
    self.userIdLabel.text = @"Anonymous";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self appDelegate] fetchMyUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - KXUserProfileDelegate

- (void)didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
{
    if (vCardTemp.photo != nil) {
        self.avatarImageView.image = [UIImage imageWithData:vCardTemp.photo];
    } else {
        self.avatarImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_NAME];
    }
    if (vCardTemp.nickname != nil) {
        self.nicknameLabel.text = vCardTemp.nickname;
    } else {
        self.nicknameLabel.text = [[vCardTemp jid] user];
    }
    self.userIdLabel.text = [[vCardTemp jid] user];
}

@end
