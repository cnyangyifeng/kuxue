//
//  KXChatTableViewCell.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/20/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXChatTableViewCell.h"

@implementation KXChatTableViewCell

@synthesize contactAvatarImageView = _contactAvatarImageView;
@synthesize messageBackgroundImageView = _messageBackgroundImageView;
@synthesize messageContentLabel = _messageContentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UILabel *msgLabel = [[UILabel alloc] init];
        msgLabel.backgroundColor = [UIColor clearColor];
        msgLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:avatarImageView];
        [self.contentView addSubview:bgImageView];
        [self.contentView addSubview:msgLabel];
        
        self.contactAvatarImageView = avatarImageView;
        self.messageBackgroundImageView = bgImageView;
        self.messageContentLabel = msgLabel;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.x += 10;
    frame.origin.y += 10;
    frame.size.width -= 20;
    frame.size.height -= 10;
    [super setFrame:frame];
}

@end
