//
//  AppDelegate.m
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "AppDelegate.h"
#import "LaunchpadViewController.h"
#import "MainViewController.h"
#import "SideViewController.h"
#import "FirstLoginViewController.h"
#import "EditPersonInfoViewController.h"
#import "BPush.h"

@interface AppDelegate ()
{
    LaunchpadViewController *lauchView;

    NSString *channel_id;
    NSString *user_id;
    
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if(SCREEN_HEIGHT > 480){
        _autoSizeScaleY = SCREEN_HEIGHT/568;
        _autoSizeScaleFont = SCREEN_WIDTH/320;
    }else{
        _autoSizeScaleY = 1.0;
        _autoSizeScaleFont = 1.0;
    }
    
    _mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    _mainViewController.hideBackButton = YES;
    _sideViewController = [[SideViewController alloc] initWithNibName:@"SideViewController" bundle:nil];
    _firstViewController = [[FirstLoginViewController alloc]initWithNibName:@"FirstLoginViewController" bundle:nil];
    _firstViewController.hideBackButton = YES;
    _deckController = [[IIViewDeckController alloc] initWithCenterViewController:[[UINavigationController alloc] initWithRootViewController:_mainViewController]
                                                                                   leftViewController:[IISideController autoConstrainedSideControllerWithViewController:_sideViewController]];
    
    self.window.rootViewController = _deckController;
    
    [self.window makeKeyAndVisible];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
//    NSString *bundleId = [infoDic objectForKey:@"CFBundleIdentifier"];
    _versionstring = [NSString stringWithFormat:@"%@.%@",[infoDic objectForKey:@"CFBundleShortVersionString"],[infoDic objectForKey:@"CFBundleVersion"]];//版本号加build号
    //启动push，用于设备收集和以后的推送服务
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        
        
    }else{
        //这里还是原来的代码 ios 8以下
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey:fnpF1TYtPpKkLr87G9jWsOfd
    [BPush registerChannel:launchOptions apiKey:@"fnpF1TYtPpKkLr87G9jWsOfd" pushMode:BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:NO isDebug:NO];

    // App 是用户点击推送消息启动
    NSDictionary *pushDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushDictionary) {
        NSLog(@"从消息启动:%@",pushDictionary);
        
        [BPush handleNotification:pushDictionary];
    }
    
    //注册ShareSdk
    [ShareSDK registerApp:@"11498c1fdc441"];
    
    [ShareSDK connectQQWithQZoneAppKey:@"1105311320"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectWeChatWithAppId:@"wx8cc8a254cca7d708" wechatCls:[WXApi class]];
    
    [ShareSDK importQQClass:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK importWeChatClass:[WXApi class]];
    
    
    //自动登录
    [self autoLogin];
    
    //启动页
    lauchView = [[LaunchpadViewController alloc]initWithNibName:@"LaunchpadViewController" bundle:nil];
    lauchView.view.frame = self.window.frame;
    [self.window addSubview:lauchView.view];
    [self.window bringSubviewToFront:lauchView.view];
    //5秒隐藏
    [self performSelector:@selector(hideLauchView) withObject:nil afterDelay:5.5f];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //获取push数量
    [self getPushCount];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//自动登录
- (void)autoLogin{
    
    if (![SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserSecret]) {
        
        return;
        
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserAcount] forKey:@"username"];
    [contentDic setObject:[SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserSecret] forKey:@"password"];
    [MYRequest requstWithDic:contentDic withUrl:API_Login withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            return ;
        }
        
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            return;
        }
        
        MyAppDelegate.userInfo = [resultDic objectForKey:@"user"];
        MyAppDelegate.classInfo = [resultDic objectForKey:@"class"];
        MyAppDelegate.logintoken = [resultDic objectForKey:@"login_token"];
        
        [SSKeychain setPassword:MyAppDelegate.userInfo[@"id"] forService:keyChainAccessGroup account:keyChainUserId];
        
        
        //发送通知，改变侧滑栏的头像信息
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshUserImage" object:nil];
        
        
    }];
}

- (void)hideLauchView{
    [lauchView.view removeFromSuperview];
    
    //判断是否登录
    if (!self.logintoken) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_firstViewController];
        [_mainViewController presentViewController:nav animated:YES completion:nil];

    }else{
        //判断是否完善信息并跳入完善信息界面
        if (([[self.userInfo objectForKey:@"head_icon"]isEqualToString:@""])||([[self.userInfo objectForKey:@"realname"]isEqualToString:@""])) {
            //进入个人信息编辑页面
            EditPersonInfoViewController *edit = [[EditPersonInfoViewController alloc]init];
            edit.isFromLogin = YES;
            [_mainViewController.navigationController pushViewController:edit animated:YES];
            
            return;
        }
        
        //首页刷新数据
        [_mainViewController refreshData];
        
    }
    
}

- (void)clearTmpPics
{
    [[SDImageCache sharedImageCache] clearDisk];
    
    [[SDImageCache sharedImageCache] clearMemory];//可有可无
        
}

//上传百度push信息
- (void)updateBPushInfo{
    if (!channel_id || !user_id || ![SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserAcount]) {
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserAcount] forKey:@"username"];
    [contentDic setObject:channel_id forKey:@"channelid"];
    [contentDic setObject:user_id forKey:@"userid"];
    [contentDic setObject:@"ios" forKey:@"os"];
    [contentDic setObject:self.versionstring forKey:@"version"];
    [contentDic setObject:@"1" forKey:@"os_type"];
    
    [MYRequest requstWithDic:contentDic withUrl:API_PUSH_Register withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            return ;
        }
        
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            return;
        }
        
        if ([resultDic[@"result"] boolValue] == YES) {
            ZLog(@"绑定成功!");
        }else{
            ZLog(@"绑定失败!");
        }
        
    }];
    
}

//注销百度push信息
- (void)logoutBPushInfo{
    if (!channel_id || !user_id || ![SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserAcount]) {
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserAcount] forKey:@"username"];
    [contentDic setObject:channel_id forKey:@"channelid"];
    [contentDic setObject:user_id forKey:@"userid"];
    
    [MYRequest requstWithDic:contentDic withUrl:API_PUSH_Logout withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            return ;
        }
        
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            return;
        }
        
        
    }];
    
}

//获取push数量
- (void)getPushCount{
    
    if (![SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserId]) {
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserId] forKey:@"uid"];
    
    [MYRequest requstWithDic:contentDic withUrl:API_PUSH_User_Notice_Count withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            return ;
        }
        
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            NSString *user_notice_count = [SSKeychain passwordForService:keyChainAccessGroup account:keyChainAppIconNumber];
            [self setAppIconNumber:user_notice_count.intValue];

            return;
        }
        
        NSString *user_notice_count = resultDic[@"user_notice_count"];
        [self setAppIconNumber:user_notice_count.intValue];
        NSString *vinfo_count = resultDic[@"vinfo_count"];
        self.VInfoCount = vinfo_count;
        NSString *notice_count = resultDic[@"notice_count"];
        self.NoticeCount = notice_count;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshNoreadView" object:nil];

    }];
    
}

#pragma mark - 获取devToken & 推送服务
// 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台 时调起
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)pushInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    NSLog(@"********** iOS7.0之后 background **********");
    //杀死状态下，直接跳转到跳转页面。
    if (application.applicationState == UIApplicationStateInactive)
    {
        //点击通知栏消息
        NSLog(@"applacation is unactive ===== %@",pushInfo);
        
        [_mainViewController getPushInfo:pushInfo];
        
    }
    // 应用在后台。当后台设置aps字段里的 content-available 值为 1 并开启远程通知激活应用的选项
    if (application.applicationState == UIApplicationStateBackground) {
        NSLog(@"background is Activated Application ");
        // 此处可以选择激活应用提前下载邮件图片等内容。
        
    }
    
    if (application.applicationState == UIApplicationStateActive) {
        ZLog(@"UIApplicationStateActive");
        //用户正在使用来了push消息
        //刷新push数量
        [self getPushCount];
        
        
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
    NSLog(@"backgroud : %@",pushInfo);
    
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
    [application registerForRemoteNotifications];
    
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"test:%@",deviceToken);
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
        ZLog(@"result = %@",result);
        NSDictionary *dic = result;
        if ([[dic allKeys] containsObject:@"response_params"]){
            //第一次启动应用
            channel_id = [dic[@"response_params"][@"channel_id"] copy];
            user_id = [dic[@"response_params"][@"user_id"] copy];
        }else{
            
            channel_id = [dic[@"channel_id"] copy];
            user_id = [dic[@"user_id"] copy];
            
        }
        
        //上传请求
        [self updateBPushInfo];
        
        // 网络错误
        if (error) {
            return ;
        }
        if (result) {
            // 确认绑定成功
            if ([result[@"error_code"]intValue]!=0) {
                return;
            }
            [BPush setTag:@"Mytag" withCompleteHandler:^(id result, NSError *error) {
                if (result) {
                    NSLog(@"设置tag成功");
                }
            }];
        }
    }];
    
    
    
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App 收到推送的通知
    [BPush handleNotification:userInfo];
    NSLog(@"********** ios7.0之前 **********");
    // 应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
        NSLog(@"acitve or background");
        //        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"收到一条消息" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        //        [alertView show];
    }
    else//杀死状态下，直接跳转到跳转页面。
    {
        
        
    }
    
    NSLog(@"%@",userInfo);
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    ZLog(@"localnotification");
    ZLog(@"%@",notification.userInfo);
    
    
}

- (void)showLocalNotifaction:(NSDictionary *)pushInfo{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        notification.fireDate=[NSDate date];
        //使用本地时区
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody=pushInfo[@"aps"][@"alert"];
        //通知提示音 使用默认的
        notification.soundName= UILocalNotificationDefaultSoundName;
        notification.alertAction=NSLocalizedString(@"", nil);
        //这个通知到时间时，你的应用程序右上角显示的数字。
        notification.applicationIconBadgeNumber = 1;
        //add key  给这个通知增加key 便于半路取消。nfkey这个key是我自己随便起的。
        // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:pushInfo[@"type"],@"type",nil];
        [notification setUserInfo:dict];
        
        ZLog(@"%@",notification);
        
        //启动这个通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
    }
}

-(void)setAppIconNumber:(int)iconNumber{
    
    [SSKeychain setPassword:[NSString stringWithFormat:@"%d",iconNumber] forService:keyChainAccessGroup account:keyChainAppIconNumber];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:iconNumber];
}

#pragma mark - ShareSDK
- (void)shareContext:(NSDictionary *)shareDic
{
    ZLog(@"%@",shareDic);
    NSString *imagePath;
    if ([shareDic objectForKey:@"image"]) {
        imagePath = [shareDic objectForKey:@"image"];
    }else{
        imagePath= [[NSBundle mainBundle] pathForResource:@"about_icon" ofType:@"png"];
    }
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[shareDic objectForKey:@"content"]
                                       defaultContent:@""
                                                image:[shareDic objectForKey:@"image"]?[ShareSDK imageWithUrl:imagePath]:[ShareSDK imageWithPath:imagePath]
                                                title:
                                     [shareDic objectForKey:@"title"]?
                                     [shareDic objectForKey:@"title"]:
                                     @"我们班"
                                                  url:
                                     [shareDic objectForKey:@"url"]?
                                     [shareDic objectForKey:@"url"]:
                                     @"https://itunes.apple.com/us/app/wo-men-ban/id1103157219?l=zh&ls=1&mt=8"
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"分享成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                                    [alertV show];
                                    
                                }else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!errorCode == %d, errorDescription == %@"), [error errorCode], [error errorDescription]);
//                                    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"分享失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
//                                    [alertV show];
                                }else if (state == SSResponseStateCancel)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!errorCode == %d, errorDescription == %@"), [error errorCode], [error errorDescription]);
//                                    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"提示" message:@"用户取消分享" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
//                                    [alertV show];
                                }
                            }];
    
    
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
    if (authList == nil)
    {
        authList = [NSMutableArray array];
    }
    
    NSString *platName = nil;
    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    switch (plat)
    {
        case ShareTypeSinaWeibo:
            platName = NSLocalizedString(@"TEXT_SINA_WEIBO", @"新浪微博");
            break;
        case ShareType163Weibo:
            platName = NSLocalizedString(@"TEXT_NETEASE_WEIBO", @"网易微博");
            break;
        case ShareTypeDouBan:
            platName = NSLocalizedString(@"TEXT_DOUBAN", @"豆瓣");
            break;
        case ShareTypeFacebook:
            platName = @"Facebook";
            break;
        case ShareTypeKaixin:
            platName = NSLocalizedString(@"TEXT_KAIXIN", @"开心网");
            break;
        case ShareTypeQQSpace:
            platName = NSLocalizedString(@"TEXT_QZONE", @"QQ空间");
            break;
        case ShareTypeRenren:
            platName = NSLocalizedString(@"TEXT_RENREN", @"人人网");
            break;
        case ShareTypeSohuWeibo:
            platName = NSLocalizedString(@"TEXT_SOHO_WEIBO", @"搜狐微博");
            break;
        case ShareTypeTencentWeibo:
            platName = NSLocalizedString(@"TEXT_TENCENT_WEIBO", @"腾讯微博");
            break;
        case ShareTypeTwitter:
            platName = @"Twitter";
            break;
        case ShareTypeInstapaper:
            platName = @"Instapaper";
            break;
        case ShareTypeYouDaoNote:
            platName = NSLocalizedString(@"TEXT_YOUDAO_NOTE", @"有道云笔记");
            break;
        case ShareTypeGooglePlus:
            platName = @"Google+";
            break;
        case ShareTypeLinkedIn:
            platName = @"LinkedIn";
            break;
        default:
            platName = NSLocalizedString(@"TEXT_UNKNOWN", @"未知");
    }
    
    id<ISSPlatformUser> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    BOOL hasExists = NO;
    for (int i = 0; i < [authList count]; i++)
    {
        NSMutableDictionary *item = [authList objectAtIndex:i];
        ShareType type = (ShareType)[[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
            hasExists = YES;
            break;
        }
    }
    
    if (!hasExists)
    {
        NSDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 platName,
                                 @"title",
                                 [NSNumber numberWithInteger:plat],
                                 @"type",
                                 [userInfo nickname],
                                 @"username",
                                 nil];
        [authList addObject:newItem];
    }
    
    [authList writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
}
#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    
}

-(void) onResp:(BaseResp*)resp
{
    
}
- (NSString *)md5HexDigest:(NSDictionary *)dict
{
    //字典排序
    NSArray *keys = [dict allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableString *dicString = [NSMutableString string];
    for (int i = 0; i < sortedArray.count; i ++) {
        [dicString appendFormat:@"%@=%@",sortedArray[i],dict[sortedArray[i]]];
    }
    [dicString appendString:MD5KEY];
    NSLog(@"dicString : %@",dicString);
    
    //md5加密
    const char* str = [dicString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end
