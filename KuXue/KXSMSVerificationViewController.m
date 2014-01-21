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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self appDelegate] setLoginEnabled:NO];
    [[self appDelegate] setRegisterEnabled:YES];
    [[self appDelegate] setHomeEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.verificationCodeTextField becomeFirstResponder];
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

- (IBAction)verifyButtonTapped:(id)sender
{
    self.verificationCodeTextField.text = @"860110";
}

- (IBAction)textFieldDidEndOnExit:(id)sender
{
    [self dismissKeyboard];
    [self register];
}

- (IBAction)nextButtonTapped:(id)sender
{
    [self dismissKeyboard];
    [self register];
}

- (void)loginButtonTapped
{
    [self performSegueWithIdentifier:@"modalLoginFromSMSVerification" sender:nil];
}

#pragma mark - Registration

- (void)register
{
    /* Registers */
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:self.userId]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:self.verificationCodeTextField.text]];
    if ([[[self appDelegate] xmppStream] isDisconnected]) {
        NSLog(@"Connection lost. Reconnects.");
        [[self appDelegate] connect];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PROGRESS_SHORT_TIME_IN_SECONDS * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[self appDelegate] registerWithElements:elements];
        });
    } else {
        [[self appDelegate] registerWithElements:elements];
    }
    /* Updates vCard */
    NSXMLElement *vCardElement = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    NSXMLElement *nicknameElement = [NSXMLElement elementWithName:@"nickname" stringValue:self.userId];
    [vCardElement addChild:nicknameElement];
    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardElement];
    [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:newvCardTemp];
    /* Shows the progress hud */
    [self showProgressHud];
    [self hideProgressHud:PROGRESS_TIME_IN_SECONDS];
}

#pragma mark - KXSMSVerificationDelegate

- (void)xmppStreamDidRegister
{
    NSLog(@"KXSMSVerificationDelegate callback: xmpp stream did register.");
    /* Authenticates */
    NSError *error = nil;
    if (![[[self appDelegate] xmppStream] authenticateWithPassword:self.verificationCodeTextField.text error:&error]) {
        NSLog(@"XMPP stream authenticate with password error.");
    }
}

- (void)didNotRegister
{
    NSLog(@"KXSMSVerificationDelegate callback: did not register.");
    [self hideProgressHud:0.0f];
}

- (void)xmppStreamDidAuthenticate
{
    NSLog(@"KXSMSVerificationDelegate callback: xmpp stream did authenticate.");
    [self hideProgressHud:0.0f];
    [self performSegueWithIdentifier:@"pushRegisterOKFromSMSVerification" sender:nil];
}

- (void)didNotAuthenticate
{
    NSLog(@"KXSMSVerificationDelegate callback: did not authenticate.");
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
