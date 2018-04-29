//
//  GetQRCodeViewController.m
//  二维码
//
//  Created by siqiyang on 2017/12/21.
//  Copyright © 2017年 mengxianjin. All rights reserved.
//

#import "GetQRCodeViewController.h"

@interface GetQRCodeViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressTf;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

@implementation GetQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"生成二维码";
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelEditing:)];
    [self.view addGestureRecognizer:tap];
  
}
- (void)cancelEditing:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
}
- (void)loogpress:(UILongPressGestureRecognizer *)loog{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *downAC = [UIAlertAction actionWithTitle:@"保存到本地" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(_imageview.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }];
    
    UIAlertAction *recognize = [UIAlertAction actionWithTitle:@"识别二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_imageview.image) {
            NSString *result = [self readImg:_imageview.image];
            if (result) {
                [self alertString:[NSString stringWithFormat:@"二维码内容: %@",result]];
            }else{
                [self alertString:@"非二维码图片"];
            }
        }
    }];
    [alertVC addAction:downAC];
    [alertVC addAction:recognize];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:confirm];
    [self presentViewController:alertVC animated:YES completion:nil];

    
}
- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:  (NSError*)error contextInfo:(void*)contextInfo

{
    
    NSString*message =@"呵呵";
    
    if(!error) {
        
        message =@"成功保存到相册";
        
    }
    else
        message = @"保存失败，请重试！";
    [self alertString:message];
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
- (IBAction)getQRCode:(id)sender {
    if ([_addressTf.text isEqualToString:@""]) {
        [self alertString:@"请输入要生成二维码的内容"];
        return;
    }
    NSString *text = self.addressTf.text;
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor whiteColor];
    UIColor *offColor = [UIColor blackColor];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    
    CGSize size = CGSizeMake(_imageview.bounds.size.width-5, _imageview.bounds.size.width-5);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    _imageview.image = codeImage;
    UILongPressGestureRecognizer *loog = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(loogpress:)];
//    loog.minimumPressDuration = 2.0;
    [_imageview addGestureRecognizer:loog];
    _imageview.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)alertString:(NSString *)title{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"朕知道了" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:confirm];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
