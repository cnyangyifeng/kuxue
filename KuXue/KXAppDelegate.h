//
//  KXAppDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/11/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXAuthenticationDelegate.h"
#import "KXMessageDelegate.h"
#import "KXUser.h"
#import "XMPP.h"
#import "XMPPRoster.h"
#import "constants.h"

@interface KXAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    KXUser *user;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, nonatomic) XMPPStream *xmppStream;
@property (readonly, nonatomic) XMPPRoster *xmppRoster;

@property (strong, nonatomic) KXUser *user;

@property (nonatomic) BOOL firstRun;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (weak, nonatomic) id authenticationDelegate;
@property (weak, nonatomic) id messageDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)connect;
- (void)disconnect;
- (BOOL)isAuthenticated;

- (void)loadUserFromLocalStorage;
- (void)signOutUser;

@end
