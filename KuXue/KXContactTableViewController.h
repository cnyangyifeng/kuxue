//
//  KXContactTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/17/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXChatViewController.h"
#import "KXContactTableViewCell.h"
#import "KXTableViewController.h"

@interface KXContactTableViewController : KXTableViewController

@property (weak, nonatomic) IBOutlet UIImageView *contactAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@property (strong, nonatomic) XMPPUserCoreDataStorageObject *contact;

- (IBAction)pushChatViewController:(id)sender;

@end
