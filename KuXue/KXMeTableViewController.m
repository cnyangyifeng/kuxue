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
    
    self.avatarImageView.image = [UIImage imageNamed:@"liukun.jpg"];
    self.nicknameLabel.text = [[[self appDelegate] user] nickname];
    
    UIImage *logoutButtonImage = [[UIImage imageNamed:@"OrangeButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    UIImage *logoutHighlightedButtonImage = [[UIImage imageNamed:@"OrangeButtonHighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    
    [self.logoutButton setBackgroundImage:logoutButtonImage forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.logoutButton setBackgroundImage:logoutHighlightedButtonImage forState:UIControlStateHighlighted];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.logoutButton setBackgroundImage:logoutHighlightedButtonImage forState:UIControlStateSelected];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"logoutSegue"]) {
        [[self appDelegate] disconnect];
        [[self appDelegate] signOutUser];
        
        // Deletes user from local storage.
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXUser"];
        [request setIncludesPropertyValues:NO];
        NSArray *users = [context executeFetchRequest:request error:nil];
        for (NSManagedObject *obj in users) {
            [context deleteObject:obj];
        }
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Data not deleted. %@, %@", error, [error userInfo]);
            return;
        }
    }
}

@end
