//
//  KXMessage.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/20/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface KXMessage : NSManagedObject

@property (strong, nonatomic) NSString *contactAvatar;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *messageContent;
@property (strong, nonatomic) NSString *messageTimeReceived;
@property (strong, nonatomic) NSString *messageType;
@property (strong, nonatomic) NSString *sid;

@end
