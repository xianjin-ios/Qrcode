//
//  UIImage+AdjustSize.h
//  OurClass
//
//  Created by huadong on 16/4/18.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AdjustSize)

//获取展示图片的大小
- (CGSize ) getShowRect:(CGSize) size withImageSize:(CGSize)imageSize;

//返回制定大小的缩略图
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;


@end
