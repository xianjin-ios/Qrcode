//
//  RegisterSecondViewController.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "RegisterSecondViewController.h"
#import "EditPersonInfoViewController.h"
#import "MainViewController.h"

@interface RegisterSecondViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet WeUITextField *_txSec;
    
    __weak IBOutlet WeUITextField *_txSec2;
    
}
@end

@implementation RegisterSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //判断是否是退格键
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _txSec) {
        [_txSec resignFirstResponder];
        [_txSec2 becomeFirstResponder];
    }else if (textField == _txSec2){
        [self.view endEditing:YES];
    }
    
    return YES;
}

- (IBAction)doCommit:(id)sender {
    
    if (_txSec.text.length == 0) {
        [self showAlert:@"请输入新密码" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (![self isValidPassword:_txSec.text]) {
        [self showAlert:@"请设置数字与字母组合密码" withTitle:@"提示" haveCancelButton:NO];
        return;
        
    }
    
    if (_txSec2.text.length == 0  || ![self isValidPassword:_txSec.text]) {
        [self showAlert:@"请再次输入密码" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (![_txSec.text isEqualToString:_txSec2.text]) {
        [self showAlert:@"你两次填写的密码不一致，请重新填写" withTitle:@"提示" haveCancelButton:NO];
        return;
        
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:self.phoneNum forKey:@"username"];
    [contentDic setObject:self.phoneCode forKey:@"code"];
    [contentDic setObject:_txSec2.text forKey:@"password"];

    [MYRequest requstWithDic:contentDic withUrl:API_Register withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
                
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
        
        //保存keychain串记住用户密码
        [SSKeychain setPassword:self.phoneNum forService:keyChainAccessGroup account:keyChainUserAcount];
        [SSKeychain setPassword:_txSec.text forService:keyChainAccessGroup account:keyChainUserSecret];

        MyAppDelegate.userInfo = [resultDic objectForKey:@"user"];
        MyAppDelegate.logintoken = [resultDic objectForKey:@"login_token"];
        MyAppDelegate.classInfo = [resultDic objectForKey:@"class"];
        
        [SSKeychain setPassword:MyAppDelegate.userInfo[@"id"] forService:keyChainAccessGroup account:keyChainUserId];

        //绑定百度push
        [MyAppDelegate updateBPushInfo];
        
        [self showAlert:@"注册成功" withTitle:@"提示" haveCancelButton:NO];
        
        
    }];
    
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"注册成功"]) {
        if (buttonIndex == 0) {
            NSDictionary *userInfo = MyAppDelegate.userInfo ;
            //判断是否完善信息并跳入完善信息界面
            if ([[userInfo objectForKey:@"head_icon"]isEqualToString:@""]||[[userInfo objectForKey:@"sex"]isEqualToString:@""]||[[userInfo objectForKey:@"realname"]isEqualToString:@""]) {
                //进入个人信息编辑页面
                EditPersonInfoViewController *edit = [[EditPersonInfoViewController alloc]init];
                edit.isFromLogin = YES;
                [self.navigationController pushViewController:edit animated:YES];
                return;
            }
            //返回首页
            [MyAppDelegate.deckController closeLeftViewAnimated:NO];
            MyAppDelegate.mainViewController.NeedRefresh = YES;
            [self dismissViewControllerAnimated:YES completion:^(void){
            }];

        }
    }
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
