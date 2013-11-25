//
//  KXVoiceHUDDelegate.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/23/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KXVoiceHUD;

@protocol KXVoiceHUDDelegate <NSObject>

@optional

- (void)KXVoiceHUD:(KXVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength;
- (void)voiceRecordCancelledByUser:(KXVoiceHUD *)voiceHUD;

@end
