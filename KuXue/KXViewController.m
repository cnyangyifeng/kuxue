//
//  KXViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 12/9/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXViewController.h"

@interface KXViewController ()

@end

@implementation KXViewController

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
    [[self appDelegate] setRegisterEnabled:NO];
    [[self appDelegate] setHomeEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Application Delegate

- (KXAppDelegate *)appDelegate
{
    return (KXAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
