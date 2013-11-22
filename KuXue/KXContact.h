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

@property (strong, nonatomic) NSString *contactAvatar;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) NSString *theme;

@end
