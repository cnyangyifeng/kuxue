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
    [[self appDelegate] setLoginDelegate:self];
    [self initUserIdTextField];
    [self initPasswordTextField];
    [self initLoginButton];
    [self initRegisterButton];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self appDelegate] setLoginEnabled:YES];
    [[self appDelegate] setRegisterEnabled:NO];
    [[self appDelegate] setHomeEnabled:NO];
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
    // UIImage *loginButtonImage = [[UIImage imageNamed:@"BlueButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    // UIImage *loginHighlightedButtonImage = [[UIImage imageNamed:@"BlueButtonHighlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(32.0f, 32.0f, 32.0f, 32.0f)];
    
    // [self.loginButton setBackgroundImage:loginButtonImage forState:UIControlStateNormal];
    // [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // [self.loginButton setBackgroundImage:loginHighlightedButtonImage forState:UIControlStateHighlighted];
    // [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    // [self.loginButton setBackgroundImage:loginHighlightedButtonImage forState:UIControlStateSelected];
    // [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

- (void)initRegisterButton
{
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton setFrame:CGRectMake(0.0f, self.view.bounds.size.height - REGISTER_BUTTON_HEIGHT, self.view.bounds.size.width, REGISTER_BUTTON_HEIGHT)];
    [bottomButton setBackgroundColor:[UIColor whiteColor]];
    [bottomButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [bottomButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [bottomButton.titleLabel setFont:[UIFont systemFontOfSize:DEFAULT_FONT_SIZE]];
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
        [self connect];
    }
}

- (IBAction)loginButtonTapped:(id)sender
{
    [self dismissKeyboard];
    [self connect];
}

- (void)registerButtonTapped
{
    [self performSegueWithIdentifier:@"modalRegisterFromLogin" sender:nil];
}

#pragma mark - Connection

- (void)connect
{
    /* Disconnects */
    [[self appDelegate] disconnect];
    /* Connects */
    NSString *myJid = [self.userIdTextField.text stringByAppendingFormat:@"%@%@", @"@", XMPP_HOST_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:myJid forKey:@"jid"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"password"];
    [[self appDelegate] connect];
    [self showProgressHud];
    [self hideProgressHud:PROGRESS_TIME_IN_SECONDS];
}

#pragma mark - KXLoginDelegate

- (void)xmppStreamDidAuthenticate
{
    NSLog(@"KXLoginDelegate callback: xmpp stream did authenticate.");
    [self hideProgressHud:0.0f];
    [self performSegueWithIdentifier:@"presentMainFromLogin" sender:nil];
}

- (void)didNotAuthenticate
{
    NSLog(@"KXLoginDelegate callback: did not authenticate.");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"jid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[self appDelegate] disconnect];
    [self hideProgressHud:0.0f];
}

#pragma mark - Private Methods

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
