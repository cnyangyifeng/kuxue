//
//  KXContact.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/14/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXContact.h"

@implementation KXContact

@dynamic avatar;
@dynamic nickname;
@dynamic theme;
@dynamic userId;

- (NSString *)getSortableName
{
    if ([self.nickname canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return self.nickname;
    } else {
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([self.nickname characterAtIndex:0])];
    }
}

@end
