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
        
        /// 通知不建议使用，只是调试使用的， 正式的SDK不会通知。
        __weak __typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:@"MXRQUERYCOVER" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf showTitle:@"正在扫描封面"];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"MXRQUERYBOOK" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf showTitle:@"正在扫描marker"];
        }];
        
#ifndef USERECOGNIZEDELEGATE
        [MXRRecognizeController instance].queryBookRecogResult = ^(NSError *error, MXRBookRecogResult *bookRecogResult) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                NSLog(@">>>> block error %@", error);
            } else {
                [strongSelf showBookRecogResult:bookRecogResult];
            }
        };
        
        [MXRRecognizeController instance].activeDeviceCallBack = ^(MXRRecognizeActiveStatus status, NSString *deviceId, NSString *code) {
            if (status == MXRRecognizeActiveStatusSuccess) {
                NSLog(@"激活成功, deviceId: %@, code : %@", deviceId, code);
            } else if (status == MXRRecognizeActiveStatusManualBack) {
                NSLog(@"用户手动返回");
            };
        };
        
        [MXRRecognizeController instance].loadBookProgress = ^(NSError *error, NSString *bookGUID, CGFloat progress) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                NSLog(@">>>>> load bookGUID<%@> error : %@", bookGUID, error);
            } else {
                NSString *title = [NSString stringWithFormat:@"下载图书进度：%.2f%%", progress * 100];
                strongSelf.title = title;
            }
        };
        
#endif
        NSLog(@">>>>> start recognize : %d", result);
    }
}

#pragma mark - Delegate
- (void)recognizeController:(MXRRecognizeController *)recognize bookRecogResult:(MXRBookRecogResult *)bookRecogResult
{
    [self showBookRecogResult:bookRecogResult];
}

- (void)recognizeController:(MXRRecognizeController *)recognize activeStatus:(MXRRecognizeActiveStatus)status deviceId:(NSString *)deviceId code:(NSString *)code
{
    if (status == MXRRecognizeActiveStatusSuccess) {
        NSLog(@"激活成功, deviceId: %@, code : %@", deviceId, code);
    } else if (status == MXRRecognizeActiveStatusManualBack) {
        NSLog(@"用户手动返回");
    };
}
    
- (void)recognizeController:(MXRRecognizeController *)recognize didFail:(NSError *)error
{
    NSLog(@">>> delegate error : %@", error);
}

///
- (void)showTitle:(NSString *)title
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTitle) object:nil];
    [self performSelector:@selector(hiddenTitle) withObject:nil afterDelay:2];
    self.title = title;
}

- (void)showBookRecogResult:(MXRBookRecogResult *)result
{
    [self _showMsg:[NSString stringWithFormat:@"%@\n%@,url:%@", result.bookGUID, result.pageName, result.path]];
}

- (void)_showMsg:(NSString *)msg
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTipLabel) object:nil];
    [self performSelector:@selector(hiddenTipLabel) withObject:nil afterDelay:2];
    self.pageTipLabel.text = msg;
    static int count = 0;
    count ++;
    UIColor *color = nil;
    switch (count % 3) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1 :
            color = [UIColor greenColor];
            break;
        case 2:
            color = [UIColor blueColor];
            break;
        default:
            color = [UIColor yellowColor];
            break;
    }
    self.pageTipLabel.textColor = color;
}

- (void)showBookFlag:(NSInteger)bookFlag imgIndex:(NSInteger)imgIndex imgScore:(NSInteger)imgScore
{
    [self _showMsg:[NSString stringWithFormat:@"%ld,%ld,%ld", (long)bookFlag, (long)imgIndex, (long)imgScore]];
}

- (void)hiddenTipLabel
{
    self.pageTipLabel.text = nil;
}

- (void)hiddenTitle
{
    self.title = nil;
}


@end
