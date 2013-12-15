//
//  KXContactsDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/15/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KXContactsDelegate <NSObject>

@required

- (void)contactsUpdated:(NSArray *)items;

@end
