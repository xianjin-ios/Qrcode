//
//  GUID.m
//  NewSolution
//
//  Created by 李振杰 on 14-6-4.
//  Copyright (c) 2014年 com.winchannel. All rights reserved.
//

#import "GUID.h"

@implementation GUID

+ (NSString*) stringWithUUID

{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    
    //get the string representation of the UUID
    NSString*uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    return uuidString;
    
}
@end
