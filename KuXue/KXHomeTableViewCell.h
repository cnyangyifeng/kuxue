//
//  KXHomeTableViewCell.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/12/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KXHomeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contactAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTimestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

@end
