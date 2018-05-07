//
//  HDImageObject.m
//  OurClass
//
//  Created by huadong on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "HDImageObject.h"
@implementation HDImageObject

+ (NSString *)saveImage:(UIImage *)image{
    
    BOOL isFinish = NO;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData.length > 100*1024) {
        if (imageData.length>1024*1024*10) {//10M以及以上
            imageData=UIImageJPEGRepresentation(image, 0.1);
        }else if (imageData.length>512*1024) {//0.5M-1M
            imageData=UIImageJPEGRepresentation(image, 0.5);
        }else if (imageData.length>200*1024) {//0.25M-0.5M
            imageData=UIImageJPEGRepresentation(image, 0.9);
        }
    }

//    if (UIImagePNGRepresentation(image) == nil) {
//        
//        imageData = UIImageJPEGRepresentation(image, 1);
//        
//    } else {
//        
//        imageData = UIImagePNGRepresentation(image);
//    }
    
    //存入本地文件
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString  *filePath = [cachPath stringByAppendingPathComponent:@"imagefile"];
    //判断是否存在，不存在则创建一个文件夹
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:[NSString stringWithFormat:@"%@/imagefile", cachPath] withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[GUID stringWithUUID]]];
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    //把UIImage保存为文件
    while (isFinish == NO) {
        if ([imageData writeToFile:filePath atomically:YES]) {
            isFinish = YES;
        }
    }
    
    return filePath;
}

+ (void)deleteImage{
    
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
                       NSString  *filePath = [cachPath stringByAppendingPathComponent:@"imagefile"];
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:filePath];
                       NSLog(@"files :%lu",(unsigned long)[files count]);
                       
                       for (int i = 0; i < [files count]; i ++) {
                           NSError *error;
                           NSString *p = [files objectAtIndex:i];
                           NSString *path = [filePath stringByAppendingPathComponent:p];
                           [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                       }
                       
                   });
    
}


@end
