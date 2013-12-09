//
//  KXLoginViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/4/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXViewController.h"

@interface KXLoginViewController : KXViewController

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)login:(id)sender;

@end
