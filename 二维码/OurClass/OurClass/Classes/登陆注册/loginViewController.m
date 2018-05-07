//
//  loginViewController.m
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "loginViewController.h"
#import "ForgetViewController.h"
#import "MainViewController.h"
#import "EditPersonInfoViewController.h"
@interface loginViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet WeUITextField *_txPhone;
    
    __weak IBOutlet WeUITextField *_txSec;
    
}
@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserAcount]) {
        _txPhone.text = [SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserAcount];

    }

}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //判断是否是退格键
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (textField == _txPhone && _txPhone.text.length >= 11) {
        _txPhone.text = [_txPhone.text substringToIndex:11];
        [_txPhone resignFirstResponder];
        [_txSec becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)doLogin:(id)sender {

    if (_txPhone.text.length != 11 || _txSec.text.length == 0 || ![self isValidPhone:_txPhone.text] || ![self isValidPassword:_txSec.text]) {
        [self showAlert:@"你填写的手机号或密码不正确，请重新填写" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:_txPhone.text forKey:@"username"];
    [contentDic setObject:_txSec.text forKey:@"password"];
    [MYRequest requstWithDic:contentDic withUrl:API_Login withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        [SSKeychain setPassword:_txPhone.text forService:keyChainAccessGroup account:keyChainUserAcount];
        [SSKeychain setPassword:_txSec.text forService:keyChainAccessGroup account:keyChainUserSecret];
        
        MyAppDelegate.userInfo = [resultDic objectForKey:@"user"];
        MyAppDelegate.logintoken = [resultDic objectForKey:@"login_token"];
        MyAppDelegate.classInfo = [resultDic objectForKey:@"class"];
        
        [SSKeychain setPassword:MyAppDelegate.userInfo[@"id"] forService:keyChainAccessGroup account:keyChainUserId];

        //绑定百度push
        [MyAppDelegate updateBPushInfo];
        
        NSDictionary *userInfo = [resultDic objectForKey:@"user"];
        //发送通知，登录成功时，刷新侧滑栏的头像信息
        [[NSNotificationCenter defaultCenter]postNotificationName:@"login" object:nil];
        //判断是否完善信息并跳入完善信息界面
        if (([[userInfo objectForKey:@"head_icon"]isEqualToString:@""])||([[userInfo objectForKey:@"realname"]isEqualToString:@""])) {
             //进入个人信息编辑页面
            EditPersonInfoViewController *edit = [[EditPersonInfoViewController alloc]init];
            edit.isFromLogin = YES;
            [self.navigationController pushViewController:edit animated:YES];

        }
        else{
            //返回首页
            [MyAppDelegate.deckController closeLeftViewAnimated:NO];
            MyAppDelegate.mainViewController.NeedRefresh = YES;
            [self dismissViewControllerAnimated:YES completion:^(void){
            }];
       
        }
        
       }];
}

- (IBAction)doForget:(id)sender {
    ForgetViewController *ctrl = [[ForgetViewController alloc]init];
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
