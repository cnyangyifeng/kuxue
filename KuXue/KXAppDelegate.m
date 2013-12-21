//
//  KXAppDelegate.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/11/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXAppDelegate.h"

@implementation KXAppDelegate

@synthesize window;
@synthesize mainTabBarController;

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterCoreDataStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppvCardCoreDataStorage;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesCoreDataStorage;

@synthesize autoConnect;

@synthesize lastActivateUser = _lastActivateUser;
@synthesize tempUserId = _tempUserId;
@synthesize tempPassword = _tempPassword;

@synthesize firstRun = _firstRun;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize authenticationDelegate = _authenticationDelegate;
@synthesize contactsDelegate = _contactsDelegate;
@synthesize messageDelegate = _messageDelegate;

@synthesize badgeNumber = _badgeNumber;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    mainTabBarController = self.window.rootViewController;
    self.badgeNumber = 0;
    
    /* First Run Check */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"firstRun"]) {
        self.firstRun = TRUE;
        [defaults setObject:[NSDate date] forKey:@"firstRun"];
        // Initializes application data.
        [self initApplicationData];
    } else {
        self.firstRun = FALSE;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self loadLastActiveUser];
    self.tempUserId = self.lastActivateUser.userId;
    self.tempPassword = self.lastActivateUser.password;
    
    [self setUpStream];
    [self connect:YES];
    
    return YES;
}

- (void)dealloc
{
    [self tearDownStream];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Application did enter background.");
    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) {
        [application setKeepAliveTimeout:600.0f handler:^{
            NSLog(@"Does some stuff to keep alive.");
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Application did enter foreground.");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Application did become active.");
    self.badgeNumber = 0;
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Application did receive local notification.");
    self.badgeNumber = 0;
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"KuXue" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"KuXue.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents Directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - XMPP Core Data

- (NSManagedObjectContext *)managedRosterObjectContext
{
    return [xmppRosterCoreDataStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedvCardObjectContext
{
    return [xmppvCardCoreDataStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedCapabilitiesObjectContext
{
    return [xmppCapabilitiesCoreDataStorage mainThreadManagedObjectContext];
}

#pragma mark - XMPP Connection/Disconnection

- (BOOL)connect:(BOOL)automatic
{
    autoConnect = automatic;
    
    if ([self isConnected]) {
        [self disconnect];
    }
    
    if (self.tempUserId == nil) {
        NSLog(@"XMPP server not connected, user not available.");
        return NO;
    }
    
    NSString *jid = [self.tempUserId stringByAppendingFormat:@"%@%@", @"@", XMPP_HOST_NAME];
    [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"XMPP server failed to connect.");
        return NO;
    }
    
    NSLog(@"XMPP server connects.");
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
    
    NSLog(@"XMPP server disconnects.");
}

- (BOOL)isConnected
{
    NSLog(@"XMPP server connected? %d.", [xmppStream isConnected]);
    return [xmppStream isConnected];
}

#pragma mark - XMPP Authentication

- (BOOL)authenticate
{
    NSError *error = nil;
    if (![xmppStream authenticateWithPassword:self.tempPassword error:&error]) {
        NSLog(@"XMPP stream authenticate with password error.");
        return NO;
    };
    
    return YES;
}

- (BOOL)isAuthenticated
{
    NSLog(@"isAuthenticated: %d.", [xmppStream isAuthenticated]);
    return [xmppStream isAuthenticated];
}

#pragma mark - XMPPStream Delegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"Socket did connect.");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"XMPP stream did connect.");
    [self authenticate];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP stream did authenticate, user: %@, password: %@.", self.tempUserId, self.tempPassword);
    if (!self.autoConnect) {
        [self.authenticationDelegate userAuthenticated];
    }
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"XMPP stream did not authenticate, user: %@, password: %@.", self.tempUserId, self.tempPassword);
    if (!self.autoConnect) {
        [self.authenticationDelegate userNotAuthenticated];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"XMPP stream did receive IQ. %@", iq);
    
    // Deprecated
    // Returns roster result.
//    if ([iq.type isEqualToString:@"result"]) {
//        NSXMLElement *query = iq.childElement;
//        if ([query.name isEqualToString:@"query"]) {
//            [self.contactsDelegate contactsUpdated:query.children];
//        }
//    }
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"XMPP stream did receive message: %@", message.body);
    if ([message isChatMessageWithBody]) {
        XMPPUserCoreDataStorageObject *userStorageObject = [xmppRosterCoreDataStorage userForJID:[message from] xmppStream:xmppStream managedObjectContext:[self managedRosterObjectContext]];
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [userStorageObject displayName];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            [self.messageDelegate newMessageReceived:message];
        } else {
            NSLog(@"Presents a local notification.");
            self.badgeNumber++;
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"View";
            localNotification.alertBody = [NSString stringWithFormat:@"%@\n%@", displayName, body];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = self.badgeNumber;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type];
    NSString *usr = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:usr]) {
        NSLog(@"XMPP stream did receive presence: %@. From: %@, Sender: %@.", presenceType, presenceFromUser, usr);
        if ([presenceType isEqualToString:@"available"]) {
            // Sets new contact online.
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            // Sets contact went offline.
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"XMPP stream did receive error.");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"XMPP stream did disconnect.");
}

#pragma mark - XMPPRoster Delegate

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    NSLog(@"XMPP roster did receive buddy request.");
    XMPPUserCoreDataStorageObject *userStorageObject = [xmppRosterCoreDataStorage userForJID:[presence from] xmppStream:xmppStream managedObjectContext:[self managedRosterObjectContext]];
    NSString *displayName = [userStorageObject displayName];
    NSString *jidStringBare = [presence fromStr];
    NSString *body = nil;
    if (![displayName isEqualToString:jidStringBare]) {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>.", displayName, jidStringBare];
    } else {
        body = [NSString stringWithFormat:@"Buddy request from %@.", displayName];
    }
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        // New buddy request received.
    } else {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"View";
        localNotification.alertBody = body;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

#pragma mark - Private XMPP Utilities

- (void)setUpStream
{
    NSLog(@"Sets up stream.");
    
    xmppStream = [[XMPPStream alloc] init];
    xmppStream.enableBackgroundingOnSocket = YES;
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    xmppRosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterCoreDataStorage];
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    xmppvCardCoreDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardCoreDataStorage];
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    xmppCapabilitiesCoreDataStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesCoreDataStorage];
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    [xmppReconnect activate:xmppStream];
    [xmppRoster activate:xmppStream];
    [xmppvCardTempModule activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities activate:xmppStream];
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppStream setHostName:XMPP_HOST_NAME];
    [xmppStream setHostPort:XMPP_HOST_PORT];
}

- (void)tearDownStream
{
    NSLog(@"Tears down stream.");
    
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect deactivate];
    [xmppRoster deactivate];
    [xmppvCardTempModule deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterCoreDataStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppvCardCoreDataStorage = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesCoreDataStorage = nil;
}

- (void)goOnline
{
    NSLog(@"Goes online.");
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}

- (void)goOffline
{
    NSLog(@"Goes offline.");
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
}

#pragma mark - Application Data

- (void)initApplicationData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *usr = [NSEntityDescription insertNewObjectForEntityForName:@"KXUser" inManagedObjectContext:context];
    [usr setValue:@"male.jpg" forKey:@"avatar"];
    [usr setValue:@"guest" forKey:@"nickname"];
    [usr setValue:@"password" forKey:@"password"];
    [usr setValue:GUEST_ID forKey:@"userId"];
    [usr setValue:[NSDate date] forKey:@"lastActiveTime"];
    
    NSManagedObject *idea = [NSEntityDescription insertNewObjectForEntityForName:@"KXIdea" inManagedObjectContext:context];
    [idea setValue:@"nytimes.jpg" forKey:@"contactAvatar"];
    [idea setValue:@"诗词歌赋" forKey:@"contactName"];
    [idea setValue:[NSNumber numberWithInt:1] forKey:@"sid"];
    [idea setValue:@"theme-1.jpg" forKey:@"theme"];
    [idea setValue:@"thumbnail-1.jpg" forKey:@"ideaThumbnail"];
    [idea setValue:@"1小时前" forKey:@"ideaTimeReceived"];
    [idea setValue:@"在新东方收获成功" forKey:@"ideaTitle"];
    
    NSManagedObject *message = [NSEntityDescription insertNewObjectForEntityForName:@"KXMessage" inManagedObjectContext:context];
    [message setValue:@"yangyifeng.jpg" forKey:@"contactAvatar"];
    [message setValue:@"杨义锋" forKey:@"contactName"];
    [message setValue:[NSDate date] forKey:@"messageReceivedTime"];
    [message setValue:@"同学，你好。" forKey:@"messageContent"];
    [message setValue:@"incoming" forKey:@"messageType"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Data not saved. %@, %@", error, [error userInfo]);
    }
}

- (void)loadLastActiveUser
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXUser"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"lastActiveTime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
    NSMutableArray *records = [[context executeFetchRequest:request error:nil] mutableCopy];
    if (records != nil && [records count] > 0) {
        self.lastActivateUser = (KXUser *)[records objectAtIndex:0];
    }
    NSLog(@"User loaded.");
}

- (void)unloadLastActiveUser
{
    self.lastActivateUser = nil;
    NSLog(@"User unloaded.");
}

- (void)saveLastActiveUser
{
    NSManagedObjectContext *context = [self managedObjectContext];
    KXUser *usr = [NSEntityDescription insertNewObjectForEntityForName:@"KXUser" inManagedObjectContext:context];
    [usr setValue:@"male.jpg" forKey:@"avatar"];
    [usr setValue:[NSDate date] forKey:@"lastActiveTime"];
    [usr setValue:self.tempUserId forKey:@"nickname"];
    [usr setValue:self.tempPassword forKey:@"password"];
    [usr setValue:self.tempUserId forKey:@"userId"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Data not inserted. %@, %@", error, [error userInfo]);
        return;
    }
}

#pragma mark - Deprecated

- (void)fetchRoster
{
    // Deprecated
    // XMPPRosterMemoryStorage *rosterStorage = [[XMPPRosterMemoryStorage alloc] init];
    // xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:rosterStorage];
    // [xmppRoster activate:xmppStream];
    // [xmppRoster fetchRoster];
}

@end
