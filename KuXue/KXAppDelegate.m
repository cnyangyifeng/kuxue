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

@synthesize firstRun = _firstRun;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize xmppStream = _xmppStream;
@synthesize xmppRoster = _xmppRoster;

@synthesize messageDelegate = _messageDelegate;

@synthesize user = _user;

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
    
    [self initUser];
    
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
    
    NSManagedObject *user1 = [NSEntityDescription insertNewObjectForEntityForName:@"KXUser" inManagedObjectContext:context];
    [user1 setValue:@"yangyifeng.jpg" forKey:@"avatar"];
    [user1 setValue:@"杨义锋" forKey:@"nickname"];
    [user1 setValue:@"password" forKey:@"password"];
    [user1 setValue:@"yangyifeng" forKey:@"userId"];
    
    NSManagedObject *idea1 = [NSEntityDescription insertNewObjectForEntityForName:@"KXIdea" inManagedObjectContext:context];
    [idea1 setValue:@"liukun.jpg" forKey:@"contactAvatar"];
    [idea1 setValue:@"刘鹍" forKey:@"contactName"];
    [idea1 setValue:[NSNumber numberWithInt:1] forKey:@"sid"];
    [idea1 setValue:@"theme-1.jpg" forKey:@"theme"];
    [idea1 setValue:@"thumbnail-1.jpg" forKey:@"ideaThumbnail"];
    [idea1 setValue:@"1小时前" forKey:@"ideaTimeReceived"];
    [idea1 setValue:@"在新东方收获成功" forKey:@"ideaTitle"];
    
    NSManagedObject *contact1 = [NSEntityDescription insertNewObjectForEntityForName:@"KXContact" inManagedObjectContext:context];
    [contact1 setValue:@"liukun.jpg" forKey:@"contactAvatar"];
    [contact1 setValue:@"刘鹍" forKey:@"contactName"];
    [contact1 setValue:@"13811155255" forKey:@"mobile"];
    [contact1 setValue:@"theme-1.jpg" forKey:@"theme"];
    
    NSManagedObject *message = [NSEntityDescription insertNewObjectForEntityForName:@"KXMessage" inManagedObjectContext:context];
    [message setValue:@"liukun.jpg" forKey:@"contactAvatar"];
    [message setValue:@"刘鹍" forKey:@"contactName"];
    [message setValue:[NSDate date] forKey:@"messageTimeReceived"];
    [message setValue:@"同学，你好。" forKey:@"messageContent"];
    [message setValue:@"incoming" forKey:@"messageType"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Data not saved. %@, %@", error, [error userInfo]);
    }
}

- (void)initUser
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXUser"];
    NSMutableArray *records = [[context executeFetchRequest:request error:nil] mutableCopy];
    _user = (KXUser *)[records objectAtIndex:0];
    _user.userId = @"yangyifeng";
    _user.password = @"password";
}

#pragma mark - XMPP

- (BOOL)connect
{
    NSLog(@"Connects.");
    
    [self setUpStream];
    
    NSString *jid = [_user.userId stringByAppendingString:@"@42.96.184.90"];
    
    if (![_xmppStream isDisconnected]) {
        return YES;
    }
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:jid]];
    [_xmppStream setHostName:@"42.96.184.90"];
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:@"Connection lost." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    NSLog(@"Disconnects.");
    
    [self goOffline];
    [_xmppStream disconnect];
}

- (void)setUpStream
{
    NSLog(@"Sets up stream.");
    
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline
{
    NSLog(@"Goes online. isConnected: %d isAuthenticated: %d", _xmppStream.isConnected, _xmppStream.isAuthenticated);
    
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

- (void)goOffline
{
    NSLog(@"Goes offline.");
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
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
    NSLog(@"XMPP Stream did authenticate.");
    
    [self goOnline];
}

- (void)xmppSteam:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"XMPP Stream did not authenticate. %@", error);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"Did receive IQ.");
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"XMPP Stream did receive message: %@", message.body);
    
    [self.messageDelegate newMessageReceived:message];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"XMPP Stream did receive presence.");
    
    NSString *presenceType = [presence type];
    NSString *usr = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:usr]) {
        if ([presenceType isEqualToString:@"available"]) {
            // Sets new contact online.
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            // Sets contact went offline.
        }
    }
}

@end
