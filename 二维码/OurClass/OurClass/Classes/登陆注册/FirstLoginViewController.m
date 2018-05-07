//
//  FirstLoginViewController.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "FirstLoginViewController.h"
#import "loginViewController.h"
#import "RegisterOneViewController.h"
#import "VMessageViewController.h"

@interface FirstLoginViewController ()

@end

@implementation FirstLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getVmessage];
    UIButton * v1 = [self.view viewWithTag:12];
    [v1 setFrame:CGRectMake(40, SCREEN_HEIGHT - AltitudeHeight - 80 - 23 - 38, 103, 38)];
    v1.layer.borderWidth = 1.5f;
    v1.layer.borderColor = [UIColor colorWithHexString:@"#0032a5"].CGColor;
    
    UIButton * v2 = [self.view viewWithTag:13];
    [v2 setFrame:CGRectMake(178, SCREEN_HEIGHT - AltitudeHeight - 80 - 23 - 38, 103, 38)];
    v2.layer.borderWidth = 1.5f;
    v2.layer.borderColor = [UIColor colorWithHexString:@"#0032a5"].CGColor;
    
    UIView *downView = (UIView *)[self.view viewWithTag:14];
    [downView setFrame:CGRectMake(0, SCREEN_VIEW_HEIGHT - 80 - AltitudeHeight, SCREEN_VIEW_WIDTH, 80)];
    
    
    //进入登录页面清空信息
    MyAppDelegate.userInfo = nil;
    MyAppDelegate.logintoken = nil;
    MyAppDelegate.classInfo = nil;

}
- (void)getVmessage{
    [self showHUD];
    NSDictionary *dic = @{};
    [MYRequest requstWithDic:dic withUrl:API_VMesage_TitleAndTime withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        [self hideHUD];
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            [self showAlert:@"网络尚未接入互联网，请检查你的网络连接！" withTitle:@"网络错误" haveCancelButton:NO];
            return ;
        }
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            [self showAlert:[resultDic objectForKey:@"error"] withTitle:@"温馨提示" haveCancelButton:NO];
            return;
        }
        self.VmessageTitle.text = resultDic[@"info"] [@"title"];
        NSString *timeStr = resultDic[@"info"][@"ctime"];
        NSString *time = [NSString stringWithFormat:@"%@",[self stampToDate:timeStr format:@"yyyy-MM-dd"]];
        NSString *today = resultDic[@"timestamp"];
        NSString *text = nil;
        if ([[self stampToDate:today format:@"yyyy-MM-dd"]isEqualToString:time]) {
            text =[NSString stringWithFormat:@"%@", @"今天"];
        }
        else
            text = [NSString stringWithFormat:@"%@",time];
        self.VMessageTime.text = text;
        
    }];
    
}
- (IBAction)doRegister:(id)sender {
    RegisterOneViewController *ctrl = [[RegisterOneViewController alloc]init];
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

- (IBAction)doLogin:(id)sender {
    
    loginViewController *ctrl = [[loginViewController alloc]init];
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

- (IBAction)doVMessage:(id)sender {
    VMessageViewController *ctrl = [[VMessageViewController alloc]init];
    [self.navigationController pushViewController:ctrl animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
