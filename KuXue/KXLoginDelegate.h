//
//  KXAuthenticationDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/14/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KXLoginDelegate <NSObject>

@required

- (void)xmppStreamDidAuthenticate;
- (void)didNotAuthenticate;

@end
