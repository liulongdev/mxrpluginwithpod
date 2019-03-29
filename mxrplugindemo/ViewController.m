//
//  ViewController.m
//  mxrplugindemo
//
//  Created by Martin.Liu on 2019/3/29.
//  Copyright © 2019年 Martin.Liu. All rights reserved.
//

#import "ViewController.h"
#import <MXRRecognizeController.h>
#import "AudioPlayer.h"

//#define USERECOGNIZEDELEGATE

@interface ViewController () <MXRRecognizeControllerDelegate>
@property (nonatomic, strong) AudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = [[AudioPlayer alloc] init];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startRecognize)];
    [self.view addGestureRecognizer:gesture];
#ifdef USERECOGNIZEDELEGATE
    [MXRRecognizeController instance].delegate = self;
#endif
    
}

- (void)startRecognize
{
    if ([MXRRecognizeController instance].isQuerying) {
        [[MXRRecognizeController instance] endRecognize];
    } else {
        BOOL result = [[MXRRecognizeController instance] startRecognizeWithKeyWindow:nil error:nil];
#ifndef USERECOGNIZEDELEGATE
        __weak __typeof(self) weakSelf = self;
        [MXRRecognizeController instance].queryCallBack = ^(NSError * _Nonnull error, NSInteger imgIndex, NSInteger imgScore) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                NSLog(@">>>> block error %@", error);
            } else {
                strongSelf.player.currentIndex = imgIndex;
                NSLog(@">>>>> block imgIndex : %ld, imgScore: %ld", (long)imgIndex, (long)imgScore);
            }
        };
#endif
        NSLog(@">>>>> start recognize : %d", result);
    }
}

#pragma mark - Delegate
- (void)recognizeController:(MXRRecognizeController *)recognize queryImgIndex:(NSInteger)imgIndex avgSocre:(NSInteger)score
{
    NSLog(@">>>>> delegate imgIndex : %ld, imgScore: %ld", (long)imgIndex, (long)score);
    self.player.currentIndex = imgIndex;
}
    
- (void)recognizeController:(MXRRecognizeController *)recognize didFail:(NSError *)error
{
    NSLog(@">>> delegate error : %@", error);
}

@end
