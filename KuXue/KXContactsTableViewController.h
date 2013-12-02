//
//  KXContactsViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/12/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXAppDelegate.h"
#import "KXChatDelegate.h"
#import "KXContactsTableViewCell.h"
#import "KXContactTableViewController.h"
#import "KXContact.h"
#import "XMPP.h"
#import "XMPPRoster.h"

@interface KXContactsTableViewController : UITableViewController <KXChatDelegate>

@property (strong, nonatomic) NSMutableArray *contacts;

@end
