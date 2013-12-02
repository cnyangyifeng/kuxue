//
//  KXChatDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/1/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KXChatDelegate <NSObject>

@required

- (void)newContactOnline:(NSString *)contactName;
- (void)contactWentOffline:(NSString *)contactName;
- (void)didDisconnect;

@end
