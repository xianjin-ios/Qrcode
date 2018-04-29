//
//  ScanQRCodeViewController.m
//  二维码
//
//  Created by siqiyang on 2017/12/21.
//  Copyright © 2017年 mengxianjin. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong) UIView *scanRectView;

@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;

@end

@implementation ScanQRCodeViewController
void (^name)(int);
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描二维码";
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:([UIScreen mainScreen].bounds.size.height<500)?AVCaptureSessionPreset640x480:AVCaptureSessionPresetHigh];
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    self.output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    
    CGSize scanSize = CGSizeMake(windowSize.width*3/4, windowSize.width*3/4);
    CGRect scanRect = CGRectMake((windowSize.width-scanSize.width)/2, (windowSize.height-scanSize.height)/2, scanSize.width, scanSize.height);
    
    //计算rectOfInterest 注意x,y交换位置
    scanRect = CGRectMake(scanRect.origin.y/windowSize.height, scanRect.origin.x/windowSize.width, scanRect.size.height/windowSize.height,scanRect.size.width/windowSize.width);
    self.output.rectOfInterest = scanRect;
    
    self.scanRectView = [UIView new];
    UIImageView *scanImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"code.png"]];
    [scanImage addSubview:_scanRectView];
    [self.view addSubview:scanImage];
    _scanRectView.frame = CGRectMake(0, 0, scanSize.width, scanSize.height);
    scanImage.frame = CGRectMake(0, 0, scanSize.width, scanSize.height);
    scanImage.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
//    self.scanRectView.layer.borderColor = [UIColor redColor].CGColor;
//    self.scanRectView.layer.borderWidth = 1;
    
    self.output.rectOfInterest = scanRect;
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    //开始捕获
    [self.session startRunning];
    
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ( (metadataObjects.count==0) )
    {
        return;
    }
    
    if (metadataObjects.count>0) {
        
        [self.session stopRunning];
        
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        //输出扫描字符串
        NSString *result = metadataObject.stringValue;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:  [NSString stringWithString:[result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]  message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.session startRunning];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
