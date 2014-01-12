//
//  KXRegisterViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 1/11/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import "KXRegisterViewController.h"

@interface KXRegisterViewController ()

@end

@implementation KXRegisterViewController

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
    
    [[self appDelegate] setRegisterDelegate:self];
    
    [self initUserIdTextField];
    [self initLoginButton];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
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

#pragma mark - Initializations

- (void)initUserIdTextField
{
    UIView *userIdTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.userIdTextField.frame.size.height)];
    self.userIdTextField.leftView = userIdTextFieldPadding;
    self.userIdTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.userIdTextField becomeFirstResponder];
}

- (void)initLoginButton
{
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton setFrame:CGRectMake(0.0f, self.view.bounds.size.height - REGISTER_BUTTON_HEIGHT, self.view.bounds.size.width, LOGIN_BUTTON_HEIGHT)];
    [bottomButton setBackgroundColor:[UIColor whiteColor]];
    [bottomButton setTitle:@"Sign in" forState:UIControlStateNormal];
    [bottomButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [bottomButton.titleLabel setFont:[UIFont systemFontOfSize:DEFAULT_FONT_SIZE]];
    [bottomButton addTarget:self action:@selector(loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginButton = bottomButton;
    [self.view addSubview:self.loginButton];
}

#pragma mark - Navigations

- (IBAction)textFieldDidEndOnExit:(id)sender
{
    [self dismissKeyboard];
    [self connect];
}

- (IBAction)nextButtonTapped:(id)sender
{
    [self dismissKeyboard];
    [self connect];
}

- (void)loginButtonTapped
{
    [self performSegueWithIdentifier:@"modalLoginFromRegister" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushSMSVerificationFromRegister"]) {
        KXSMSVerificationViewController *smsVerificationController = segue.destinationViewController;
        smsVerificationController.userId = self.userIdTextField.text;
    }
}

#pragma mark - Connection

- (void)connect
{
    /* Disconnects */
    [[self appDelegate] disconnect];
    /* Connects */
    NSString *myJid = [self.userIdTextField.text stringByAppendingFormat:@"%@%@", @"@", XMPP_HOST_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:myJid forKey:@"jid"];
    [[NSUserDefaults standardUserDefaults] setObject:DEFAULT_PASSWORD forKey:@"password"];
    [[self appDelegate] connect];
    [self showProgressHud];
    [self hideProgressHud:PROGRESS_TIME_IN_SECONDS];
}

#pragma mark - KXRegisterDelegate

- (void)xmppStreamDidConnect
{
    NSLog(@"KXRegisterDelegate callback: xmpp stream did connect.");
    [self hideProgressHud:0.0f];
    [self performSegueWithIdentifier:@"pushSMSVerificationFromRegister" sender:nil];
}

- (void)xmppStreamDidDisconnect
{
    NSLog(@"KXRegisterDelegate callback: xmpp stream did disconnect.");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"jid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [self hideProgressHud:0.0f];
}

#pragma mark - Private Methods

- (void)dismissKeyboard
{
    if ([self.userIdTextField isFirstResponder]) {
        [self.userIdTextField resignFirstResponder];
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
