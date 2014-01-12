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
    
    [self initUserIdTextField];
    [self initLoginButton];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushSMSVerificationFromRegister"]) {
        // TODO: Checks if jid exists.
        KXSMSVerificationViewController *smsVerificationController = segue.destinationViewController;
        smsVerificationController.userId = self.userIdTextField.text;
    }
}

- (void)loginButtonTapped
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KXLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"KXLoginViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)dismissKeyboard
{
    if ([self.userIdTextField isFirstResponder]) {
        [self.userIdTextField resignFirstResponder];
    }
}

@end
