//
//  KXChatViewController.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/18/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DAKeyboardControl/DAKeyboardControl.h>
#import "KXChatTableViewCell.h"
#import "KXContact.h"
#import "KXMessage.h"
#import "KXMessageDelegate.h"
#import "KXUser.h"
#import "KXViewController.h"
#import "KXVoiceHUDDelegate.h"
#import "KXVoiceHUD.h"
#import "TURNSocket.h"

#define CHAT_TOOLBAR_HEIGHT 45.0f
#define CHAT_TOOLBAR_LEFT_FIXED_SPACE -10.0f
#define CHAT_TOOLBAR_ESTIMATED_SPACE 106.0f
#define CHAT_TEXT_FIELD_HEIGHT 32.0f
#define CHAT_BUTTON_WIDTH 32.0f
#define CHAT_BUTTON_HEIGHT 32.0f
#define TABLE_VIEW_CELL_HEIGHT_SPACE 30.0f
#define CONTACT_AVATAR_IMAGE_VIEW_WIDTH 32.0f
#define CONTACT_AVATAR_IMAGE_VIEW_HEIGHT 32.0f
#define CONTACT_AVATAR_PADDING_TOP_SPACE 3.0f
#define MESSAGE_BACKGROUND_IMAGE_LEFT_CAP_WIDTH 18
#define MESSAGE_BACKGROUND_IMAGE_LEFT_CAP_HEIGHT 3
#define MESSAGE_MARGIN 3.0f
#define MESSAGE_PADDING 10.0f
#define MESSAGE_PADDING_TOP_SPACE 2.0f
#define MESSAGE_PADDING_CALLOUT 20.0f
#define MAX_MESSAGE_CONTENT_WIDTH 230.0f
#define MAX_MESSAGE_CONTENT_HEIGHT 10000.0f

@interface KXChatViewController : KXViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, KXVoiceHUDDelegate, KXMessageDelegate>

@property (strong, nonatomic) UITableView *chatTableView;
@property (strong, nonatomic) UIToolbar *chatToolbar;
@property (strong, nonatomic) UIBarButtonItem *fixedToolbarButtonItemSpace;
@property (strong, nonatomic) UIBarButtonItem *chatTypeButtonItem;
@property (strong, nonatomic) UIButton *chatTypeButton;
@property (strong, nonatomic) UIBarButtonItem *talkButtonItem;
@property (strong, nonatomic) UIButton *talkButton;
@property (strong, nonatomic) UIBarButtonItem *inputTextFieldButtonItem;
@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UIBarButtonItem *emoticonOrAudioPlayButtonItem;
@property (strong, nonatomic) UIButton *emoticonOrAudioPlayButton;
@property (strong, nonatomic) UIBarButtonItem *insertOrAudioSendButtonItem;
@property (strong, nonatomic) UIButton *insertOrAudioSendButton;

@property (strong, nonatomic) KXVoiceHUD *talkHud;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *turnSockets;

@property (nonatomic) BOOL isAudioChatType;

@property (strong, nonatomic) KXContact *contact;

- (void)sendMessage;

@end
