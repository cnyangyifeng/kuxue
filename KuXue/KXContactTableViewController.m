//
//  KXContactTableViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/17/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXContactTableViewController.h"

@interface KXContactTableViewController ()

@end

@implementation KXContactTableViewController

@synthesize contact = _contact;

@synthesize ideas = _ideas;

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
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initMockData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initializations

- (void)initMockData
{
    // Fetches the application mock data.
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXIdea"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"sid" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
    self.ideas = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    // Reloads table data every time this view appears.
    
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ideas.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *headerCellIdendifier = @"contactHeaderTableViewCell";
    static NSString *cellIdentifier = @"contactTableViewCell";
    
    if (indexPath.row == 0) {
        KXContactHeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:headerCellIdendifier forIndexPath:indexPath];
        headerCell.themeImageView.image = [UIImage imageNamed:self.contact.theme];
        headerCell.contactNameLabel.text = self.contact.nickname;
        headerCell.contactAvatarImageView.image = [UIImage imageNamed:self.contact.avatar];
        headerCell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        return headerCell;
    } else {
        KXContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        KXIdea *idea = [self.ideas objectAtIndex:indexPath.row - 1];
        cell.ideaThumbnailImageView.image = [UIImage imageNamed:idea.ideaThumbnail];
        cell.ideaTitleLabel.text = idea.ideaTitle;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 315.0f;
    } else {
        return 90.0f;
    }
}

#pragma mark - Navigations

- (IBAction)pushChatViewController:(id)sender
{
    KXChatViewController *chatViewController = [[KXChatViewController alloc] init];
    chatViewController.contact = self.contact;
    
    chatViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}

@end
