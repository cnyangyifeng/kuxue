//
//  KXChatViewController.m
//  KuXue
//
//  Created by Yang Yi Feng on 11/18/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import "KXChatViewController.h"

@interface KXChatViewController ()

@end

@implementation KXChatViewController

@synthesize chatTableView = _chatTableView;
@synthesize chatToolbar = _chatToolbar;
@synthesize fixedToolbarButtonItemSpace = _fixedToolbarButtonItemSpace;
@synthesize chatTypeButtonItem = _chatTypeButtonItem;
@synthesize chatTypeButton = _chatTypeButton;
@synthesize talkButtonItem = _talkButtonItem;
@synthesize talkButton = _talkButton;
@synthesize inputTextViewButtonItem = _inputTextViewButtonItem;
@synthesize inputTextView = _inputTextView;
@synthesize smileyButtonItem = _smileyButtonItem;
@synthesize smileyButton = _smileyButton;
@synthesize insertButtonItem = _insertButtonItem;
@synthesize insertButton = _insertButton;

@synthesize messages = _messages;
@synthesize timestamps = _timestamps;
@synthesize subtitles = _subtitles;
@synthesize avatars = _avatars;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initMainView];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initMockData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addKeyboardControl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeKeyboardControl];
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
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"KXMessage"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"sid" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
    self.messages = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    // Reloads table data every time this view appears.
    
    [self.chatTableView reloadData];
}

- (void)initMainView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - CHAT_TOOLBAR_HEIGHT)];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height - CHAT_TOOLBAR_HEIGHT, self.view.bounds.size.width, CHAT_TOOLBAR_HEIGHT)];
    toolbar.backgroundColor = [UIColor whiteColor];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0.0f, 0.0f, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT)];
    [leftButton setBackgroundColor:[UIColor whiteColor]];
    [leftButton setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
    [leftButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [leftButton.layer setBorderWidth:0.5f];
    [leftButton.layer setCornerRadius:leftButton.bounds.size.width / 2.0f];
    // [leftButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    // [leftButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(switchChatType) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem= [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *holdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [holdButton setFrame:CGRectMake(0.0f, 0.0f, toolbar.bounds.size.width - CHAT_BUTTON_WIDTH - CHAT_TOOLBAR_SPACE, CHAT_BUTTON_HEIGHT)];
    [holdButton setBackgroundColor:[UIColor blackColor]];
    [holdButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [holdButton.layer setBorderWidth:0.5f];
    [holdButton.layer setCornerRadius:5.0f];
    [holdButton setTitle:@"Hold to Talk" forState:UIControlStateNormal];
    [holdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [holdButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    UIBarButtonItem *holdButtonItem = [[UIBarButtonItem alloc] initWithCustomView:holdButton];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbar.bounds.size.width - CHAT_BUTTON_WIDTH - CHAT_TOOLBAR_SPACE, CHAT_TEXT_FIELD_HEIGHT)];
    [textView setBackgroundColor:[UIColor whiteColor]];
    [textView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textView.layer setBorderWidth:0.5f];
    [textView.layer setCornerRadius:5.0f];
    [textView setFont:[UIFont systemFontOfSize:15.0f]];
    UIBarButtonItem *textViewButtonItem = [[UIBarButtonItem alloc] initWithCustomView:textView];
    
    UIButton *middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [middleButton setFrame:CGRectMake(0.0f, 0.0f, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT)];
    [middleButton setBackgroundColor:[UIColor whiteColor]];
    [middleButton setImage:[UIImage imageNamed:@"Smiley"] forState:UIControlStateNormal];
    [middleButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [middleButton.layer setBorderWidth:0.5f];
    [middleButton.layer setCornerRadius:middleButton.bounds.size.width / 2.0f];
    // [middleButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    // [middleButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [middleButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *middleButtonItem= [[UIBarButtonItem alloc] initWithCustomView:middleButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0.0f, 0.0f, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT)];
    [rightButton setBackgroundColor:[UIColor whiteColor]];
    [rightButton setImage:[UIImage imageNamed:@"Insert"] forState:UIControlStateNormal];
    [rightButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [rightButton.layer setBorderWidth:0.5f];
    [rightButton.layer setCornerRadius:rightButton.bounds.size.width / 2.0f];
    // [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    // [rightButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem= [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = -10.0f;
    
    self.isAudioChat = NO;
    
    [toolbar setItems:[NSArray arrayWithObjects:fixedSpace, leftButtonItem, textViewButtonItem, middleButtonItem, rightButtonItem, nil]];
    
    self.chatTypeButtonItem = leftButtonItem;
    self.chatTypeButton = leftButton;
    self.fixedToolbarButtonItemSpace = fixedSpace;
    self.talkButtonItem = holdButtonItem;
    self.talkButton = holdButton;
    self.inputTextViewButtonItem = textViewButtonItem;
    self.inputTextView = textView;
    self.smileyButtonItem = middleButtonItem;
    self.smileyButton = middleButton;
    self.insertButtonItem = rightButtonItem;
    self.insertButton = rightButton;
    
    self.chatTableView = tableView;
    [self.view addSubview:self.chatTableView];
    
    self.chatToolbar = toolbar;
    [self.view addSubview:self.chatToolbar];
}

- (void)switchChatType
{
    if (self.isAudioChat) {
        [self.view hideKeyboard];
        [self.chatTypeButton setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
        [self.chatToolbar setItems:[NSArray arrayWithObjects:self.fixedToolbarButtonItemSpace, self.chatTypeButtonItem, self.inputTextViewButtonItem, self.smileyButtonItem, self.insertButtonItem, nil]];
         self.isAudioChat = NO;
    } else {
        [self.chatTypeButton setImage:[UIImage imageNamed:@"Keyboard"] forState:UIControlStateNormal];
        [self.chatToolbar setItems:[NSArray arrayWithObjects:self.fixedToolbarButtonItemSpace, self.chatTypeButtonItem, self.talkButtonItem, self.smileyButtonItem, self.insertButtonItem, nil]];
        self.isAudioChat = YES;
    }
}

- (void)hideKeyboard
{
    [self.view hideKeyboard];
}

#pragma mark - Keyboard Control

- (void)addKeyboardControl
{
    self.view.keyboardTriggerOffset = _chatToolbar.bounds.size.height;
    
    UITableView *tv = self.chatTableView;
    UIToolbar *tb = self.chatToolbar;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        /* Try not to call "self" inside this block (retain cycle). But if you do, make sure to remove DAKeyboardControl when you are done with the view controller by calling: [self.view removeKeyboardControl]; */
        CGRect toolbarFrame = tb.frame;
        toolbarFrame.origin.y = keyboardFrameInView.origin.y - toolbarFrame.size.height;
        tb.frame = toolbarFrame;
        
        CGRect tableViewFrame = tv.frame;
        tableViewFrame.size.height = toolbarFrame.origin.y;
        tv.frame = tableViewFrame;
    }];
    
    self.chatTableView = tv;
    self.chatToolbar = tb;
}

- (void)removeKeyboardControl
{
    [self.view removeKeyboardControl];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KXChatTableViewCell *cell = [[KXChatTableViewCell alloc] init];
    
    KXMessage *message = [self.messages objectAtIndex:indexPath.row];
    cell.contactAvatarImageView.image = [UIImage imageNamed:message.contactAvatar];
    if ([message.messageType isEqualToString:@"receiver"]) {
        [cell.contactAvatarImageView setFrame:CGRectMake(cell.bounds.size.width - 38.0f, 6.0f, 32.0f, 32.0f)];
    }
    cell.messageContentLabel.text = message.messageContent;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
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

@end
