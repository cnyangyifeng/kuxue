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
@synthesize xmppMessageArchiving;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesCoreDataStorage;

@synthesize loginEnabled = _loginEnabled;
@synthesize registerEnabled = _registerEnabled;
@synthesize homeEnabled = _homeEnabled;

@synthesize firstRun = _firstRun;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize chatDelegate = _chatDelegate;
@synthesize contactsDelegate = _contactsDelegate;
@synthesize homeDelegate = _homeDelegate;
@synthesize loginDelegate = _loginDelegate;
@synthesize meDelegate = _meDelegate;
@synthesize registerDelegate = _registerDelegate;
@synthesize smsVerificationDelegate = _smsVerificationDelegate;
@synthesize userProfileDelegate = _userProfileDelegate;
@synthesize nicknameDelegate = _nicknameDelegate;

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
        // TODO: Initializes application data for the first run.
    } else {
        self.firstRun = FALSE;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setLoginEnabled:NO];
    [self setRegisterEnabled:NO];
    [self setHomeEnabled:YES];
    
    [self setUpStream];
    if (![self connect]) {
        double delayInSeconds = 0.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.mainTabBarController performSegueWithIdentifier:@"presentLoginFromMain" sender:nil];
        });
    }
    
    /* Checks network reachablity. */
    Reachability *reach = [Reachability reachabilityWithHostname:XMPP_HOST_NAME];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
    
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

- (NSManagedObjectContext *)managedMessageArchivingObjectContext
{
    return [xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
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

#pragma mark - XMPP Public Methods

- (BOOL)connect
{
    if ([[self xmppStream] isConnected]) {
        NSLog(@"XMPP server connected, connection kept alive.");
        return YES;
    }
    
    NSString *myJid = [[NSUserDefaults standardUserDefaults] stringForKey:@"jid"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (myJid == nil || [myJid isEqualToString:@""] || myPassword == nil || [myPassword isEqualToString:@""]) {
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

- (BOOL)registerWithElements:(NSArray *)elements
{
    NSError *error = nil;
    if ([xmppStream registerWithElements:elements error:&error]) {
        return NO;
    }
    
    NSLog(@"New account registers.");
    return YES;
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"Socket did connect.");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"XMPP stream did connect.");
    if (self.homeEnabled) {
        [self.homeDelegate xmppStreamDidConnect];
    }
    if (self.registerEnabled) {
        [self.registerDelegate xmppStreamDidConnect];
    }
    NSError *error = nil;
    if (![xmppStream authenticateWithPassword:password error:&error]) {
        NSLog(@"XMPP stream authenticate with password error.");
    }
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"XMPP stream connect did timeout.");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"XMPP stream did disconnect.");
    if (self.homeEnabled) {
        [self.homeDelegate xmppStreamDidDisconnect];
        NSString *myJid = [[NSUserDefaults standardUserDefaults] stringForKey:@"jid"];
        if (myJid != nil) {
            [self connect];
        }
    }
    if (self.registerEnabled) {
        [self.registerDelegate xmppStreamDidDisconnect];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP stream did authenticate, user: %@.", [[xmppStream myJID] user]);
    [self goOnline];
    if (self.loginEnabled) {
        [self.loginDelegate xmppStreamDidAuthenticate];
    }
    if (self.registerEnabled) {
        [self.smsVerificationDelegate xmppStreamDidAuthenticate];
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"XMPP stream did not authenticate, user: %@.", [[xmppStream myJID] user]);
    if (self.loginEnabled) {
        [self.loginDelegate didNotAuthenticate];
    }
    if (self.registerEnabled) {
        [self.smsVerificationDelegate didNotAuthenticate];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    if ([iq.type isEqualToString:@"result"]) {
        // NSXMLElement *element = (NSXMLElement *)[iq.children objectAtIndex:0];
        NSLog(@"XMPP stream did receive IQ, type: %@.", iq.type);
    }
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"XMPP stream did receive message: %@", message.body);
    if ([message isChatMessageWithBody]) {
        XMPPUserCoreDataStorageObject *userStorageObject = [xmppRosterCoreDataStorage userForJID:[message from] xmppStream:xmppStream managedObjectContext:[self managedRosterObjectContext]];
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *from = [[userStorageObject jid] user];

        if (self.homeEnabled) {
            /* Reloads messages. */
            [self.homeDelegate didReceiveMessage:message];
            [self.chatDelegate didReceiveMessage:message];
            userStorageObject.unreadMessages =
                [NSNumber numberWithInt:[userStorageObject.unreadMessages intValue] + 1];
        }
        
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
            /* Presents a local notification. */
            self.badgeNumber++;
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"View";
            localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", from, body];
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
            // TODO: Sets new contact online.
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            // TODO: Sets contact went offline.
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"XMPP stream did receive error.");
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"XMPP stream did send message: %@", message.body);
    if (self.homeEnabled) {
        [self.homeDelegate didSendMessage:message];
        [self.chatDelegate didSendMessage:message];
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"XMPP stream did register.");
    if (self.registerEnabled) {
        [self.smsVerificationDelegate xmppStreamDidRegister];
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    NSLog(@"XMPP stream did not register. %@", error.description);
    if (self.registerEnabled) {
        [self.smsVerificationDelegate didNotRegister];
    }
}

#pragma mark - XMPPRosterDelegate

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"XMPP roster did end populating.");
    if (self.homeEnabled) {
        [self.contactsDelegate xmppRosterDidEndPopulating];
    }
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    NSLog(@"XMPP roster did receive roster item.");
    if (self.homeEnabled) {
        [self.contactsDelegate didReceiveRosterItem];
    }
}

#pragma mark - XMPPvCardTempModuleDelegate

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    NSLog(@"XMPP vCard temp module did receive vCard temp, jid: %@.", jid);
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    NSLog(@"XMPP vCard temp did update my vCard.");
    if (self.homeEnabled) {
        [self.nicknameDelegate xmppvCardTempModuleDidUpdateMyvCard:vCardTempModule];
    }
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
    NSLog(@"XMPP vCard temp failed to update my vCard. %@", error);
    if (self.homeEnabled) {
        [self.nicknameDelegate failedToUpdateMyvCard:error];
    }
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
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    xmppMessageArchiving.clientSideMessageArchivingOnly = YES;
    
    xmppCapabilitiesCoreDataStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesCoreDataStorage];
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    [xmppReconnect activate:xmppStream];
    [xmppRoster activate:xmppStream];
    [xmppvCardTempModule activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppMessageArchiving activate:xmppStream];
    [xmppCapabilities activate:xmppStream];
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppStream setHostName:XMPP_HOST_NAME];
    [xmppStream setHostPort:XMPP_HOST_PORT];
}

- (void)tearDownStream
{
    NSLog(@"Tears down stream.");
    
    [xmppStream removeDelegate:self];
    [xmppReconnect removeDelegate:self];
    [xmppRoster removeDelegate:self];
    [xmppvCardTempModule removeDelegate:self];
    [xmppvCardAvatarModule removeDelegate:self];
    [xmppMessageArchiving removeDelegate:self];
    [xmppCapabilities removeDelegate:self];
    
    [xmppReconnect deactivate];
    [xmppRoster deactivate];
    [xmppvCardTempModule deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppMessageArchiving deactivate];
    [xmppCapabilities deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterCoreDataStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppvCardCoreDataStorage = nil;
    xmppMessageArchiving = nil;
    xmppMessageArchivingCoreDataStorage = nil;
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

#pragma mark - Reachability

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *reach = [note object];
    if ([reach isReachable]) {
        NSLog(@"Network reachable. Connects.");
        [self connect];
    } else {
        NSLog(@"Network not reachable. Disconnects.");
        [self disconnect];
    }
}

@end
