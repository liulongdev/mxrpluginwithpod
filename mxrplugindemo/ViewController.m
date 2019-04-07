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
#import <NSObject+MAREX.h>
//#define USERECOGNIZEDELEGATE

@interface ViewController () <MXRRecognizeControllerDelegate>
@property (nonatomic, strong) AudioPlayer *player;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UILabel *pageTipLabel;
@property (nonatomic, copy) MARCancelBlockToken blocktoken;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageTipLabel.text = nil;
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

- (void)setPageValue:(NSInteger)pageIndex
{
    if (pageIndex > -1) {
        self.pageTipLabel.text = [NSString stringWithFormat:@"%ld", (long)pageIndex];
        if (_blocktoken) {
            [NSObject mar_cancelBlock:_blocktoken];
            _blocktoken = NULL;
        }
        __weak __typeof(self) weakSelf = self;
        self.blocktoken = [self mar_gcdPerformAfterDelay:2 usingBlock:^(id  _Nonnull objSelf) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.pageTipLabel.text = nil;
        }];
    }
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
        [MXRRecognizeController instance].queryBooksCallBack = ^(NSError * _Nonnull error, NSInteger bookFlag, NSInteger imgIndex, NSInteger imgScore) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                NSLog(@">>>> block error %@", error);
            } else {
                NSString *msg = nil;
                if (imgIndex > -1) {
                    if (imgIndex >= 9) {
                        // 对具体的书籍进行页码封装
                        switch (bookFlag) {
                            case 0:
                                imgIndex -= 9;
                                break;
                            case 1:
                            case 3:
                                if (imgIndex <= 11) {
                                    imgIndex = 0;
                                } else {
                                    imgIndex = (imgIndex -11) / 3;
                                }
                                break;
                            default:
                                imgIndex = (imgIndex - 9) / 3;
                                break;
                        }
                        msg = [NSString stringWithFormat:@"扫描到第%ld本书,第%ld页！", (long)bookFlag, (long)(imgIndex + 1)];
                    } else {
                        msg = [NSString stringWithFormat:@"扫描到%ld本书封面", (long)bookFlag];
                    }
                    if (msg) {
                        [self setPageValue:imgIndex + 1];
                        ShowSuccessMessage(msg, Duration_Normal);
                    }
                }
                //                strongSelf.player.currentIndex = imgIndex;
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
//    self.player.currentIndex = imgIndex;
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
