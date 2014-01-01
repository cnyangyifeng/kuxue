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
    
    [[self appDelegate] setMeDelegate:self];
    
    self.avatarImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_NAME];
    self.nicknameLabel.text = @"Anonymous";
    [self initLogoutButton];
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

#pragma mark - Initializations

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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"jid"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
        [[self appDelegate] disconnect];
    } else if ([segue.identifier isEqualToString:@"pushUserProfileFromMe"]) {
        KXTableViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - KXMeDelegate

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
}

@end
