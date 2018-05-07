//
//  AboutViewController.m
//  OurClass
//
//  Created by huadong on 16/4/6.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "AboutViewController.h"
#import "webViewer.h"

@interface AboutViewController ()
{
    
    __weak IBOutlet UIButton *downBtn;
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于 我们班";
    
    [downBtn setFrame:CGRectMake(downBtn.frame.origin.x, SCREEN_VIEW_HEIGHT - 100 - AltitudeHeight, downBtn.frame.size.width, downBtn.frame.size.height)];

    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *shortVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    WeUILabel *lb1 = [self.view viewWithTag:12];
    lb1.text = [NSString stringWithFormat:@"版本号：%@.%@",shortVersion,version];
    
//    WeUILabel *lb2 = [self.view viewWithTag:13];
//    NSString *lbStr = [NSString stringWithFormat:@"曹逸美，庄清源/r/n北京侃侃知著教育科技有限公司"];
//    lb2.text = lbStr;
//    [lb2 sizeToFit];
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
