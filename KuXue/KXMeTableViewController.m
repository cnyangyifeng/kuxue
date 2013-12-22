//
//  KXMeTableViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 12/10/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXMeTableViewController.h"

@interface KXMeTableViewController ()

@end

@implementation KXMeTableViewController

@synthesize avatarImageView = _avatarImageView;
@synthesize nicknameLabel = _nicknameLabel;
@synthesize logoutButton = _logoutButton;

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
    
    CGRect frame = self.tableView.frame;
    frame.origin.x += 10.0f;
    frame.origin.y += 10.0f;
    frame.size.width -= 20.0f;
    frame.size.height -= 10.0f;
    self.tableView.frame = frame;
    
    [self initUserProfile];
    [self initLogoutButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initializations

- (void)initUserProfile
{
//    KXUser *usr = [[self appDelegate] lastActivateUser];
//    self.avatarImageView.image = [UIImage imageNamed:usr.avatar];
//    self.nicknameLabel.text = usr.nickname;
}

- (void)initLogoutButton
{
    // UIImage *logoutButtonImage = [[UIImage imageNamed:@"OrangeButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    // UIImage *logoutHighlightedButtonImage = [[UIImage imageNamed:@"OrangeButtonHighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    
    // [self.logoutButton setBackgroundImage:logoutButtonImage forState:UIControlStateNormal];
    // [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // [self.logoutButton setBackgroundImage:logoutHighlightedButtonImage forState:UIControlStateHighlighted];
    // [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    // [self.logoutButton setBackgroundImage:logoutHighlightedButtonImage forState:UIControlStateSelected];
    // [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"logoutSegue"]) {
        [[self appDelegate] disconnect];
    }
}

@end
