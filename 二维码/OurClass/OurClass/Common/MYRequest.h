//
//  MYRequest.h
//  ASINetPackaging
//
//  Created by siqiyang on 16/2/22.
//  Copyright © 2016年 mengxianjin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class ASIFormDataRequest;
@interface MYRequest : NSObject

+ (void)requstWithDic:(NSDictionary *)dic withUrl:(NSString *)urlStr withRequestMethod:(NSString *)method isHTTPS:(BOOL)ishttps isMultiPart:(BOOL)ismultipart andMultiPartFileUrl:(NSString *)fileurl andGetData:(void (^)(id data, NSError *error))block;

/**
 *  检查网络
 *
 *  @return 0：无网络
 *          1：手机网络
 *          2：WiFi网络
 *          3：其他网络
 */
+ (NSInteger )checkNetStatus;

@end
