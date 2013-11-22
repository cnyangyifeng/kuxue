//
//  KXContactTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/17/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXContactHeaderTableViewCell.h"
#import "KXContactTableViewCell.h"
#import "KXChatViewController.h"
#import "KXIdea.h"

@interface KXContactTableViewController : UITableViewController

@property (strong, nonatomic) NSString *theme;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *contactAvatar;

@property (strong, nonatomic) NSMutableArray *ideas;

@end
