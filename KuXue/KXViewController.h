//
//  KXViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/9/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXAppDelegate.h"
#import "constants.h"

@interface KXViewController : UIViewController

- (NSManagedObjectContext *)managedObjectContext;

- (KXAppDelegate *)appDelegate;

@end
