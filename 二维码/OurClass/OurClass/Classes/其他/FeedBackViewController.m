//
//  FeedBackViewController.m
//  OurClass
//
//  Created by huadong on 16/4/6.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()<UITextViewDelegate>
{
    
    __weak IBOutlet UITextView *_txFeedBack;
    
    
    
}
@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"客户服务";
    
    [_txFeedBack setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    
}

- (void)initFeedBackData{
    [_txFeedBack setText:@"在这里描述你的建议..."];
    [_txFeedBack setTextColor:[UIColor colorWithHexString:@"#DFDFDF"]];
    [self.view endEditing:YES];
    
}

#pragma mark - textViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (textView == _txFeedBack) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (textView.text.length > 1000) {
        [self showAlert:@"反馈建议最多输入1000字" withTitle:@"提示" haveCancelButton:NO];
        [self.view endEditing:YES];
        return NO;
    }
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (textView == _txFeedBack && textView.text.length <= 0) {
        [self initFeedBackData];
    }
    return YES;
}


- (IBAction)doCommit:(id)sender {
    
    if ([_txFeedBack.text isEqualToString:@"在这里描述你的建议..."]||_txFeedBack.text.length<=0) {
        [self showAlert:@"请输入你的建议" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:_txFeedBack.text forKey:@"content"];
    [MYRequest requstWithDic:contentDic withUrl:API_Add_Suggestion withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        
        [self showAlert:@"你的建议提交成功" withTitle:@"提示" haveCancelButton:NO];


        
    }];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"你的建议提交成功"]) {
        if (buttonIndex == 0) {
            [self initFeedBackData];

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
