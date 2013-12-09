//
//  KXLoginViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 12/4/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXLoginViewController.h"

@interface KXLoginViewController ()

@end

@implementation KXLoginViewController

@synthesize userIdTextField = _userIdTextField;
@synthesize passwordTextField = _passwordTextField;

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
    
    UIView *userIdTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.userIdTextField.frame.size.height)];
    self.userIdTextField.leftView = userIdTextFieldPadding;
    self.userIdTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.userIdTextField becomeFirstResponder];
    
    UIView *passwordTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.passwordTextField.frame.size.height)];
    self.passwordTextField.leftView = passwordTextFieldPadding;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.userIdTextField.text = @"";
    self.passwordTextField.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (IBAction)login:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    
    if (tf.tag == 1) {
        // If is userIdTextField.
        [self.passwordTextField becomeFirstResponder];
    } else {
        [sender resignFirstResponder];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSManagedObject *usr = [NSEntityDescription insertNewObjectForEntityForName:@"KXUser" inManagedObjectContext:context];
        [usr setValue:@"new_yorker.jpg" forKey:@"avatar"];
        [usr setValue:self.userIdTextField.text forKey:@"nickname"];
        [usr setValue:self.passwordTextField.text forKey:@"password"];
        [usr setValue:self.userIdTextField.text forKey:@"userId"];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Data not inserted. %@, %@", error, [error userInfo]);
            return;
        }
        
        [[self appDelegate] connect];
        
        [self performSegueWithIdentifier:@"loginSegue" sender:sender];
    }
}

@end
