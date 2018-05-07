//
//  HDImageObject.h
//  OurClass
//
//  Created by huadong on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GUID.h"

@interface HDImageObject : NSObject

+ (NSString *)saveImage:(UIImage *)image;

+ (void)deleteImage;

@end
