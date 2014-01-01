//
//  KXMeTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/10/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXTableViewController.h"
#import "KXMeDelegate.h"

@interface KXMeTableViewController : KXTableViewController <KXMeDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end
