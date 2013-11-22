//
//  KXAppDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/11/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"

@interface KXAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    
    XMPPStream *xmppStream;
    NSString *password;
    BOOL isOpen;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) BOOL firstRun;

@property (nonatomic, readonly) XMPPStream *xmppStream;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)connect;
- (void)disconnect;
- (void)setUpStream;
- (void)goOnline;
- (void)goOffline;

@end
