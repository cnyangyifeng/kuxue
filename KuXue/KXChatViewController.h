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
#import "KXVoiceHUDDelegate.h"
#import "KXVoiceHUD.h"
#import "KXMessage.h"

#define CHAT_TOOLBAR_HEIGHT 45.0f
#define CHAT_TOOLBAR_LEFT_FIXED_SPACE -10.0f
#define CHAT_TOOLBAR_ESTIMATED_SPACE 106.0f
#define CHAT_TEXT_FIELD_HEIGHT 32.0f
#define CHAT_BUTTON_WIDTH 32.0f
#define CHAT_BUTTON_HEIGHT 32.0f
#define TABLE_VIEW_CELL_HEIGHT 72.0f

@interface KXChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KXVoiceHUDDelegate>

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
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;

@property (nonatomic) BOOL isAudioChatType;
@property (nonatomic) BOOL isAudioPlaying;

@end
