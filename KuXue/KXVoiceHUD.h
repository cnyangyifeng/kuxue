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

#define HUD_SIZE 200
#define STOP_BUTTON_HEIGHT 50
#define SOUND_METER_COUNT 40
#define WAVE_UPDATE_FREQUENCY 0.05f
#define RECORD_DURATION 120.0f

@interface KXVoiceHUD : UIView <AVAudioRecorderDelegate> {
    UIButton *stopButton;
    UIImage *micImage;
    int soundMeters[40];
    CGRect hudRect;
    
	NSMutableDictionary *recordSettings;
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
- (void)commitRecording;
- (void)playRecording:(NSURL *)url;

@end