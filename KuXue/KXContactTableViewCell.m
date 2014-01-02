//
//  KXContactTableViewCell.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/17/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXContactTableViewCell.h"

@implementation KXContactTableViewCell

@synthesize ideaThumbnailImageView = _ideaThumbnailImageView;
@synthesize ideaTitleLabel = _ideaTitleLabel;

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
    frame.origin.x += 5;
    frame.size.width -= 10;
    [super setFrame:frame];
}

@end
