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
@synthesize asGuestButton = _asGuestButton;
@synthesize registerButton = _registerButton;

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
    [self initAsGuestButton];
    [self initRegisterButton];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    self.userIdTextField.keyboardType = UIKeyboardTypeAlphabet;
}

- (void)initPasswordTextField
{
    UIView *passwordTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.passwordTextField.frame.size.height)];
    self.passwordTextField.leftView = passwordTextFieldPadding;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)initLoginButton
{
    // UIImage *loginButtonImage = [[UIImage imageNamed:@"BlueButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    // UIImage *loginHighlightedButtonImage = [[UIImage imageNamed:@"BlueButtonHighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    
    // [self.loginButton setBackgroundImage:loginButtonImage forState:UIControlStateNormal];
    // [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // [self.loginButton setBackgroundImage:loginHighlightedButtonImage forState:UIControlStateHighlighted];
    // [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    // [self.loginButton setBackgroundImage:loginHighlightedButtonImage forState:UIControlStateSelected];
    // [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

- (void)initAsGuestButton
{
}

- (void)initRegisterButton
{
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton setFrame:CGRectMake(0.0f, self.view.bounds.size.height - REGISTER_BUTTON_HEIGHT, self.view.bounds.size.width, REGISTER_BUTTON_HEIGHT)];
    [bottomButton setBackgroundColor:[UIColor whiteColor]];
    [bottomButton setTitle:@"Register" forState:UIControlStateNormal];
    [bottomButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [bottomButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [bottomButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.registerButton = bottomButton;
    [self.view addSubview:self.registerButton];
}

#pragma mark - Navigations

- (IBAction)textFieldDidEndOnExit:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    
    if (tf.tag == 1) {
        // If is userIdTextField,
        [self.passwordTextField becomeFirstResponder];
    } else {
        // else is passwordTextField.
        [sender resignFirstResponder];
        [self loginWithUserId:self.userIdTextField.text password:self.passwordTextField.text];
    }
}

- (IBAction)loginButtonTapped:(id)sender
{
    NSLog(@"Login button tapped.");
    [self dismissKeyboard];
    [self loginWithUserId:self.userIdTextField.text password:self.passwordTextField.text];
}

- (IBAction)asGuestButtonTapped:(id)sender
{
    NSLog(@"As guest button tapped.");
    
    [self dismissKeyboard];
    
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXUser"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId==%@", GUEST_ID];
//    [request setPredicate:predicate];
//    [request setFetchLimit:1];
    // KXUser *usr = (KXUser *)[[[context executeFetchRequest:request error:nil] mutableCopy] objectAtIndex:0];
    
    // [self loginWithUserId:usr.userId password:usr.password];
}

- (void)registerButtonTapped
{
    NSLog(@"Register button tapped.");
}

#pragma mark - Login

- (void)loginWithUserId:(NSString *)userId password:(NSString *)password
{
    [[self appDelegate] setTempUserId:userId];
    [[self appDelegate] setTempPassword:password];
    
    [[self appDelegate] connect:NO];
    
    [self showProgressHud];
    [self hideProgressHud:10.0f];
}

#pragma mark - Authentication Delegate

- (void)userAuthenticated
{
    NSLog(@"Callback: User authenticated.");
    
    [self.progressHud hide:YES];
    // [[self appDelegate] saveLastActiveUser];
    // [[self appDelegate] loadLastActiveUser];
    [self performSegueWithIdentifier:@"presentMainFromLogin" sender:nil];
}

- (void)userNotAuthenticated
{
    NSLog(@"Callback: User not authenticated.");
    
    [self.progressHud hide:YES];
    [[self appDelegate] setTempUserId:@""];
    [[self appDelegate] setTempPassword:@""];
}

#pragma mark - Private Utilities

- (void)dismissKeyboard
{
    if ([self.userIdTextField isFirstResponder]) {
        [self.userIdTextField resignFirstResponder];
    }
    if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}

- (void)showProgressHud
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    hud.color = [UIColor clearColor];
    self.progressHud = hud;
}

- (void)hideProgressHud:(double)delayInSeconds
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.progressHud hide:YES];
    });
}

@end
