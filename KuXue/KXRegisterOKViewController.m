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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)startButtonTapped:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KXMainTabBarController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"KXMainTabBarController"];
    [self presentViewController:mainTabBarController animated:YES completion:nil];
}

@end
