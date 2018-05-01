//
//  ScanQRCodeViewController.m
//  WWLDeveloperPlatform
//
//  Created by 博大光通 on 16/3/16.
//  Copyright © 2016年 博大光通. All rights reserved.
//

#import "J_ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>


#import "QRCodeReaderView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
#define GSScreenHeight [UIScreen mainScreen].bounds.size.height
#define GSScreenWidth [UIScreen mainScreen].bounds.size.width
#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)

@interface J_ScanQRCodeViewController ()<QRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    QRCodeReaderView * readview;//二维码扫描对象
    
    BOOL isFirst;//第一次进入该页面
    BOOL isPush;//跳转到下一级页面
}

@property (strong, nonatomic) CIDetector *detector;

@end

@implementation J_ScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫描";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * rbbItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(alumbBtnEvent)];
    self.navigationItem.rightBarButtonItem = rbbItem;
    
//    UIBarButtonItem * lbbItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonEvent)];
//    self.navigationItem.leftBarButtonItem = lbbItem;
    
    isFirst = YES;
    isPush = NO;
    
    [self InitScan];
}

#pragma mark - 返回
- (void)backButtonEvent
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 初始化扫描
- (void)InitScan
{
    if (readview) {
        [readview removeFromSuperview];
        readview = nil;
    }
    
    readview = [[QRCodeReaderView alloc]initWithFrame:CGRectMake(0, 0, GSScreenWidth, GSScreenHeight)];
    readview.is_AnmotionFinished = YES;
    readview.backgroundColor = [UIColor clearColor];
    readview.delegate = self;
    readview.alpha = 0;
    
    [self.view addSubview:readview];
    
    [UIView animateWithDuration:0.5 animations:^{
        readview.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - 相册
- (void)alumbBtnEvent
{
    
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        if (IOS8) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未开启访问相册权限，现在去开启！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 4;
            [alert show];
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        return;
    }
    
    isPush = YES;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController         availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    readview.is_Anmotion = YES;
    
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >=1) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //播放扫描二维码的声音
            SystemSoundID soundID;
            NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
            AudioServicesPlaySystemSound(soundID);
            NSLog(@"%@",scannedResult);
            [self accordingQcode:scannedResult];
        }];
        
    }
    else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            readview.is_Anmotion = NO;
            [readview start];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

#pragma mark -QRCodeReaderViewDelegate
- (void)readerScanResult:(NSString *)result
{
    readview.is_Anmotion = YES;
    [readview stop];
    
    //播放扫描二维码的声音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    [self accordingQcode:result];
    
    [self performSelector:@selector(reStartScan) withObject:nil afterDelay:1.5];
}

#pragma mark - 扫描结果处理
- (void)accordingQcode:(NSString *)result
{
    
//    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alertView show];

//    [[NSNotificationCenter defaultCenter] postNotificationName:@"scanNotifi" object:str];

//    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:  [NSString stringWithString:[result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]  message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    [self InitScan];
}
- (void)reStartScan
{
    readview.is_Anmotion = NO;
    
    if (readview.is_AnmotionFinished) {
        [readview loopDrawLine];
    }
    
    [readview start];
}

#pragma mark - view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isFirst || isPush) {
        if (readview) {
            [self reStartScan];
        }
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (readview) {
        [readview stop];
        readview.is_Anmotion = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isFirst) {
        isFirst = NO;
    }
    if (isPush) {
        isPush = NO;
    }
}


//    self.view.backgroundColor = [UIColor blackColor];
//    
//    isAuth = YES;
//    
//    // 显示navigationBar
//    self.navigationController.navigationBarHidden = NO;
//    
//    // // 修改“back”为“返回”
//    [self.navigationController.navigationBar.backItem setTitle:@"返回"];
//    
//    // 设置标题
//    [self.navigationItem setTitle:@"扫一扫"];
//    
//    //移动线条
//    [self moveScanLine];
    
//}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    if (GSScreenWidth / GSScreenHeight > 0.6) {
//        
//        self.scanWindowView.center = self.view.center;
//        
//        self.scanWindowView.bounds = CGRectMake(0, 0, 200, 200);
//        
//        [self.scanWindowView setTranslatesAutoresizingMaskIntoConstraints:YES];
//    }
//    
//    //[SVProgressHUD showInfoWithStatus:@"正在初始化二维码"];
//
//}
//
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    for (UIView *view in self.view.window.subviews) {
//        if ([view isKindOfClass:[UILabel class]]) {
//            
//            [view removeFromSuperview];
//        }
//    }
//    // 设置视频View属性
////    if (GSDeviceVersion > 7.0) {
//     [self configureCaptureViewProperties];
////        // 添加扫描线并开始扫描
////        [self addScanLineAndScan];
////        
//////    }
//}
//
//-(void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    
//    [_videoPreviewLayer removeFromSuperlayer];
//    
//    if ([_device hasTorch]) {
//        
//        [_device lockForConfiguration:nil];
//        [_device setTorchMode:AVCaptureTorchModeOff];
//        [_device unlockForConfiguration];
//    }
//    
//}
//
///**
// *  设置视频View属性
// */
//- (void)configureCaptureViewProperties {
//    NSError *error;
//    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
//    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    //2.用captureDevice创建输入流
//    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
//    if (!input) {
////        GSLog(@"%@", [error localizedDescription]);
//    }
//    //3.创建媒体数据输出流
//    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
//    
//    //4.实例化捕捉会话
//    _captureSession = [[AVCaptureSession alloc] init];
//    //是否可以添加到会话
//    if ([_captureSession canAddInput:input] && [_captureSession canAddOutput:captureMetadataOutput]) {
//        //将输入流添加到会话
//        [_captureSession addInput:input];
//        //将媒体输出流添加到会话中
//        [_captureSession addOutput:captureMetadataOutput];
//    }else{
//        //提示用户给予权限
//        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"未授权该应用打开相机的权限" message:@"请在设备\"设置\"-\"隐私\"-\"相机\"中打开" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alert show];
//        return;
//    }
//    //5.创建串行队列，并加媒体输出流添加到队列当中
//    dispatch_queue_t dispatchQueue;
//    dispatchQueue = dispatch_queue_create("myQueue", NULL);
//    //5.1.设置代理
//    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    //5.2.设置输出媒体数据类型为QRCode
//    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
//    //6.实例化预览图层
//    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
//    //7.设置预览图层填充方式
//    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//    //8.设置图层的frame
//    [_videoPreviewLayer setFrame:_scanWindowView.layer.bounds];
//    //9.将图层添加到预览view的图层上
//    [_scanWindowView.layer insertSublayer:_videoPreviewLayer atIndex:0];
//    //10.设置扫描范围
////    CGRect viewRect = self.view.frame;
//    //获取扫描容器的frame
////    CGRect containerRect = self.scanWindowView.frame;
////    CGFloat x = containerRect.origin.y / viewRect.size.height;
////    CGFloat y = containerRect.origin.x / viewRect.size.width;
////    CGFloat width = containerRect.size.height / viewRect.size.height;
////    CGFloat height = containerRect.size.width / viewRect.size.width;
////    captureMetadataOutput.rectOfInterest = CGRectMake(x, y, width, height);
//    captureMetadataOutput.rectOfInterest = CGRectMake(0.01f, 0.01f, 0.99f, 0.99f);  // CGRectMake(0.2f, 0.2f, 0.8f, 0.8f)
//    [_captureSession startRunning];
//    // 添加扫描线并开始扫描
//    [self addScanLineAndScan];
//    [self.activityIndicatorView removeFromSuperview];
//    
//}
//
//#pragma mark - <AVCaptureMetadataOutputObjectsDelegate> 此代理在子线程中
//-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
//    
//    NSString * regex = @"^[A-Za-z0-9]{16}$";
//    if (metadataObjects.count > 0 && metadataObjects != nil) {
//        
//        //停止会话
//        [_captureSession stopRunning];
//        
//    }
////    BOOL isMatch = [[[metadataObjects objectAtIndex:0] stringValue] isMatchedByRegex:regex];
//    
////    if(isMatch){//授权成功
////        
////        [self performSelectorOnMainThread:@selector(JumpHomeVC:) withObject:[[metadataObjects objectAtIndex:0]stringValue]  waitUntilDone:YES];
//////        GSLog(@"%@",metadataObject.stringValue);
////        
////    }else{//授权失败
////        
////        isAuth = NO;
////        [[NSNotificationCenter defaultCenter] postNotificationName:@"IsAuth" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:isAuth] forKey:@"isAuth"]];
////        [self.navigationController popViewControllerAnimated:YES];
////    }
//}
//- (IBAction)LightButton:(UIButton *)sender {
//    
//    if (_device != nil) {
//        //是否可用
//        if (_device.torchAvailable){
//            [_device lockForConfiguration:nil];
//            if (!_device.torchActive) {
//                [_device setTorchMode:AVCaptureTorchModeOn];
//                [_device setFlashMode:AVCaptureFlashModeOn];
//            } else {
//                [_device setTorchMode:AVCaptureTorchModeOff];
//                [_device setFlashMode:AVCaptureFlashModeOff];
//            }
//            [_device unlockForConfiguration];
//        }
//    }
//
//}
//
///**
// *  向scanWindowView添加扫描线，并开始扫描
// */
//- (void)addScanLineAndScan {
//    //10.2.扫描线
//    _scanLineImgView = [[UIImageView alloc] init];
//    _scanLineImgView.frame = CGRectMake(0, 0, self.scanWindowView.bounds.size.width, 2);
//    _scanLineImgView.image = [UIImage imageNamed:@"qrcode_Scan_weixin_Line"];
//    [_scanWindowView addSubview:_scanLineImgView];
//   
//}
//
//- (void)moveScanLine
//{
//    __weak typeof(self)weakself = self;
//    
//    [UIView animateWithDuration:2 animations:^{
//        
//        _scanLineImgView.transform = CGAffineTransformTranslate(_scanLineImgView.transform, 0, _scanWindowView.frame.size.height);
//        
//    } completion:^(BOOL finished) {
//        
//        [UIView animateWithDuration:2 animations:^{
//            //回到原位
//            _scanLineImgView.transform = CGAffineTransformIdentity;
//
//        
//        } completion:^(BOOL finished) {
//            
//            [weakself moveScanLine];
//            
//        }];
//
//    }];
//}
//
//-(void)JumpHomeVC:(NSString *)scanResult
//{
//    //影藏灯光按钮
//    self.LightButton.alpha = 0;
//    [_scanLineImgView removeFromSuperview];
//    
//    //得到扫描的数据
////    GSLog(@"%@",scanResult);
//    
////    //传扫描得到的数据到主页
//
//    //跳到主页
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}
//
//#pragma mark - **************** UIAlertView的代理
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1) {
//
//        //跳到设置页面
//        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        
//        if ([[UIApplication sharedApplication] canOpenURL:url])
//        {
//            [[UIApplication sharedApplication] openURL:url];
//        }
//    }else{
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}
//
//-(void)dealloc
//{
////    GSLog(@"第二个页面销毁了");
//}
@end
