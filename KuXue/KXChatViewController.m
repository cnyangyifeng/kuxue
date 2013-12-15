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
@synthesize inputTextFieldButtonItem = _inputTextFieldButtonItem;
@synthesize inputTextField = _inputTextField;
@synthesize emoticonOrAudioPlayButtonItem = _emoticonOrAudioPlayButtonItem;
@synthesize emoticonOrAudioPlayButton = _emoticonOrAudioPlayButton;
@synthesize insertOrAudioSendButtonItem = _insertOrAudioSendButtonItem;
@synthesize insertOrAudioSendButton = _insertOrAudioSendButton;

@synthesize talkHud = _talkHud;

@synthesize messages = _messages;
@synthesize turnSockets = _turnSockets;

@synthesize isAudioChatType = _isAudioChatType;

@synthesize contact = _contact;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initMainView];
    }
    
    self.turnSockets = [[NSMutableArray alloc] init];
    [[self appDelegate] setMessageDelegate:self];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    // Open TURN Socket.
    // KXUser *user = [[self appDelegate] user];
    // NSString *jid = @"contact@42.96.184.90";
    
    // TURNSocket *socket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:[XMPPJID jidWithString:jid]];
    // [self.turnSockets addObject:socket];
    // [socket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addKeyboardControl];

    [self initMockData];
    // [self initData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self scrollTableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeKeyboardControl];
    [self.talkHud commitRecording];
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
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"messageTimeReceived" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
    self.messages = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    // Reloads table data every time this view appears.
    
    [self.chatTableView reloadData];
}

- (void)initData
{
    self.messages = [[NSMutableArray alloc] init];
}

- (void)initMainView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - CHAT_TOOLBAR_HEIGHT)];
    [tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.dataSource = self;
    tableView.delegate = self;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tableView addGestureRecognizer:tapGestureRecognizer];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height - CHAT_TOOLBAR_HEIGHT, self.view.bounds.size.width, CHAT_TOOLBAR_HEIGHT)];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0.0f, 0.0f, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT)];
    [leftButton setBackgroundColor:[UIColor whiteColor]];
    [leftButton setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
    [leftButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [leftButton.layer setBorderWidth:0.5f];
    [leftButton.layer setCornerRadius:leftButton.bounds.size.width / 2.0f];
    [leftButton addTarget:self action:@selector(switchChatType) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem= [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tapButton setFrame:CGRectMake(0.0f, 0.0f, toolbar.bounds.size.width - CHAT_BUTTON_WIDTH - CHAT_TOOLBAR_ESTIMATED_SPACE, CHAT_BUTTON_HEIGHT)];
    [tapButton setBackgroundColor:[UIColor blackColor]];
    [tapButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [tapButton.layer setBorderWidth:0.5f];
    [tapButton.layer setCornerRadius:5.0f];
    [tapButton setTitle:@"Tap to Record" forState:UIControlStateNormal];
    [tapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tapButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [tapButton addTarget:self action:@selector(tapToRecord) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *tapButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tapButton];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbar.bounds.size.width - CHAT_BUTTON_WIDTH - CHAT_TOOLBAR_ESTIMATED_SPACE, CHAT_TEXT_FIELD_HEIGHT)];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField.layer setBorderWidth:0.5f];
    [textField.layer setCornerRadius:5.0f];
    [textField setFont:[UIFont systemFontOfSize:15.0f]];
    UIView *textFieldPadding = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, textField.frame.size.height)];
    textField.leftView = textFieldPadding;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.returnKeyType = UIReturnKeySend;
    textField.delegate = self;
    UIBarButtonItem *textFieldButtonItem = [[UIBarButtonItem alloc] initWithCustomView:textField];
    
    UIButton *middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [middleButton setFrame:CGRectMake(0.0f, 0.0f, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT)];
    [middleButton setBackgroundColor:[UIColor whiteColor]];
    [middleButton setImage:[UIImage imageNamed:@"Emoticon"] forState:UIControlStateNormal];
    [middleButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [middleButton.layer setBorderWidth:0.5f];
    [middleButton.layer setCornerRadius:middleButton.bounds.size.width / 2.0f];
    [middleButton addTarget:self action:@selector(tapToInsertEmoticonOrPlayAudio) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *middleButtonItem= [[UIBarButtonItem alloc] initWithCustomView:middleButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0.0f, 0.0f, CHAT_BUTTON_WIDTH, CHAT_BUTTON_HEIGHT)];
    [rightButton setBackgroundColor:[UIColor whiteColor]];
    [rightButton setImage:[UIImage imageNamed:@"Insert"] forState:UIControlStateNormal];
    [rightButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [rightButton.layer setBorderWidth:0.5f];
    [rightButton.layer setCornerRadius:rightButton.bounds.size.width / 2.0f];
    [rightButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem= [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = CHAT_TOOLBAR_LEFT_FIXED_SPACE;
    
    self.isAudioChatType = NO;
    [toolbar setItems:[NSArray arrayWithObjects:fixedSpace, leftButtonItem, textFieldButtonItem, middleButtonItem, rightButtonItem, nil]];
    
    KXVoiceHUD *voiceHud = [[KXVoiceHUD alloc] initWithParentView:self.view];
    voiceHud.title = @"Talk Now";
    voiceHud.delegate = self;
    
    self.chatTypeButtonItem = leftButtonItem;
    self.chatTypeButton = leftButton;
    self.fixedToolbarButtonItemSpace = fixedSpace;
    self.talkButtonItem = tapButtonItem;
    self.talkButton = tapButton;
    self.inputTextFieldButtonItem = textFieldButtonItem;
    self.inputTextField = textField;
    self.emoticonOrAudioPlayButtonItem = middleButtonItem;
    self.emoticonOrAudioPlayButton = middleButton;
    self.insertOrAudioSendButtonItem = rightButtonItem;
    self.insertOrAudioSendButton = rightButton;
    
    self.talkHud = voiceHud;
    
    self.chatTableView = tableView;
    [self.view addSubview:self.chatTableView];
    
    self.chatToolbar = toolbar;
    [self.view addSubview:self.chatToolbar];
}

#pragma mark - Chat Type Button

- (void)switchChatType
{
    if (self.isAudioChatType) {
        [self.view hideKeyboard];
        [self.chatTypeButton setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
        [self.talkButton becomeFirstResponder];
        [self.emoticonOrAudioPlayButton setImage:[UIImage imageNamed:@"Emoticon"] forState:UIControlStateNormal];
        [self.insertOrAudioSendButton setImage:[UIImage imageNamed:@"Insert"] forState:UIControlStateNormal];
        [self.chatToolbar setItems:[NSArray arrayWithObjects:self.fixedToolbarButtonItemSpace, self.chatTypeButtonItem, self.inputTextFieldButtonItem, self.emoticonOrAudioPlayButtonItem, self.insertOrAudioSendButtonItem, nil]];
        self.isAudioChatType = NO;
    } else {
        [self.chatTypeButton setImage:[UIImage imageNamed:@"Keyboard"] forState:UIControlStateNormal];
        [self.inputTextField becomeFirstResponder];
        [self.emoticonOrAudioPlayButton setImage:[UIImage imageNamed:@"Volume"] forState:UIControlStateNormal];
        [self.insertOrAudioSendButton setImage:[UIImage imageNamed:@"Send"] forState:UIControlStateNormal];
        [self.chatToolbar setItems:[NSArray arrayWithObjects:self.fixedToolbarButtonItemSpace, self.chatTypeButtonItem, self.talkButtonItem, self.emoticonOrAudioPlayButtonItem, self.insertOrAudioSendButtonItem, nil]];
        self.isAudioChatType = YES;
    }
}

#pragma mark - Tap To Talk Button

- (void)tapToRecord
{
    [self.view addSubview:self.talkHud];
    [self.talkHud startForFilePath:[NSString stringWithFormat:@"%@/Documents/KuXue.caf", NSHomeDirectory()]];
}

- (void)tapToInsertEmoticonOrPlayAudio
{
    if (self.isAudioChatType) {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Documents/KuXue.caf", NSHomeDirectory()]];
        [self.talkHud playRecording:url];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.chatTableView setFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - CHAT_TOOLBAR_HEIGHT - keyboardSize.height)];
    [self scrollTableView];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self.chatTableView setFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - CHAT_TOOLBAR_HEIGHT)];
    [self scrollTableView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    [self scrollTableView];
    [self sendMessage];
    
    return YES;
}

- (void)sendMessage
{
    NSString *messageContent = self.inputTextField.text;
    
    if (messageContent.length > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageContent];
        
        NSXMLElement *msg = [NSXMLElement elementWithName:@"message"];
        [msg addAttributeWithName:@"type" stringValue:@"chat"];
        [msg addAttributeWithName:@"to" stringValue:self.contact.userId];
        [msg addChild:body];
        
        [[[self appDelegate] xmppStream] sendElement:msg];
        
        self.inputTextField.text = @"";
        
        NSManagedObjectContext *context = [self managedObjectContext];
        KXMessage *message = [NSEntityDescription insertNewObjectForEntityForName:@"KXMessage" inManagedObjectContext:context];
        KXUser *usr = [[self appDelegate] user];
        message.contactAvatar = usr.avatar;
        message.contactName = usr.nickname;
        message.messageContent = messageContent;
        message.messageTimeReceived = [NSDate date];
        message.messageType = @"outgoing";
        [context insertObject:message];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Data not inserted. %@, %@", error, [error userInfo]);
            return;
        }
        [self.messages addObject:message];
        [self.chatTableView reloadData];
    }
}

#pragma mark - Talk HUD

- (void)KXVoiceHUD:(KXVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength {
    NSLog(@"Sound recorded with file %@ for %.2f seconds", [recordPath lastPathComponent], recordLength);
}

- (void)voiceRecordCancelledByUser:(KXVoiceHUD *)voiceHUD {
    NSLog(@"Voice recording cancelled for HUD: %@", voiceHUD);
}

#pragma mark - Emoticon Button & Insert Button

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
    
    // Sets the contact avatar.
    cell.contactAvatarImageView.image = [UIImage imageNamed:message.contactAvatar];
    if ([message.messageType isEqualToString:@"incoming"]) {
        [cell.contactAvatarImageView setFrame:CGRectMake(0.0f, CONTACT_AVATAR_PADDING_TOP_SPACE, CONTACT_AVATAR_IMAGE_VIEW_WIDTH, CONTACT_AVATAR_IMAGE_VIEW_HEIGHT)];
    } else if ([message.messageType isEqualToString:@"outgoing"]) {
        [cell.contactAvatarImageView setFrame:CGRectMake(cell.frame.size.width - CONTACT_AVATAR_IMAGE_VIEW_WIDTH, CONTACT_AVATAR_PADDING_TOP_SPACE, CONTACT_AVATAR_IMAGE_VIEW_WIDTH, CONTACT_AVATAR_IMAGE_VIEW_HEIGHT)];
    }
    
    // Sets the message content.
    cell.messageContentLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.messageContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.messageContentLabel.numberOfLines = 0;
    
    CGSize textSize = { MAX_MESSAGE_CONTENT_WIDTH, MAX_MESSAGE_CONTENT_HEIGHT };
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: cell.messageContentLabel.font, NSParagraphStyleAttributeName: paragraphStyle};
    CGSize size = [message.messageContent boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    cell.messageContentLabel.text = message.messageContent;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    if ([message.messageType isEqualToString:@"incoming"]) {
        [cell.messageContentLabel setFrame:CGRectMake(CONTACT_AVATAR_IMAGE_VIEW_WIDTH + MESSAGE_MARGIN + MESSAGE_PADDING_CALLOUT, MESSAGE_PADDING, size.width, size.height)];
        bgImage = [[UIImage imageNamed:@"MessageIncoming"] stretchableImageWithLeftCapWidth:MESSAGE_BACKGROUND_IMAGE_LEFT_CAP_WIDTH topCapHeight:MESSAGE_BACKGROUND_IMAGE_LEFT_CAP_HEIGHT];
        cell.messageBackgroundImageView.image = bgImage;
        [cell.messageBackgroundImageView setFrame:CGRectMake(cell.messageContentLabel.frame.origin.x - MESSAGE_PADDING_CALLOUT, cell.messageContentLabel.frame.origin.y - MESSAGE_PADDING + MESSAGE_PADDING_TOP_SPACE, size.width + MESSAGE_PADDING_CALLOUT + MESSAGE_PADDING, cell.messageContentLabel.frame.size.height + MESSAGE_PADDING * 2)];
    } else if ([message.messageType isEqualToString:@"outgoing"]) {
        [cell.messageContentLabel setFrame:CGRectMake(cell.frame.size.width - CONTACT_AVATAR_IMAGE_VIEW_WIDTH - MESSAGE_MARGIN - MESSAGE_PADDING_CALLOUT - size.width, MESSAGE_PADDING, size.width, size.height)];
        bgImage = [[UIImage imageNamed:@"MessageOutgoing"] stretchableImageWithLeftCapWidth:MESSAGE_BACKGROUND_IMAGE_LEFT_CAP_WIDTH topCapHeight:MESSAGE_BACKGROUND_IMAGE_LEFT_CAP_HEIGHT];
        cell.messageBackgroundImageView.image = bgImage;
        [cell.messageBackgroundImageView setFrame:CGRectMake(cell.messageContentLabel.frame.origin.x - MESSAGE_PADDING, cell.messageContentLabel.frame.origin.y - MESSAGE_PADDING + MESSAGE_PADDING_TOP_SPACE, size.width + MESSAGE_PADDING_CALLOUT + MESSAGE_PADDING, cell.messageContentLabel.frame.size.height + MESSAGE_PADDING * 2)];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KXMessage *message = [self.messages objectAtIndex:indexPath.row];

    CGSize textSize = { MAX_MESSAGE_CONTENT_WIDTH, MAX_MESSAGE_CONTENT_HEIGHT };
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f], NSParagraphStyleAttributeName: paragraphStyle};
    CGSize size = [message.messageContent boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    size.height += MESSAGE_PADDING * 2;
    
    CGFloat height = size.height + TABLE_VIEW_CELL_HEIGHT_SPACE;
    
    return height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    [self scrollTableView];
    
    return indexPath;
}

- (void)scrollTableView
{
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Message Delegate

- (void)newMessageReceived:(XMPPMessage *)message
{
    NSLog(@"Callback: New messsage received.");
    
    NSManagedObjectContext *context = [self managedObjectContext];
    KXMessage *msg = [NSEntityDescription insertNewObjectForEntityForName:@"KXMessage" inManagedObjectContext:context];
    
    msg.contactAvatar = @"yangyifeng.jpg";
    msg.contactName = @"杨义锋";
    msg.messageContent = message.body;
    msg.messageTimeReceived = [NSDate date];
    msg.messageType = @"incoming";
    [context insertObject:msg];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Data not inserted. %@, %@", error, [error userInfo]);
        return;
    }
    [self.messages addObject:msg];
    [self.chatTableView reloadData];
    [self scrollTableView];
}

#pragma mark - TURN Socket

- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket
{
    NSLog(@"TURN Connection succeeded!");
    NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
    [self.turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender
{
    NSLog(@"TURN Connection failed!");
    [self.turnSockets removeObject:sender];
}

@end
