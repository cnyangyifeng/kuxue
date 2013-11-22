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
#import "KXMessage.h"

#define CHAT_TOOLBAR_HEIGHT 44.0f
#define CHAT_TOOLBAR_SPACE 110.0f
#define CHAT_TEXT_FIELD_HEIGHT 32.0f
#define CHAT_BUTTON_WIDTH 32.0f
#define CHAT_BUTTON_HEIGHT 32.0f

@interface KXChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *chatTableView;
@property (strong, nonatomic) UIToolbar *chatToolbar;
@property (strong, nonatomic) UIBarButtonItem *fixedToolbarButtonItemSpace;
@property (strong, nonatomic) UIBarButtonItem *chatTypeButtonItem;
@property (strong, nonatomic) UIButton *chatTypeButton;
@property (strong, nonatomic) UIBarButtonItem *talkButtonItem;
@property (strong, nonatomic) UIButton *talkButton;
@property (strong, nonatomic) UIBarButtonItem *inputTextViewButtonItem;
@property (strong, nonatomic) UITextView *inputTextView;
@property (strong, nonatomic) UIBarButtonItem *smileyButtonItem;
@property (strong, nonatomic) UIButton *smileyButton;
@property (strong, nonatomic) UIBarButtonItem *insertButtonItem;
@property (strong, nonatomic) UIButton *insertButton;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;

@property (nonatomic) BOOL isAudioChat;

@end
