//
//  KXTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/9/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXAppDelegate.h"
#import "XMPP.h"

@interface KXTableViewController : UITableViewController

- (NSManagedObjectContext *)managedObjectContext;

- (KXAppDelegate *)appDelegate;

- (XMPPStream *)xmppStream;

@end
