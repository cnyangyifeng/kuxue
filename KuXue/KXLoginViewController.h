//
//  KXLoginViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/4/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "KXLoginDelegate.h"
#import "KXRegisterNavigationController.h"
#import "KXViewController.h"

#define REGISTER_BUTTON_HEIGHT 50.0f

@interface KXLoginViewController : KXViewController <MBProgressHUDDelegate, KXLoginDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) UIButton *registerButton;

@property (weak, nonatomic) MBProgressHUD *progressHud;

- (IBAction)textFieldDidEndOnExit:(id)sender;
- (IBAction)loginButtonTapped:(id)sender;

@end
