//
//  KXNicknameViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 1/13/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "KXNicknameDelegate.h"
#import "KXViewController.h"

@interface KXNicknameViewController : KXViewController <MBProgressHUDDelegate, KXNicknameDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) MBProgressHUD *progressHud;

@property (strong, nonatomic) NSString *nickname;

- (IBAction)textFieldDidEndOnExit:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end
