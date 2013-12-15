//
//  KXAppDelegate.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/11/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXAppDelegate.h"

@implementation KXAppDelegate

@synthesize window = _window;

@synthesize xmppStream = _xmppStream;
@synthesize xmppRoster = _xmppRoster;

@synthesize user = _user;

@synthesize firstRun = _firstRun;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize authenticationDelegate = _authenticationDelegate;
@synthesize contactsDelegate = _contactsDelegate;
@synthesize messageDelegate = _messageDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* First Run Check */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"firstRun"]) {
        self.firstRun = TRUE;
        [defaults setObject:[NSDate date] forKey:@"firstRun"];
        // Initializes application data.
        [self initMockData];
    } else {
        self.firstRun = FALSE;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self loadUserFromLocalStorage];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark - Core Data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

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

#pragma mark - Application Mock Data

- (void)initMockData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *idea1 = [NSEntityDescription insertNewObjectForEntityForName:@"KXIdea" inManagedObjectContext:context];
    [idea1 setValue:@"yangyifeng.jpg" forKey:@"contactAvatar"];
    [idea1 setValue:@"杨义锋" forKey:@"contactName"];
    [idea1 setValue:[NSNumber numberWithInt:1] forKey:@"sid"];
    [idea1 setValue:@"theme-1.jpg" forKey:@"theme"];
    [idea1 setValue:@"thumbnail-1.jpg" forKey:@"ideaThumbnail"];
    [idea1 setValue:@"1小时前" forKey:@"ideaTimeReceived"];
    [idea1 setValue:@"在新东方收获成功" forKey:@"ideaTitle"];
    
    NSManagedObject *contact1 = [NSEntityDescription insertNewObjectForEntityForName:@"KXContact" inManagedObjectContext:context];
    [contact1 setValue:@"yangyifeng.jpg" forKey:@"avatar"];
    [contact1 setValue:@"杨义锋" forKey:@"nickname"];
    [contact1 setValue:@"theme-1.jpg" forKey:@"theme"];
    [contact1 setValue:@"yangyifeng" forKey:@"userId"];
    
    NSManagedObject *message = [NSEntityDescription insertNewObjectForEntityForName:@"KXMessage" inManagedObjectContext:context];
    [message setValue:@"yangyifeng.jpg" forKey:@"contactAvatar"];
    [message setValue:@"杨义锋" forKey:@"contactName"];
    [message setValue:[NSDate date] forKey:@"messageTimeReceived"];
    [message setValue:@"同学，你好。" forKey:@"messageContent"];
    [message setValue:@"incoming" forKey:@"messageType"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Data not saved. %@, %@", error, [error userInfo]);
    }
}

#pragma mark - User

- (void)loadUserFromLocalStorage
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXUser"];
    NSMutableArray *records = [[context executeFetchRequest:request error:nil] mutableCopy];
    if (records != nil && [records count] > 0) {
        _user = (KXUser *)[records objectAtIndex:0];
    }
    
    NSLog(@"User loaded from local storage.");
}

- (void)signOutUser
{
    _user = nil;
    
    NSLog(@"User signed out.");
}

#pragma mark - XMPP

- (BOOL)connect
{
    if (_user == nil) {
        NSLog(@"XMPP server not connected, no user exists.");
        return NO;
    }
    
    [self setUpStream];
    
    NSString *jid = [_user.userId stringByAppendingFormat:@"%@%@", @"@", XMPP_SERVER_URL];
    
    if (![_xmppStream isDisconnected]) {
        NSLog(@"XMPP server connection kept alive.");
        return YES;
    }
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:jid]];
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"XMPP server failed to connect.");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:@"Connection lost." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    NSLog(@"XMPP server connects.");
    
    return YES;
}

- (void)disconnect
{
    if (_user == nil) {
        return;
    }
    
    [self goOffline];
    [_xmppStream disconnect];
    
    NSLog(@"XMPP server disconnects.");
}

- (BOOL)isAuthenticated
{
    return [_xmppStream isAuthenticated];
}

#pragma mark - XMPP Delegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"XMPP Stream did connect.");
    
    NSError *error = nil;
    [_xmppStream authenticateWithPassword:_user.password error:&error];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP Stream did authenticate, user: %@.", self.user.userId);
    
    [self.authenticationDelegate userAuthenticated];
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"XMPP Stream did not authenticate, user: %@, %@", [self.user.userId isEqualToString:@""] ? @"nil" : self.user.userId, error);
    
    [self.authenticationDelegate userNotAuthenticated];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"Did receive IQ. %@", iq);
    
    if ([iq.type isEqualToString:@"result"]) {
        NSXMLElement *query = iq.childElement;
        if ([query.name isEqualToString:@"query"]) {
            NSArray *items = query.children;
            [self.contactsDelegate contactsUpdated:items];
        }
        return YES;
    }
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"XMPP Stream did receive message: %@", message.body);
    
    [self.messageDelegate newMessageReceived:message];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type];
    NSString *usr = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:usr]) {
        NSLog(@"XMPP Stream did receive presence: %@. From: %@, Sender: %@.", presenceType, presenceFromUser, usr);
        
        if ([presenceType isEqualToString:@"available"]) {
            // Sets new contact online.
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            // Sets contact went offline.
        }
    }
}

#pragma mark - XMPP Utilities

- (void)setUpStream
{
    NSLog(@"Sets up stream.");
    
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline
{
    NSLog(@"Goes online.");
    
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

- (void)goOffline
{
    NSLog(@"Goes offline.");
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

@end
