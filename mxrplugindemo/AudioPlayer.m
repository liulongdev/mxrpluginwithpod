//
//  AudioPlayer.m
//  mxrpluginOpencv3
//
//  Created by Martin.Liu on 2019/3/27.
//  Copyright © 2019年 Martin.Liu. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer() <AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSInteger dontQueryCount;
@property (nonatomic, assign) NSInteger preIndex;
@end

@implementation AudioPlayer


- (instancetype)init
{
    if (self = [super init]) {
        _currentIndex = -1;
    }
    return self;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (currentIndex < 0) {
        self.dontQueryCount ++;
    }
    
    // 播放结束，如果摄像头一直没有动，则不继连续读，否则读。
    if (_currentIndex == -2 && self.preIndex == currentIndex && self.dontQueryCount < 1) {
        return;
    }
    
    
    if ( _currentIndex != currentIndex && currentIndex >= 0 && currentIndex <= 12) {
        _currentIndex = currentIndex;
        self.preIndex = currentIndex;
        [_player stop];
        _player.delegate = nil;
        _player = nil;
        
        NSString *url = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%ld", (long)currentIndex] ofType:@"mp3"];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:url] error:nil];
        _player.delegate = self;
        [_player prepareToPlay];
        [_player play];
        self.dontQueryCount = 0;
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _currentIndex = -2;
    _player.delegate = nil;
    _player = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    _currentIndex = -1;
    NSLog(@">>>>>> palyer error : %@", error);
}


@end
