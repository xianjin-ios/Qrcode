//
//  ReadQrCodeViewController.m
//  二维码
//
//  Created by siqiyang on 2017/12/21.
//  Copyright © 2017年 mengxianjin. All rights reserved.
//

#import "ReadQrCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ReadQrCodeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

@implementation ReadQrCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (NSString *)readImg:(UIImage *)qrcodeImage{
    UIImage * srcImage = qrcodeImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result = feature.messageString;
    return result;
}
- (IBAction)selectImg:(id)sender {
//    调用系统相册的类
    UIImagePickerController *pickVC = [[UIImagePickerController alloc]init];
//    图片设置可以被编辑
    pickVC.allowsEditing = YES;
//    设置呈现样式
    pickVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
//    delegate
    pickVC.delegate = self;
    [self.navigationController presentViewController:pickVC animated:YES completion:^{
        
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"info = %@",info);
    self.imageview.image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)readQrcodeFromImage:(id)sender {
    if (_imageview.image) {
        NSString *urlstr = [self readImg:_imageview.image];
        NSLog(@"二维码内容是:  %@",urlstr);
        if (urlstr) {
            [self alertString:urlstr];
        }else{
            [self alertString:@"非二维码图片"];
        }
        
    }
    else{
        [self alertString:@"请选取带二维码的图片"];
    }
    
}
- (void)alertString:(NSString *)title{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"朕知道了" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:confirm];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
