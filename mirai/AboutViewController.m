//
//  AboutViewController.m
//  mirai
//
//  Created by Zhao Zhongqi on 2021/8/18.
//

#import "AboutViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AboutViewController ()

@end

AVAudioPlayer* player;

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onBackgroundSwitchValueChanged:(UISwitch *)sender {
    // Handle Interruption?
    if ([sender isOn]) {
        if (player && [player isPlaying]) return;
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setMode:AVAudioSessionModeDefault error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        if (@available(iOS 14.5, *)) {
            [session setPrefersNoInterruptionsFromSystemAlerts:YES error:nil];
        }
        [session setActive:YES error:nil];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"music" withExtension:@"mp3"] error:nil];
        [player setVolume:0.0];
        [player prepareToPlay];
        player.numberOfLoops = -1;
        [player play];
        
        if(![player isPlaying]) {
            sender.on = NO;
        }
        
    } else {
        if (!player || ![player isPlaying]) return;
        [player stop];
        player = nil;
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
    }
}



@end

