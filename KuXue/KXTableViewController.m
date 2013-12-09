//
//  KXTableViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 12/9/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXTableViewController.h"

@interface KXTableViewController ()

@end

@implementation KXTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

#pragma mark - Application Delegate

- (KXAppDelegate *)appDelegate
{
    return (KXAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - XMPP

- (XMPPStream *)xmppStream
{
    return [[self appDelegate] xmppStream];
}

@end
