//
//  KXContact.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/14/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "pinyin.h"

@interface KXContact : NSManagedObject

@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *theme;
@property (strong, nonatomic) NSString *userId;

@end
