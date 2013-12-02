//
//  KXAppDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/11/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXChatDelegate.h"
#import "KXMessageDelegate.h"
#import "XMPP.h"
#import "XMPPRoster.h"

@interface KXAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    NSString *password;
    BOOL isOpen;
    
    __weak NSObject <KXChatDelegate> *chatDelegate;
    __weak NSObject <KXMessageDelegate> *messageDelegate;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL firstRun;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, nonatomic) XMPPStream *xmppStream;
@property (readonly, nonatomic) XMPPRoster *xmppRoster;

@property (weak, nonatomic) id chatDelegate;
@property (weak, nonatomic) id messageDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)connect;
- (void)disconnect;
- (void)setUpStream;
- (void)goOnline;
- (void)goOffline;

@end
