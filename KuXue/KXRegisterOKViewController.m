//
//  KXRegisterOKViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 1/12/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import "KXRegisterOKViewController.h"

@interface KXRegisterOKViewController ()

@end

@implementation KXRegisterOKViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self appDelegate] setLoginEnabled:NO];
    [[self appDelegate] setRegisterEnabled:YES];
    [[self appDelegate] setHomeEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)startButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"modalMainFromRegisterOK" sender:nil];
}

@end
