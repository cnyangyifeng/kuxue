//
//  KXMessageDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/1/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@protocol KXHomeDelegate <NSObject>

@required

- (void)xmppStreamDidConnect;
- (void)xmppStreamDidDisconnect;
- (void)didReceiveMessage:(XMPPMessage *)message;
- (void)didSendMessage:(XMPPMessage *)message;

@end
