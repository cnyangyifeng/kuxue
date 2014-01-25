//
//  KXMeTableViewCell.m
//  KuXue
//
//  Created by Yang Yi Feng on 1/2/14.
//  Copyright (c) 2014 kuxue.me. All rights reserved.
//

#import "KXMeTableViewCell.h"

@implementation KXMeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setFrame:(CGRect)frame
{
    // frame.origin.x += 5;
    // frame.size.width -= 10;
    [super setFrame:frame];
}

@end
