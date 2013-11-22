//
//  KXIdea.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/13/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface KXIdea : NSManagedObject

@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *contactAvatar;
@property (strong, nonatomic) NSNumber *sid;
@property (strong, nonatomic) NSString *theme;
@property (strong, nonatomic) NSString *ideaThumbnail;
@property (strong, nonatomic) NSString *ideaTimeReceived;
@property (strong, nonatomic) NSString *ideaTitle;

@end
