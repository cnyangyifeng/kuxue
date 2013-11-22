//
//  KXContact.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/14/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXContact.h"

@implementation KXContact

@dynamic contactAvatar;
@dynamic contactName;
@dynamic mobile;
@dynamic theme;

- (NSString *)getSortableName
{
    if ([self.contactName canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return self.contactName;
    } else {
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([self.contactName characterAtIndex:0])];
    }
}

@end
