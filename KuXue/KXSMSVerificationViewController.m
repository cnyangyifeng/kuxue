//
//  KXSMSVerificationViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 1/11/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import "KXSMSVerificationViewController.h"

@interface KXSMSVerificationViewController ()

@end

@implementation KXSMSVerificationViewController

@synthesize loginButton = _loginButton;

@synthesize progressHud = _progressHud;

@synthesize userId = _userId;

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
    
    [[self appDelegate] setSmsVerificationDelegate:self];
    
    [self initVerificationCodeTextField];
    [self initLoginButton];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initializations

- (void)initVerificationCodeTextField
{
    UIView *verificationCodeTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.verificationCodeTextField.frame.size.height)];
    self.verificationCodeTextField.leftView = verificationCodeTextFieldPadding;
    self.verificationCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.verificationCodeTextField becomeFirstResponder];
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
    [self.verificationCodeTextField resignFirstResponder];
    [self loginWithUserId:self.userId password:self.verificationCodeTextField.text];
}

- (IBAction)nextButtonTapped:(id)sender
{
    [self dismissKeyboard];
    [self loginWithUserId:self.userId password:self.verificationCodeTextField.text];
}

#pragma mark - Login

- (void)loginWithUserId:(NSString *)userId password:(NSString *)password
{
    NSString *myJid = [self.userId stringByAppendingFormat:@"%@%@", @"@", XMPP_HOST_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:myJid forKey:@"jid"];
    [[NSUserDefaults standardUserDefaults] setObject:self.verificationCodeTextField.text forKey:@"password"];
    [[self appDelegate] connect:NO];
    [self showProgressHud];
    [self hideProgressHud:PROGRESS_TIME_IN_SECONDS];
}

- (void)loginButtonTapped
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KXLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"KXLoginViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

#pragma mark - KXSMSVerificationDelegate

- (void)didAuthenticate
{
    NSLog(@"KXSMSVerificationDelegate callback: User did authenticated.");
    [self hideProgressHud:0.0f];
    [self performSegueWithIdentifier:@"pushRegisterOKFromSMSVerification" sender:nil];
}

- (void)didNotAuthenticate
{
    NSLog(@"KXSMSVerificationDelegate callback: User did not authenticated.");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"jid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[self appDelegate] disconnect];
    [self hideProgressHud:0.0f];
}

#pragma mark - Private Methods

- (void)dismissKeyboard
{
    if ([self.verificationCodeTextField isFirstResponder]) {
        [self.verificationCodeTextField resignFirstResponder];
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
