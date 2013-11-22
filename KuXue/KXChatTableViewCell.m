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
@synthesize messageContentLabel = _messageContentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, 32.0f, 32.0f)];
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(54.0f, 6.0f, 192.0f, 32.0f)];
        lb.backgroundColor = [UIColor whiteColor];
        [lb setFont:[UIFont systemFontOfSize:15.0f]];
        
        self.contactAvatarImageView = iv;
        [self addSubview:iv];
        
        self.messageContentLabel = lb;
        [self addSubview:lb];
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
