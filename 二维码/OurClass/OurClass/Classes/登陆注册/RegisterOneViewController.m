//
//  RegisterOneViewController.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "RegisterOneViewController.h"
#import "RegisterSecondViewController.h"
#import "webViewer.h"

@interface RegisterOneViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet UIImageView *checkImage;
    __weak IBOutlet WeUITextField *_txPhone;
    
    __weak IBOutlet WeUITextField *_txCode;
    
    //注册获取验证码90秒等待
    int wait90Sec;
    
    UIButton *_codeBtn;
    
    BOOL isGetCode;
}
@end

@implementation RegisterOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _codeBtn = [self.view viewWithTag:11];
    _codeBtn.layer.borderWidth = 1.0f;
    _codeBtn.layer.borderColor = [UIColor colorWithHexString:@"#0032a5"].CGColor;

    [checkImage setHighlighted:YES];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //判断是否是退格键
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (textField == _txPhone && _txPhone.text.length >= 11) {
        _txPhone.text = [_txPhone.text substringToIndex:11];
        [_txPhone resignFirstResponder];
        return NO;
        
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

//开始90S计时
- (void)startCount{
    wait90Sec--;
    NSString *titleStr = [NSString stringWithFormat:@"%ds", wait90Sec];
    [_codeBtn setTitle:titleStr forState:UIControlStateNormal];
    if(wait90Sec <= 0){
        [_codeBtn setTitle:@"重获" forState:UIControlStateNormal];
    }else{
        [self performSelector:@selector(startCount) withObject:nil afterDelay:1];
    }
}


- (IBAction)getCode:(id)sender {
    
    if (_txPhone.text.length != 11 || ![self isValidPhone:_txPhone.text]) {
        [self showAlert:@"你填写的手机号不正确，请重新填写" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    wait90Sec = 90;
    [self startCount];
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:_txPhone.text forKey:@"username"];

    [MYRequest requstWithDic:contentDic withUrl:API_Get_Code_Register withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
        isGetCode = YES;
        
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
            wait90Sec = 0;
            return;
        }
        
        [self showAlert:@"验证码已发送，请注意查收" withTitle:@"提示" haveCancelButton:NO];

        
        
    }];
}

- (IBAction)doNext:(id)sender {
    if (!checkImage.highlighted) {
        [self showAlert:@"请同意《我们班软件许可及服务协议》！" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (_txPhone.text.length != 11 || ![self isValidPhone:_txPhone.text]) {
        [self showAlert:@"你填写的手机号不正确，请重新填写" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (_txCode.text.length == 0 || ![self isValidCode:_txCode.text]) {
        [self showAlert:@"请填写正确的短信验证码" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    if (!isGetCode) {
        [self showAlert:@"请获取短信验证码" withTitle:@"提示" haveCancelButton:NO];
        return;

    }
    
    RegisterSecondViewController *ctrl = [[RegisterSecondViewController alloc]init];
    ctrl.phoneNum = _txPhone.text;
    ctrl.phoneCode = _txCode.text;
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

- (IBAction)doCheck:(id)sender {
    
    NSString *urlStr = @"http://ourinter.guangguang.net.cn/h5/protocol/protocol";
    webViewer *ctrl = [[webViewer alloc]initWithUrl:urlStr andTitle:@"《我们班软件许可及服务协议》"];
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
