//
//  ViewController.m
//  二维码
//
//  Created by siqiyang on 2017/12/21.
//  Copyright © 2017年 mengxianjin. All rights reserved.
//

#import "ViewController.h"
#import "ScanQRCodeViewController.h"
#import "GetQRCodeViewController.h"
#import "ReadQrCodeViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)scanqrcode:(id)sender {
    
    [self.navigationController pushViewController:[[ScanQRCodeViewController alloc]init] animated:YES];
}

- (IBAction)getqrcode:(id)sender {

    [self.navigationController pushViewController:[[GetQRCodeViewController alloc]init] animated:YES];
}
- (IBAction)read:(id)sender {

    [self.navigationController pushViewController:[[ReadQrCodeViewController alloc]init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
