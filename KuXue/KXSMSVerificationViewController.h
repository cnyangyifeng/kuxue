//
//  KXSMSVerificationViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 1/11/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "KXLoginViewController.h"
#import "KXSMSVerificationDelegate.h"
#import "KXViewController.h"

#define LOGIN_BUTTON_HEIGHT 50.0f

@interface KXSMSVerificationViewController : KXViewController <KXSMSVerificationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) UIButton *loginButton;

@property (weak, nonatomic) MBProgressHUD *progressHud;

@property (strong, nonatomic) NSString *userId;

- (IBAction)textFieldDidEndOnExit:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;

@end
