//
//  KXVoiceHUD.h
//  KuXue
//
//  Created by Yang Yi Feng on 11/23/13.
//  Copyright (c) 2013 kuxue.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "KXVoiceHUDDelegate.h"

#define HUD_SIZE                270
#define CANCEL_BUTTON_HEIGHT    50
#define SOUND_METER_COUNT       40
#define WAVE_UPDATE_FREQUENCY   0.05

@interface KXVoiceHUD : UIView <AVAudioRecorderDelegate> {
    UIButton *btnCancel;
    UIImage *imgMicrophone;
    int soundMeters[40];
    CGRect hudRect;
    
	NSMutableDictionary *recordSetting;
	NSString *recorderFilePath;
	AVAudioRecorder *recorder;
	
	SystemSoundID soundID;
	NSTimer *timer;
    
    float recordTime;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) id<KXVoiceHUDDelegate> delegate;
@property AVAudioPlayer *player;

- (id)initWithParentView:(UIView *)view;
- (void)startForFilePath:(NSString *)filePath;
- (void)cancelRecording;
- (void)setCancelButtonTitle:(NSString *)title;
- (void)playRecording:(NSURL *)url;

@end