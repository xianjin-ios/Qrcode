//
//  JubaoViewController.m
//  OurClass
//
//  Created by huadong on 16/5/27.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "JubaoViewController.h"
#import "webViewer.h"

@interface JubaoViewController ()
{
    __weak IBOutlet UITextView *_txFeedBack;

    __weak IBOutlet UIButton *downBtn;
}
@end

@implementation JubaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"投诉";
    
    [_txFeedBack setFont:[UIFont systemFontOfSize:DefaultContentFont]];

    [downBtn setFrame:CGRectMake(downBtn.frame.origin.x, SCREEN_VIEW_HEIGHT - 100 - AltitudeHeight, downBtn.frame.size.width, downBtn.frame.size.height)];
}

- (void)initFeedBackData{
    [_txFeedBack setText:@"请在这里填写你的投诉原因，收到后我们会尽快处理"];
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
        [self showAlert:@"投诉原因最多输入1000字" withTitle:@"提示" haveCancelButton:NO];
        [self.view endEditing:YES];
        return NO;
    }
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (textView == _txFeedBack && textView.text.length <= 0) {
        [self initFeedBackData];
    }

    if([@"请在这里填写你的投诉原因，收到后我们会尽快处理" rangeOfString:textView.text].location !=NSNotFound)//_roaldSearchText
    {
        NSLog(@"yes");
        textView.text = @"请在这里填写你的投诉原因，收到后我们会尽快处理";
        
    }
    
    return YES;
}

- (IBAction)doCommit:(id)sender {
    
    if ([_txFeedBack.text isEqualToString:@"请在这里填写你的投诉原因，收到后我们会尽快处理"]||_txFeedBack.text.length<=0) {
        [self showAlert:@"请输入你的投诉原因" withTitle:@"提示" haveCancelButton:NO];
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
        
        [self showAlert:@"你的投诉提交成功" withTitle:@"提示" haveCancelButton:NO];
        
        
        
    }];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"你的投诉提交成功"]) {
        if (buttonIndex == 0) {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
}

- (IBAction)doCheck:(id)sender {
    
    
    NSString *urlStr = @"http://ourinter.guangguang.net.cn/h5/protocol/complaint";
    webViewer *ctrl = [[webViewer alloc]initWithUrl:urlStr andTitle:@"投诉须知"];
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
