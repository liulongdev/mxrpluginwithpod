//
//  MXRRecognizeController.h
//  mxrpluginKit
//
//  Created by Martin.Liu on 2019/3/27.
//  Copyright © 2019年 Martin.Liu. All rights reserved.
//

#import <UIKit/UIkit.h>

@protocol MXRRecognizeControllerDelegate;

typedef NS_ENUM(NSUInteger, MXRRecognizeActiveStatus) {
    MXRRecognizeActiveStatusSuccess,            // 在扫描页面扫描成功
    MXRRecognizeActiveStatusManualBack,         // 在扫描页面手动点击返回
};

@interface MXRBookRecogResult : NSObject
@property (nonatomic, assign, readonly) NSInteger bookFlag __deprecated_msg("unavailable");       // 表示第几本书，索引从0开始
@property (nonatomic, assign, readonly) NSInteger bookPagePart __deprecated_msg("unavailable");   // 一整页的那一块，主要指三等分的书籍，左边为0，中间为1，右边为2， 默认-1

@property (nonatomic, assign, readonly) NSInteger bookPageIndex __deprecated_msg("unavailable");  // 表示页面，由编辑器编辑所得
@property (nonatomic, strong, readonly) NSString *pageName; // 表示marker页的名称
@property (nonatomic, assign, readonly) BOOL isCover;  // 表示是否扫描到封面, 扫描到封面值是YES，否则NO
@property (nonatomic, strong, readonly) NSString *path;         // 对应的path
@property (nonatomic, assign, readonly) NSString *bookGUID;     // 表示图书标识
@end

typedef NS_OPTIONS(NSInteger, MXRRecognizeStatus) {
    MXREncodingTypeMask = 0xFFFF,
    MXRRecognizeStatusNone = 0,
    MXRRecognizeStatusPreparingMask = 0x000F, // 准备
    MXRRecognizeStatusPreparingCover = 0x0001,
    MXRRecognizeStatusPreparingBookMarker = 0x0002,
    MXRRecognizeStatusQueryingMask = 0x00F0,    // 识别
    MXRRecognizeStatusQueryingCover = 0x0010,
    MXRRecognizeStatusQueryingMarker = 0x0020,
};

@interface MXRRecognizeController : NSObject

/**
 单例
 */
+ (instancetype)instance;

/**
 在AppDelegate启动的时候调用,即application:didFinishLaunchingWithOptions:中调用，以后版本会删除。
 */
+ (void)registerApp __deprecated_msg("use registerWithAppId:");

/**
 在AppDelegate启动的时候调用,即application:didFinishLaunchingWithOptions:中调用
 */
+ (void)registerWithAppId:(NSString *)appId;

/**
 是否正在扫描的标志
 */
@property (nonatomic, readonly) BOOL isQuerying;

/**
 扫描图书的状态
 */
@property (nonatomic, readonly) MXRRecognizeStatus status;

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
- (BOOL)startRecognizeWithKeyWindow:(UIWindow *)keyWindow error:(NSError **)error;

/**
 关闭扫描功能
 */
- (void)endRecognize;

/**
 返回扫描到的图片索引，以及该图片的得分。 （与delegate只需要任选一种）
 note：以后将弃用
 */
@property (nonatomic, copy) void (^queryBooksCallBack)(NSError *error, NSInteger bookFlag, NSInteger imgIndex, NSInteger imgScore) __deprecated_msg("use queryBookRecogResult");

/**
 返回扫描到的图片索引，以及该图片的得分。 （与delegate只需要任选一种）
 */
@property (nonatomic, copy) void (^queryBookRecogResult)(NSError *error, MXRBookRecogResult *bookRecogResult);

/**
 下载图书封面的进度
 */
@property (nonatomic, copy) void (^loadBookCoverProgress)(BOOL isFinished, CGFloat progress);

/**
 加载图书训练文件。
 先从本地寻找加载，如果没有，则下载后加载。
 */
@property (nonatomic, copy) void (^loadBookProgress)(NSError *error, NSString *bookGUID, CGFloat progress);

/**
 返回扫描激活页面的结果（与delegate只需要任选一种） 下个版本将会删除此方法
 */
@property (nonatomic, copy) void (^activeCallBack)(MXRRecognizeActiveStatus status) __deprecated_msg("use activeDeviceCallBack");

/**
 返回扫描激活页面的结果（与delegate只需要任选一种）
 */
@property (nonatomic, copy) void (^activeDeviceCallBack)(MXRRecognizeActiveStatus status, NSString *deviceId,  NSString *code);

@end

@protocol MXRRecognizeControllerDelegate <NSObject>
@optional
/**
 扫描到匹配图片的代理
 
 @param recognize MXRRecognizeController对象
 @param imgIndex 扫描到的图片索引
 @param score 扫描图片匹配度的得分，得分越高表示越匹配
 note: 下个版本将会删除此方法
 */
- (void)recognizeController:(MXRRecognizeController *)recognize bookFlag:(NSInteger)bookFlag queryImgIndex:(NSInteger)imgIndex avgSocre:(NSInteger)score __deprecated_msg("use recognizeController:bookRecogResult:");

/**
 扫描到匹配图片的代理
 
 @param recognize MXRRecognizeController对象
 @param imgIndex 扫描到的图片索引
 @param score 扫描图片匹配度的得分，得分越高表示越匹配
 */
- (void)recognizeController:(MXRRecognizeController *)recognize bookRecogResult:(MXRBookRecogResult *)bookRecogResult;

/**
 激活扫描页面的代理。
 MXRRecognizeActiveStatusSuccess表示扫描成功。
 MXRRecognizeActiveStatusManualBack表示用户手动点击返回按钮.
 
 @param recognize MXRRecognizeController对象
 @param status MXRRecognizeActiveStatus
 note：下个版本将会删除此方法
 */
- (void)recognizeController:(MXRRecognizeController *)recognize activeStatus:(MXRRecognizeActiveStatus)status __deprecated_msg("use recognizeController:activeStatus:deviceId:code:");

/**
 激活扫描页面的代理。
 MXRRecognizeActiveStatusSuccess表示扫描成功。
 MXRRecognizeActiveStatusManualBack表示用户手动点击返回按钮.
 
 @param recognize MXRRecognizeController对象
 @param status MXRRecognizeActiveStatus
 @param deviceId 设备标识
 @param code 激活码
 */
- (void)recognizeController:(MXRRecognizeController *)recognize activeStatus:(MXRRecognizeActiveStatus)status deviceId:(NSString *)deviceId code:(NSString *)code;

/**
 扫描错误的代理
 
 @param recognize MXRRecognizeController对象
 @param error NSError
 */
- (void)recognizeController:(MXRRecognizeController *)recognize didFail:(NSError *)error;

@end
