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

@synthesize firstRun = _firstRun;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize chatDelegate = _chatDelegate;
@synthesize contactsDelegate = _contactsDelegate;
@synthesize homeDelegate = _homeDelegate;
@synthesize loginDelegate = _loginDelegate;
@synthesize meDelegate = _meDelegate;
@synthesize userProfileDelegate = _userProfileDelegate;

@synthesize badgeNumber = _badgeNumber;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    mainTabBarController = self.window.rootViewController;
    self.badgeNumber = 0;
    
    /* First Run Check */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"firstRun"]) {
        self.firstRun = TRUE;
        [defaults setObject:[NSDate date] forKey:@"firstRun"];
        // TODO: Initialize application data.
    } else {
        self.firstRun = FALSE;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setUpStream];
    if (![self connect:YES]) {
        double delayInSeconds = 0.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.mainTabBarController performSegueWithIdentifier:@"presentLoginFromMain" sender:nil];
        });
    }
    
    return YES;
}

- (void)dealloc
{
    [self tearDownStream];
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
    // FIXME: Detects network reachability.
    [self connect:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Application will resign active.");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"Application will terminate.");
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

#pragma mark - XMPP Connection/Disconnection

- (BOOL)connect:(BOOL)automatic
{
    autoConnect = automatic;
    
    if ([[self xmppStream] isConnected]) {
        NSLog(@"XMPP server connected, connection kept alive.");
        return YES;
    }
    
    NSString *myJid = [[NSUserDefaults standardUserDefaults] stringForKey:@"jid"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (myJid == nil || myPassword == nil) {
        NSLog(@"XMPP server not connected, user not available.");
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJid]];
    password = myPassword;
    
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
    NSLog(@"XMPP server disconnects.");
    [self goOffline];
    [xmppStream disconnect];
}

- (void)fetchMyUser
{
    NSString *myJid = [[NSUserDefaults standardUserDefaults] stringForKey:@"jid"];
    // BUG: Ignores the core data storage and fetches my user information every time from the server, because of the libxml2 error.
    // [xmppvCardTempModule myvCardTemp];
    [xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:myJid] ignoreStorage:YES];
    // XMPPvCardTemp *vCard = [xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithString:myJid] shouldFetch:YES];
    // NSLog(@"vCard: %@", [vCard jid]);
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"Socket did connect.");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"XMPP stream did connect.");
    // FIXME: Detects network reachability.
    [self.homeDelegate didConnect];
    NSError *error = nil;
    if (![xmppStream authenticateWithPassword:password error:&error]) {
        NSLog(@"XMPP stream authenticate with password error.");
    }
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"XMPP stream connect did timeout.");
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP stream did authenticate, user: %@.", [[xmppStream myJID] user]);
    [self goOnline];
    if (!self.autoConnect) {
        [self.loginDelegate didAuthenticate];
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"XMPP stream did not authenticate, user: %@.", [[xmppStream myJID] user]);
    if (!self.autoConnect) {
        [self.loginDelegate didNotAuthenticate];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"XMPP stream did receive IQ, description: %@.", iq.description);
    if ([iq.type isEqualToString:@"result"]) {
        NSXMLElement *element = (NSXMLElement *)[iq.children objectAtIndex:0];
        if ([element.name isEqualToString:@"vCard"]) {
            XMPPvCardTemp *vCardTemp = [XMPPvCardTemp vCardTempCopyFromIQ:iq];
            [self.meDelegate didReceivevCardTemp:vCardTemp];
            [self.userProfileDelegate didReceivevCardTemp:vCardTemp];
        }
    }
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
            [self.homeDelegate didReceiveMessage:message];
            [self.chatDelegate didReceiveMessage:message];
        } else {
            NSLog(@"Presents a local notification.");
            self.badgeNumber++;
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"View";
            localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", displayName, body];
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
        NSLog(@"XMPP stream did receive '%@' presence of '%@'.", presenceType, presenceFromUser);
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
    // FIXME: Detects network reachability.
    [self.homeDelegate didDisconnect];
}

#pragma mark - XMPPRosterDelegate

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"XMPP roster did end populating.");
    [self.contactsDelegate contactsUpdated];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    NSLog(@"XMPP roster did receive roster item.");
}

#pragma mark - XMPPvCardTempModuleDelegate

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    NSLog(@"XMPP vCard temp module did receive vCard temp, jid: %@.", jid);
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    NSLog(@"XMPP vCard temp did update my vCard.");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
    NSLog(@"XMPP vCard temp failed to update my vCard.");
}

#pragma mark - XMPPvCardAvatarDelegate

- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid
{
    NSLog(@"XMPP vCard avatar module did receive photo, jid: %@.", jid);
}

#pragma mark - Private XMPP Methods

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
    [xmppReconnect removeDelegate:self];
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

@end
