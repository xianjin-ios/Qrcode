//
//  LaunchpadViewController.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "LaunchpadViewController.h"

@interface LaunchpadViewController ()
{
    UIImageView *dotView;
    
}
@end

@implementation LaunchpadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    //加载gif图片
//    // 设定位置和大小
//    CGRect frame = CGRectMake(0,50,0,0);
//    frame.size = [UIImage imageNamed:@"1.gif"].size;
//    // 读取gif图片数据
//    NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"1" ofType:@"gif"]];
//    // view生成
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
//    webView.userInteractionEnabled = NO;//用户不可交互
//    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//    [self.view addSubview:webView];
    
    dotView = [self.view viewWithTag:11];
    
    //开始启动图动画
    [self performSelector:@selector(scale_1) withObject:nil afterDelay:0.5f];
    [self performSelector:@selector(scale_2) withObject:nil afterDelay:1.0f];
    [self performSelector:@selector(scale_3) withObject:nil afterDelay:1.5f];
    [self performSelector:@selector(scale_4) withObject:nil afterDelay:2.0f];
    [self performSelector:@selector(scale_5) withObject:nil afterDelay:2.5f];
    [self performSelector:@selector(scale_1) withObject:nil afterDelay:3.0f];
    [self performSelector:@selector(scale_2) withObject:nil afterDelay:3.5f];
    [self performSelector:@selector(scale_3) withObject:nil afterDelay:4.0f];
    [self performSelector:@selector(scale_4) withObject:nil afterDelay:4.5f];
    [self performSelector:@selector(scale_5) withObject:nil afterDelay:5.0f];
}

- (void)scale_1{
    [dotView setImage:[UIImage imageNamed:@"launch_dot1.png"]];
}

- (void)scale_2{
    [dotView setImage:[UIImage imageNamed:@"launch_dot2.png"]];

}

- (void)scale_3{
    [dotView setImage:[UIImage imageNamed:@"launch_dot3.png"]];

}

- (void)scale_4{
    [dotView setImage:[UIImage imageNamed:@"launch_dot4.png"]];

}

- (void)scale_5{
    [dotView setImage:[UIImage imageNamed:@"launch_dot5.png"]];

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
