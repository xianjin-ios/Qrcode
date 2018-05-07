//
//  AppDelegate.h
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IISideController.h"
#import "IIViewDeckController.h"
#import "IIWrapController.h"

#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApiObject.h"

#import "SSKeychain.h"
#define keyChainAccessGroup @"com.xkdx.OurClass"
#define keyChainUserAcount @"userid"
#define keyChainUserSecret @"usersecret"
#define keyChainUserId @"uid"
#define keyChainAppIconNumber @"appiconnumber"

@class SideViewController;
@class MainViewController;
@class FirstLoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>
{
    //微信分享
    enum WXScene _scene;
    
}

@property (strong, nonatomic) UIWindow *window;

//屏幕适配比例
@property (nonatomic,assign)double autoSizeScaleY;
@property (nonatomic,assign)double autoSizeScaleFont;

@property (strong, nonatomic) SideViewController *sideViewController;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) FirstLoginViewController *firstViewController;
@property (strong, nonatomic) IIViewDeckController *deckController;

//个人信息
@property (nonatomic,retain) NSDictionary *userInfo;
@property (nonatomic,retain) NSDictionary *classInfo;
@property (nonatomic,retain) NSString *logintoken;
//版本号加build号
@property (nonatomic,retain) NSString *versionstring;

- (void)shareContext:(NSDictionary *)shareDic;//分享

- (NSString *)md5HexDigest:(NSDictionary *)dict;


//绑定百度push
- (void)updateBPushInfo;
//注销百度push
- (void)logoutBPushInfo;

//获取push数量
- (void)getPushCount;
@property (nonatomic,retain) NSString *VInfoCount;
@property (nonatomic,retain) NSString *NoticeCount;

//设置appIconNumber
- (void)setAppIconNumber:(int)number;

@end

