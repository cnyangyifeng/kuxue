//
//  KXChatTableViewCell.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/20/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KXChatTableViewCell : UITableViewCell

@property (weak, nonatomic) UIImageView *contactAvatarImageView;
@property (weak, nonatomic) UIImageView *messageBackgroundImageView;
@property (weak, nonatomic) UILabel *messageContentLabel;

@end
