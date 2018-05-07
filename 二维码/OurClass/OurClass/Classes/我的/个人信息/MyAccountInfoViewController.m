//
//  MyAccountInfoViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "MyAccountInfoViewController.h"
#import "PersonalInfoViewController.h"
#import "MyClassViewController.h"
#import "ChangeSecViewController.h"
@interface MyAccountInfoViewController ()

@end

@implementation MyAccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self hideBackButton:NO];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  跳转到个人信息
 *
 */
- (IBAction)gotoPersonalInfo:(id)sender {
    
    PersonalInfoViewController *personalVC = [[PersonalInfoViewController alloc]init];
    [self.navigationController pushViewController:personalVC animated:YES];
    

}
/**
 *  跳转到我的班级
 *
 */
- (IBAction)gotoMyClass:(id)sender {
    
    MyClassViewController *classVC = [[MyClassViewController alloc]init];
    [self.navigationController pushViewController:classVC animated:YES];
    
}
/**
 *  跳转到修改密码
 *
 */
- (IBAction)gotoModifyPassword:(id)sender {
    //
    NSLog(@"跳转到修改密码");
    ChangeSecViewController *changeSec = [[ChangeSecViewController alloc]init];
    
    [self.navigationController pushViewController:changeSec animated:YES];
    
}
@end
