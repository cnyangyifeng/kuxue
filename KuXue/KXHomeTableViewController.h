//
//  KXHomeTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/12/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXContactTableViewController.h"
#import "KXHomeTableViewCell.h"
#import "KXIdea.h"
#import "KXTableViewController.h"

@interface KXHomeTableViewController : KXTableViewController

@property (strong, nonatomic) NSMutableArray *ideas;

@end
