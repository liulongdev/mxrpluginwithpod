//
//  mxrpluginKit.h
//  mxrpluginKit
//
//  Created by Martin.Liu on 2019/3/20.
//  Copyright © 2019年 Martin.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for mxrpluginKit.
FOUNDATION_EXPORT double mxrpluginKitVersionNumber;

//! Project version string for mxrpluginKit.
FOUNDATION_EXPORT const unsigned char mxrpluginKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <mxrpluginKit/PublicHeader.h>
#import <pthread.h>
static inline void mxr_dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#import "MXRRecognizeController.h"


#define MXRERRCODEDONTINITRAIN          1000001         // 没有初始化训练文件
#define MXRERRCODEDONTCHECKACCESS       1000002         // 没有验证是否有权限
#define MXRERRCODEDONTREGISTREACCESS    1000003         // 没有申请识别权限
#define MXRERRCODESERVEREUNKNOWN        1000004         // 服务端未知错误，请联系管理员
#define MXRERRCODEINVALID               1000005         // 无效的二维码
#define MXRERRCODEACTIVEOUT             1000005         // 超出申请次数
