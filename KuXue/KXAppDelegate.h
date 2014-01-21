//
//  KXAppDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/11/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Reachability/Reachability.h>
#import "KXChatDelegate.h"
#import "KXContactsDelegate.h"
#import "KXHomeDelegate.h"
#import "KXLoginDelegate.h"
#import "KXMeDelegate.h"
#import "KXRegisterDelegate.h"
#import "KXSMSVerificationDelegate.h"
#import "KXUserProfileDelegate.h"
#import "KXNicknameDelegate.h"
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
    XMPPMessageArchiving *xmppMessageArchiving;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesCoreDataStorage;
    
    NSString *password;
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
@property (strong, readonly, nonatomic) XMPPMessageArchiving *xmppMessageArchiving;
@property (strong, readonly, nonatomic) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (strong, readonly, nonatomic) XMPPCapabilities *xmppCapabilities;
@property (strong, readonly, nonatomic) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesCoreDataStorage;

@property (nonatomic) BOOL loginEnabled;
@property (nonatomic) BOOL registerEnabled;
@property (nonatomic) BOOL homeEnabled;

@property (nonatomic) BOOL firstRun;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (weak, nonatomic) id chatDelegate;
@property (weak, nonatomic) id contactsDelegate;
@property (weak, nonatomic) id homeDelegate;
@property (weak, nonatomic) id loginDelegate;
@property (weak, nonatomic) id meDelegate;
@property (weak, nonatomic) id registerDelegate;
@property (weak, nonatomic) id smsVerificationDelegate;
@property (weak, nonatomic) id userProfileDelegate;
@property (weak, nonatomic) id nicknameDelegate;

@property (nonatomic) NSInteger badgeNumber;

- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectContext *)managedRosterObjectContext;
- (NSManagedObjectContext *)managedvCardObjectContext;
- (NSManagedObjectContext *)managedMessageArchivingObjectContext;
- (NSManagedObjectContext *)managedCapabilitiesObjectContext;

- (BOOL)connect;
- (void)disconnect;
- (BOOL)registerWithElements:(NSArray *)elements;

@end
