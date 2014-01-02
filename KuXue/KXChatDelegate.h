//
//  KXChatDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/22/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@protocol KXChatDelegate <NSObject>

@required

- (void)didReceiveMessage:(XMPPMessage *)message;
- (void)didSendMessage:(XMPPMessage *)message;

@end
