//
//  KXMessageDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/1/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@protocol KXMessageDelegate <NSObject>

@required

- (void)newMessageReceived:(XMPPMessage *)message;

@end
