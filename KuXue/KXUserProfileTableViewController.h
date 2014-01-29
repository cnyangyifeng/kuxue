//
//  KXUserProfileTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/15/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXNicknameTableViewController.h"
#import "KXTableViewController.h"
#import "KXUserProfileDelegate.h"

@interface KXUserProfileTableViewController : KXTableViewController <KXUserProfileDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@end
