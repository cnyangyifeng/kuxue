//
//  KXContactTableViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/17/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXChatViewController.h"
#import "KXContactHeaderTableViewCell.h"
#import "KXContactTableViewCell.h"
#import "KXIdea.h"
#import "KXTableViewController.h"

@interface KXContactTableViewController : KXTableViewController

@property (strong, nonatomic) NSString *theme;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *contactAvatar;

@property (strong, nonatomic) KXContact *contact;

@property (strong, nonatomic) NSMutableArray *ideas;

@end
