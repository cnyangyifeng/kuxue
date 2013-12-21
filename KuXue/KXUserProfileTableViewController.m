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
    
    KXUser *usr = [[self appDelegate] lastActivateUser];
    self.avatarImageView.image = [UIImage imageNamed:usr.avatar];
    self.nicknameLabel.text = usr.nickname;
    self.userIdLabel.text = usr.userId;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
