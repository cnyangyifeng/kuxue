//
//  KXAppDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/11/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXAuthenticationDelegate.h"
#import "KXContactsDelegate.h"
#import "KXMessageDelegate.h"
#import "XMPPFramework.h"
#import "constants.h"

@interface KXAppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate, XMPPReconnectDelegate, XMPPRosterDelegate, XMPPvCardTempModuleDelegate, XMPPvCardAvatarDelegate, XMPPCapabilitiesDelegate> {
    UIWindow *window;
    UIViewController *mainTabBarController;
    
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPvCardCoreDataStorage *xmppvCardCoreDataStorage;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesCoreDataStorage;
    
    NSString *password;
    
    BOOL autoConnect;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *mainTabBarController;

@property (strong, readonly, nonatomic) XMPPStream *xmppStream;
@property (strong, readonly, nonatomic) XMPPReconnect *xmppReconnect;
@property (strong, readonly, nonatomic) XMPPRoster *xmppRoster;
@property (strong, readonly, nonatomic) XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;
@property (strong, readonly, nonatomic) XMPPvCardTempModule *xmppvCardTempModule;
@property (strong, readonly, nonatomic) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (strong, readonly, nonatomic) XMPPvCardCoreDataStorage *xmppvCardCoreDataStorage;
@property (strong, readonly, nonatomic) XMPPCapabilities *xmppCapabilities;
@property (strong, readonly, nonatomic) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesCoreDataStorage;

@property (nonatomic) BOOL autoConnect;

@property (nonatomic) BOOL firstRun;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (weak, nonatomic) id authenticationDelegate;
@property (weak, nonatomic) id contactsDelegate;
@property (weak, nonatomic) id messageDelegate;

@property (nonatomic) NSInteger badgeNumber;

- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectContext *)managedRosterObjectContext;
- (NSManagedObjectContext *)managedvCardObjectContext;
- (NSManagedObjectContext *)managedCapabilitiesObjectContext;

- (BOOL)connect:(BOOL)automatic;
- (void)disconnect;
- (BOOL)isConnected;

- (XMPPUserCoreDataStorageObject *)user;

@end
