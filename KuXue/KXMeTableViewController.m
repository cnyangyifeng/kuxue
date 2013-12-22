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
    
    [self initLogoutButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initUserProfile];
    [self.view setNeedsDisplay];
}

#pragma mark - Initializations

- (void)initUserProfile
{
    self.avatarImageView.image = [[[self appDelegate] user] photo];
    self.nicknameLabel.text = [[[self appDelegate] user] displayName];
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"jid"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
        [[self appDelegate] disconnect];
    }
}

@end
