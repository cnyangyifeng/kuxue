//
//  KXRegisterViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 1/11/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import "KXLoginViewController.h"
#import "KXSMSVerificationViewController.h"
#import "KXViewController.h"

#define LOGIN_BUTTON_HEIGHT 50.0f

@interface KXRegisterViewController : KXViewController

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) UIButton *loginButton;

@end
