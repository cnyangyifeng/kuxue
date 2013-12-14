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
@synthesize loginButton = _loginButton;

@synthesize progressHud = _progressHud;

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
    
    [[self appDelegate] setAuthenticationDelegate:self];
    
    [self initUserIdTextField];
    [self initPasswordTextField];
    [self initLoginButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    KXUser *usr = [[self appDelegate] user];
    if (usr != nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading...";
        
        self.progressHud = hud;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initializations

- (void)initUserIdTextField
{
    UIView *userIdTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.userIdTextField.frame.size.height)];
    self.userIdTextField.leftView = userIdTextFieldPadding;
    self.userIdTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)initPasswordTextField
{
    UIView *passwordTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.passwordTextField.frame.size.height)];
    self.passwordTextField.leftView = passwordTextFieldPadding;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)initLoginButton
{
    UIImage *loginButtonImage = [[UIImage imageNamed:@"BlueButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    UIImage *loginHighlightedButtonImage = [[UIImage imageNamed:@"BlueButtonHighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    
    [self.loginButton setBackgroundImage:loginButtonImage forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.loginButton setBackgroundImage:loginHighlightedButtonImage forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.loginButton setBackgroundImage:loginHighlightedButtonImage forState:UIControlStateSelected];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

#pragma mark - Navigation

- (IBAction)login:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    
    if (tf.tag == 1) {
        // If is userIdTextField,
        [self.passwordTextField becomeFirstResponder];
    } else {
        // else is passwordTextField.
        [sender resignFirstResponder];
        
        [self doLogin];
    }
}

- (IBAction)loginButtonTapped:(id)sender
{
    if ([self.userIdTextField isFirstResponder]) {
        [self.userIdTextField resignFirstResponder];
    }
    if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
    
    [self doLogin];
}

- (void)doLogin
{
    [self saveUserToLocalStorage];
    [[self appDelegate] loadUserFromLocalStorage];
    [[self appDelegate] connect];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    
    self.progressHud = hud;
}

- (void)saveUserToLocalStorage
{
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
    
    KXUser *usr = [NSEntityDescription insertNewObjectForEntityForName:@"KXUser" inManagedObjectContext:context];
    [usr setValue:@"new_yorker.jpg" forKey:@"avatar"];
    [usr setValue:self.userIdTextField.text forKey:@"nickname"];
    [usr setValue:self.passwordTextField.text forKey:@"password"];
    [usr setValue:self.userIdTextField.text forKey:@"userId"];
    
    if (![context save:&error]) {
        NSLog(@"Data not inserted. %@, %@", error, [error userInfo]);
        return;
    }
}

- (void)userAuthenticated
{
    NSLog(@"Callback: User authenticated.");
    
    [self.progressHud hide:YES];
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}

- (void)userNotAuthenticated
{
    NSLog(@"Callback: User not authenticated.");
    
    [self.progressHud hide:YES];
}

@end
