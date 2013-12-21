//
//  KXUser.h
//  KuXue
//
//  Created by Yang Yi Feng on 12/3/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface KXUser : NSManagedObject

@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSDate *lastActiveTime;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *userId;

@end
