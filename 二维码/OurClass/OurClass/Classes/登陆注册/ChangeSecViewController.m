//
//  ChangeSecViewController.m
//  OurClass
//
//  Created by huadong on 16/4/6.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "ChangeSecViewController.h"
#import "FirstLoginViewController.h"

@interface ChangeSecViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet WeUITextField *_txOldSec;
    
    __weak IBOutlet WeUITextField *_txNewSec;
    
    __weak IBOutlet WeUITextField *_txNewSec2;
    
}
@end

@implementation ChangeSecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //判断是否是退格键
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _txOldSec) {
        [_txOldSec resignFirstResponder];
        [_txNewSec becomeFirstResponder];
    }else if (textField == _txNewSec){
        [_txNewSec resignFirstResponder];
        [_txNewSec2 becomeFirstResponder];
    }else if (textField == _txNewSec2){
        [self.view endEditing:YES];
    }
    
    return YES;
}

- (IBAction)doCommit:(id)sender {
    
    if (_txOldSec.text.length == 0) {
        [self showAlert:@"请填写正确的旧密码" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (_txNewSec.text.length == 0) {
        [self showAlert:@"请输入新密码" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (![self isValidPassword:_txNewSec.text]) {
        [self showAlert:@"请输入字母和数字组合的密码" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (_txNewSec2.text.length == 0) {
        [self showAlert:@"请再次输入新密码" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (![_txNewSec.text isEqualToString:_txNewSec2.text]) {
        [self showAlert:@"你两次填写的密码不一致，请重新填写" withTitle:@"提示" haveCancelButton:NO];
        return;
        
    }
    
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:_txOldSec.text forKey:@"password"];
    [contentDic setObject:_txNewSec2.text forKey:@"newpassword"];
  

    [MYRequest requstWithDic:contentDic withUrl:API_Update_Password withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        [SSKeychain setPassword:_txNewSec.text forService:keyChainAccessGroup account:keyChainUserSecret];

        [self showAlert:@"登录密码修改成功" withTitle:@"提示" haveCancelButton:NO];
    }];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"登录密码修改成功"]) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            
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
