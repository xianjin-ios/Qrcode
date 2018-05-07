//
//  UIImage+AdjustSize.m
//  OurClass
//
//  Created by huadong on 16/4/18.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "UIImage+AdjustSize.h"
#import <Photos/Photos.h>

@implementation UIImage (AdjustSize)

- (CGSize ) getShowRect:(CGSize) size withImageSize:(CGSize)imageSize{
    // 排错
    if(size.width==0||size.height==0)
        return size;
    
    CGSize imgSize=imageSize.width>0?imageSize:size;
    float scale=size.height/size.width;
    float imgScale=imgSize.height/imgSize.width;
    float width=0.0f,height=0.0f;
    
    if (scale == 1) {
        //正方形情况下返回正方形尺寸，适用于列表的缩略图展示等
        if (imgScale <= 1) {
            width = imgSize.height;
            height = imgSize.height;
        }else{
            width = imgSize.width;
            height = imgSize.width;
        }
        
    }else{
        //主页照片显示
        if (imgScale >= 1) {
            //原图(高比宽大)
            width = size.width;
            height = size.width * imgScale>size.width*2?size.width*2:size.width * imgScale;
            
        }else{
            //原图（宽比高大）
            width = size.width;
            height = size.width*imgScale<size.width/2?size.width/2:size.width*imgScale;
        }
    }
    
    CGSize resSize = CGSizeMake(width, height);
    return resSize;
    
}

- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize

{
    
    UIImage *newimage;
    
    if (nil == image) {
        
        newimage = nil;
        
    }
    
    else{
        
        UIGraphicsBeginImageContext(asize);
        
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    return newimage;
    
}


@end
