//
//  MXRRecognizeController.h
//  mxrpluginKit
//
//  Created by Martin.Liu on 2019/3/27.
//  Copyright © 2019年 Martin.Liu. All rights reserved.
//

#import <UIKit/UIkit.h>

@protocol MXRRecognizeControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MXRRecognizeActiveStatus) {
    MXRRecognizeActiveStatusSuccess,            // 在扫描页面扫描成功
    MXRRecognizeActiveStatusManualBack,         // 在扫描页面手动点击返回
};

@interface MXRRecognizeController : NSObject

/**
 单例
 */
+ (instancetype)instance;

/**
 在AppDelegate启动的时候调用,即application:didFinishLaunchingWithOptions:中调用
 */
+ (void)registerApp;

/**
 是否正在扫描的标志
 */
@property (nonatomic, readonly) BOOL isQuerying;

/**
 代理
 */
@property (nonatomic, weak) id<MXRRecognizeControllerDelegate> delegate;

/**
 开始扫描，主要方法。第一次调用会开启扫描页面进行扫描二维码激活设备，之后调用就开启扫描功能。

 @param keyWindow 主window，如果nil则取默认的window
 @param error 开启扫描出现的错误
 @return 开启成功返回YES，其他返回NO，
 */
- (BOOL)startRecognizeWithKeyWindow:(nullable UIWindow *)keyWindow error:(NSError **)error;

/**
 关闭扫描功能
 */
- (void)endRecognize;

/**
 返回扫描到的图片索引，以及该图片的得分。 （与delegate只需要任选一种）
 */
@property (nonatomic, copy) void (^ _Nullable queryCallBack)(NSError *error, NSInteger imgIndex, NSInteger imgScore);

/**
 返回扫描激活页面的结果（与delegate只需要任选一种）
 */
@property (nonatomic, copy) void (^ _Nullable activeCallBack)(MXRRecognizeActiveStatus status);

@end

@protocol MXRRecognizeControllerDelegate <NSObject>

/**
 扫描到匹配图片的代理
 
 @param recognize MXRRecognizeController对象
 @param imgIndex 扫描到的图片索引
 @param score 扫描图片匹配度的得分，得分越高表示越匹配
 */
- (void)recognizeController:(MXRRecognizeController *)recognize queryImgIndex:(NSInteger)imgIndex avgSocre:(NSInteger)score;

/**
 激活扫描页面的代理。
 MXRRecognizeActiveStatusSuccess表示扫描成功。
 MXRRecognizeActiveStatusManualBack表示用户手动点击返回按钮.
 
 @param recognize MXRRecognizeController对象
 @param status MXRRecognizeActiveStatus
 */
- (void)recognizeController:(MXRRecognizeController *)recognize activeStatus:(MXRRecognizeActiveStatus)status;

/**
 扫描错误的代理
 
 @param recognize MXRRecognizeController对象
 @param error NSError
 */
- (void)recognizeController:(MXRRecognizeController *)recognize didFail:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
