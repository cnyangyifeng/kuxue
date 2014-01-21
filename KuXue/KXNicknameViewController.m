//
//  KXNicknameViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 1/13/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import "KXNicknameViewController.h"

@interface KXNicknameViewController ()

@end

@implementation KXNicknameViewController

@synthesize nicknameTextField = _nicknameTextField;
@synthesize saveButton = _saveButton;

@synthesize nickname = _nickname;

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
    [[self appDelegate] setNicknameDelegate:self];
    [self initNicknameTextField];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    self.nicknameTextField.text = self.nickname;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nicknameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.nicknameTextField becomeFirstResponder];
}

#pragma mark - Initializations

- (void)initNicknameTextField
{
    UIView *userIdTextFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, self.nicknameTextField.frame.size.height)];
    self.nicknameTextField.leftView = userIdTextFieldPadding;
    self.nicknameTextField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - Navigations

- (IBAction)textFieldDidEndOnExit:(id)sender
{
    [self dismissKeyboard];
    [self saveNickname];
}

- (IBAction)saveButtonTapped:(id)sender
{
    [self dismissKeyboard];
    [self saveNickname];
}

#pragma mark - Save Nickname

- (void)saveNickname
{
    XMPPvCardTemp *xmppvCardTemp = [[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    if (xmppvCardTemp != nil) {
        [xmppvCardTemp setNickname:self.nicknameTextField.text];
        [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:xmppvCardTemp];
    } else {
        NSXMLElement *vCardElement = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
        NSXMLElement *nicknameElement = [NSXMLElement elementWithName:@"nickname" stringValue:self.nicknameTextField.text];
        [vCardElement addChild:nicknameElement];
        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardElement];
        [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:newvCardTemp];
    }
    [self showProgressHud];
    [self hideProgressHud:PROGRESS_TIME_IN_SECONDS];
}

#pragma mark - KXNicknameDelegate

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    NSLog(@"KXNicknameDelegate callback: xmpp vcard temp module did update my vcard.");
    [self hideProgressHud:0.0f];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)failedToUpdateMyvCard:(NSXMLElement *)error
{
    NSLog(@"KXNicknameDelegate callback: failed to update my vcard.");
    [self hideProgressHud:0.0f];
}

#pragma mark - Private Methods

- (void)dismissKeyboard
{
    if ([self.nicknameTextField isFirstResponder]) {
        [self.nicknameTextField resignFirstResponder];
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
