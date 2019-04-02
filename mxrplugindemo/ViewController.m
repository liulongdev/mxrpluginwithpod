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
#import <MARGlobalManager.h>
#define USERECOGNIZEDELEGATE

@interface ViewController () <MXRRecognizeControllerDelegate>
@property (nonatomic, strong) AudioPlayer *player;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipLabel.text = @"点击扫描";
    _player = [[AudioPlayer alloc] init];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startRecognize)];
    [self.view addGestureRecognizer:gesture];
    [self addObserver];
#ifdef USERECOGNIZEDELEGATE
    [MXRRecognizeController instance].delegate = self;
#endif
}

- (void)dealloc
{
    [[MXRRecognizeController instance] removeObserver:self forKeyPath:@"isQuerying"];
}

- (void)addObserver
{
    [[MXRRecognizeController instance] addObserver:self forKeyPath:@"isQuerying" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isQuerying"]) {
        self.tipLabel.text = [change[@"new"] boolValue] ? @"正在扫描" : @"开始扫描 ";
    }
    NSLog(@"J>>>> keyPath : %@， change ： %@", keyPath, change);
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
                if (imgIndex > -1) {
                    NSString *msg = [NSString stringWithFormat:@"扫描到第%ld页！", (long)(imgIndex + 1)];
                    ShowSuccessMessage(msg, Duration_Normal);
                }
                strongSelf.player.currentIndex = imgIndex;
                NSLog(@">>>>> block imgIndex : %ld, imgScore: %ld", (long)imgIndex, (long)imgScore);
            }
        };
        
        [MXRRecognizeController instance].activeCallBack = ^(MXRRecognizeActiveStatus status) {
            if (status == MXRRecognizeActiveStatusSuccess) {
                NSLog(@"激活成功");
            } else if (status == MXRRecognizeActiveStatusManualBack) {
                NSLog(@"用户手动返回");
            };
        };
#endif
        NSLog(@">>>>> start recognize : %d", result);
    }
}

#pragma mark - Delegate
- (void)recognizeController:(MXRRecognizeController *)recognize queryImgIndex:(NSInteger)imgIndex avgSocre:(NSInteger)score
{
    if (imgIndex > -1) {
        NSString *msg = [NSString stringWithFormat:@"扫描到第%ld页！", (long)(imgIndex + 1)];
        ShowSuccessMessage(msg, Duration_Normal);
    }
    NSLog(@">>>>> delegate imgIndex : %ld, imgScore: %ld", (long)imgIndex, (long)score);
    self.player.currentIndex = imgIndex;
}

- (void)recognizeController:(MXRRecognizeController *)recognize activeStatus:(MXRRecognizeActiveStatus)status
{
    if (status == MXRRecognizeActiveStatusSuccess) {
        NSLog(@"激活成功");
    } else if (status == MXRRecognizeActiveStatusManualBack) {
        NSLog(@"用户手动返回");
    };
}
    
- (void)recognizeController:(MXRRecognizeController *)recognize didFail:(NSError *)error
{
    NSLog(@">>> delegate error : %@", error);
}

@end
