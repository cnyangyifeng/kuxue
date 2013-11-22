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

#define CHAT_TOOLBAR_HEIGHT 40.0f
#define CHAT_TOOLBAR_SPACE 110.0f
#define CHAT_TEXT_FIELD_HEIGHT 30.0f
#define CHAT_BUTTON_WIDTH 30.0f
#define CHAT_BUTTON_HEIGHT 30.0f

@interface KXChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *chatTableView;
@property (weak, nonatomic) UIToolbar *chatToolbar;
@property (weak, nonatomic) UIBarButtonItem *chatTypeButtonItem;
@property (weak, nonatomic) UIButton *chatTypeButton;
@property (weak, nonatomic) UIBarButtonItem *inputTextViewButtonItem;
@property (weak, nonatomic) UITextView *inputTextView;
@property (weak, nonatomic) UIBarButtonItem *smileyButtonItem;
@property (weak, nonatomic) UIButton *smileyButton;
@property (weak, nonatomic) UIBarButtonItem *insertButtonItem;
@property (weak, nonatomic) UIButton *insertButton;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;

@end
