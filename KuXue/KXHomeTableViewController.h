//
//  KXHomeTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/12/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXContactTableViewController.h"
#import "KXHomeDelegate.h"
#import "KXHomeTableViewCell.h"
#import "KXMessage.h"
#import "KXTableViewController.h"

@interface KXHomeTableViewController : KXTableViewController <KXHomeDelegate>

@property (strong, nonatomic) NSMutableArray *conversations;

@end
