//
//  MYRequest.m
//  ASINetPackaging
//
//  Created by siqiyang on 16/2/22.
//  Copyright © 2016年 mengxianjin. All rights reserved.
//

#import "MYRequest.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"


#define MyAppDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@implementation MYRequest

+ (NSInteger )checkNetStatus{
    NetworkStatus internetStatus=[[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    if (internetStatus == NotReachable ){
        //无网络
        [ASIHTTPRequest setDefaultTimeOutSeconds:5];
        [ASIFormDataRequest setDefaultTimeOutSeconds:5];
        return 0;
    }else if(( internetStatus == ReachableViaWWAN ) && (internetStatus != ReachableViaWiFi) ){
        //手机网络
        [ASIHTTPRequest setDefaultTimeOutSeconds:15];
        [ASIFormDataRequest setDefaultTimeOutSeconds:15];
        return 1;
    }else if (( internetStatus == ReachableViaWWAN ) && (internetStatus == ReachableViaWiFi )){
        //WiFi网络
        [ASIHTTPRequest setDefaultTimeOutSeconds:10];
        [ASIFormDataRequest setDefaultTimeOutSeconds:10];
        return 2;
    }else{
        //其他网络
        [ASIHTTPRequest setDefaultTimeOutSeconds:5];
        [ASIFormDataRequest setDefaultTimeOutSeconds:5];
        return 3;
    }
}

+ (void)requstWithDic:(NSDictionary *)dic withUrl:(NSString *)urlStr withRequestMethod:(NSString *)method isHTTPS:(BOOL)ishttps isMultiPart:(BOOL)ismultipart andMultiPartFileUrl:(NSString *)fileurl andGetData:(void (^)(id data, NSError *error))block{

    //排错
    if (dic == nil || urlStr == nil || method == nil) {
        NSLog(@"requestData has error!");
        return;
    }
    if (ismultipart == YES && fileurl == nil) {
        NSLog(@"multipartfile has error!");
        return;
    }
    //
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
    [contentDic setObject:@"1" forKey:@"os"];//1-iOS,2-Android
    [contentDic setObject:MyAppDelegate.versionstring forKey:@"vn"];
    [contentDic setObject:@"2" forKey:@"plat"];//1-企业版，2-AppStore
    //有login_tocken 就设置
    if(MyAppDelegate.logintoken){
        [contentDic setObject:MyAppDelegate.userInfo[@"id"] forKey:@"uid"];
        [contentDic setObject:MyAppDelegate.logintoken forKey:@"login_token"];
    }
    [contentDic setObject:[MyAppDelegate md5HexDigest:contentDic] forKey:@"sign"];
    
    //判断网络状态
    if ([MYRequest checkNetStatus] == 0) {
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"网络错误" message:@"网络尚未接入互联网，请检查你的网络连接！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertV show];
        return;
    }
    ////
    NSData* result = [NSJSONSerialization dataWithJSONObject:contentDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString: %@",jsonString);
    
    //如果是GET方法，重新拼装urlStr
    if ([method isEqualToString:@"GET"]) {
        NSArray *keyArr = [dic allKeys];
        NSArray *values = [dic allValues];
        
        NSMutableString *parmaString = [[NSMutableString alloc]init];
        for (int i = 0; i< keyArr.count; i++) {
            NSString *key = [keyArr objectAtIndex:i];
            NSString *value = [values objectAtIndex:i];
            [parmaString appendFormat:@"%@=%@",key,value];
            if (i<keyArr.count-1) {
                [parmaString appendString:@"&"];
            }
        }
        urlStr = [NSString stringWithFormat:@"%@?%@",urlStr,parmaString];
    }
    
    NSLog(@"API: %@",urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    __block ASIFormDataRequest *request  = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:method];
    
    if (![method isEqualToString:@"GET"]) [request setPostValue:jsonString forKey:@"JsonString"];

    //判断是否https请求
    [request setValidatesSecureCertificate:!ishttps];
//    [request setShouldAttemptPersistentConnection:NO];
    
    if (ismultipart) {
        //multipart上传图片
        if (fileurl.length > 0) {
            [request setFile:fileurl forKey:@"file"];
        }
        [request buildRequestHeaders];
        [request buildPostBody];
    }
    
    __weak ASIFormDataRequest *_blorequest = request;
    
    [ASIFormDataRequest showNetworkActivityIndicator];
    [_blorequest setCompletionBlock:^{
        NSString *responseString = [_blorequest responseString];
        NSLog(@"responseString: %@",responseString);
        NSData *data = [_blorequest responseData];
        [ASIFormDataRequest hideNetworkActivityIndicator];
        if(0 == data.length){
            block(nil,[NSError errorWithDomain:@"NO data" code:110 userInfo:[NSDictionary dictionary]]);
        }else{
            block(data,nil);
        }
        
    }];
    
    [_blorequest setFailedBlock:^{
        [ASIFormDataRequest hideNetworkActivityIndicator];

        NSLog(@"error:%ld", _blorequest.error.code);
        NSData *data = [_blorequest responseData];
        block(data,_blorequest.error);
    }];
    
    [_blorequest startAsynchronous];
}

@end
