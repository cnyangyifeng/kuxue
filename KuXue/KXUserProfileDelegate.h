//
//  KXAuthenticationDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/14/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPvCardTemp.h"

@protocol KXUserProfileDelegate <NSObject>

@required

- (void)didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp;

@end
