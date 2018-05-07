//
//  BaseViewController.h
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OurClass_Prefix.pch"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "SSKeychain.h"
#import "MBProgressHUD.h"
#import "UIImage+FixRotation.h"
#import "UIColor+Expanded.h"
#import "ChineseToPinyin.h"
#import "UIImage+AdjustSize.h"

#import "WeUIImageView.h"
#import "WeButton.h"
#import "WeUILabel.h"
#import "WeUITextField.h"
#import "WeUIView.h"

#import <CommonCrypto/CommonDigest.h>//md5

#import "HDImageObject.h"

#import "MYRequest.h"



#define DefaultTitleFont 12*(MyAppDelegate.autoSizeScaleFont)
#define DefaultContentFont 10*(MyAppDelegate.autoSizeScaleFont)
#define DefaultBtnFont 13*(MyAppDelegate.autoSizeScaleFont)

//刷新前页数据
typedef void (^RefreshBlock)(void);

@interface BaseViewController : UIViewController<UIAlertViewDelegate>
{
    //刷新班级信息页的block
    RefreshBlock refreshBlock;
    
    
    MBProgressHUD *HUD;

    UITapGestureRecognizer *tap;
    
}

- (void)setRefreshBlock : (RefreshBlock)block;

@property (nonatomic,assign) BOOL hideBackButton;

- (void)cancelTapHideKeyBoard:(BOOL)cancel;
- (void)dismissKeyboard;

//是否能显示侧栏
- (void)setEnabledSideView:(BOOL)iscan;

//返回操作
- (void)goBack:(id)sender;
- (void)hideBackButton:(BOOL)hide;

//HUD
- (void)showHUD;
- (void)hideHUD;

//弹出消息
- (void)showAlert:(NSString *)message withTitle:(NSString *)title haveCancelButton:(BOOL)cancel;


//侧栏
- (void)showSideView;
- (void)hideSideView;

//验证规则
- (BOOL)isValidPassword : (NSString *)pass;
- (BOOL)isValidPhone : (NSString *)phone;
- (BOOL)isValidCode : (NSString *)code;

//字符串转换为时间戳
-(NSString*)stringToStamp:(NSString*)strTime format:(NSString*)format;

//时间戳转换为时间
-(NSDate*)stampToDate:(NSString*)strStamp;
//时间戳转换为时间(返回格式化好的字符串)
-(NSString *)stampToDate:(NSString*)strStamp format:(NSString *)format;


- (void)showDatePickerView;

- (void)hideDatePickerView;

//获取未读提示
- (UIView *)getNoReadViewWithSuperFrame:(CGRect)rect;

@end
