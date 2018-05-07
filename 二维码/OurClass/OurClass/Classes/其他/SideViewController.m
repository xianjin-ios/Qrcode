//
//  SideViewController.m
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "SideViewController.h"
#import "MainViewController.h"
#import "FirstLoginViewController.h"
#import "VMessageViewController.h"
#import "MyPhotoViewController.h"
#import "MyAccountInfoViewController.h"
#import "AboutViewController.h"
#import "FeedBackViewController.h"
#import "ClassVC.h"

@interface SideViewController (){
    IBOutlet UIImageView *imgHead;
    
    __weak IBOutlet UIImageView *vinfoIcon;
    
}



//昵称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

//显示头像
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation SideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.photoImageView.layer.masksToBounds = YES;
    self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width/2.0;
//    NSDictionary *userinfo = MyAppDelegate.userInfo;
//    
//    [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:[userinfo objectForKey:@"head_icon"]]];
//    
//    //名字
//    self.nameLabel.text = [userinfo objectForKey:@"realname"];
   
//注册通知，当编辑个人信息是刷新头像
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrentImage1:) name:@"refreshCurrentImage" object:nil];
//注册通知，当自动登录时，显示头像
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrentImage2:) name:@"refreshUserImage" object:nil];
//注册通知，当登录成功时，刷新头像
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrentImage3:) name:@"login" object:nil];
//注册通知，刷新未读提示
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNoread) name:@"refreshNoreadView" object:nil];
    
    imgHead.layer.cornerRadius = imgHead.frame.size.width/2.0;
    imgHead.layer.masksToBounds = YES;
}

- (void)refreshNoread{
    UIView *noReadView = [self getNoReadViewWithSuperFrame:vinfoIcon.frame];
    [vinfoIcon addSubview:noReadView];
    if (MyAppDelegate.VInfoCount.intValue > 0) {
        [noReadView setHidden:NO];
    }else{
        [noReadView setHidden:YES];
    }
}

- (IBAction)doTapWeClass:(id)sender {
    //返回班级照片录首页
    [self hideSideView];
    
    //返回首页
    MyAppDelegate.mainViewController.NeedRefresh = YES;
    [MyAppDelegate.mainViewController refreshData];
    
}

- (IBAction)doVMessage:(id)sender {
    //隐藏侧栏
    [self hideSideView];
    
    VMessageViewController *ctrl = [[VMessageViewController alloc]init];
    [MyAppDelegate.mainViewController.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)doFeedBack:(id)sender {
    //隐藏侧栏
    [self hideSideView];
    
    FeedBackViewController *ctrl = [[FeedBackViewController alloc]init];
    [MyAppDelegate.mainViewController.navigationController pushViewController:ctrl animated:YES];

}

- (IBAction)doAbout:(id)sender {
    //隐藏侧栏
    [self hideSideView];
    
    AboutViewController *ctrl = [[AboutViewController alloc]init];
    [MyAppDelegate.mainViewController.navigationController pushViewController:ctrl animated:YES];

}

- (IBAction)doLoginOut:(id)sender {
    //隐藏侧栏
    [self hideSideView];
    
    //清除用户信息
    MyAppDelegate.userInfo = nil;
    MyAppDelegate.logintoken = nil;
    MyAppDelegate.classInfo = nil;
    //
    [SSKeychain deletePasswordForService:keyChainAccessGroup account:keyChainUserAcount];
    [SSKeychain deletePasswordForService:keyChainAccessGroup account:keyChainUserSecret];
    [SSKeychain deletePasswordForService:keyChainAccessGroup account:keyChainUserId];
    [SSKeychain deletePasswordForService:keyChainAccessGroup account:keyChainAppIconNumber];
    
    [MyAppDelegate logoutBPushInfo];
    
    [MyAppDelegate setAppIconNumber:0];
    
    //显示登录页面
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:MyAppDelegate.firstViewController];
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  我的相册 //huad,7.6新需求，点击头像进入我的相册
 */
- (IBAction)gotoMyView:(id)sender{
    [self hideSideView];
    
    MyPhotoViewController *photoVC = [[MyPhotoViewController alloc]init];
    photoVC.hideBackButton = YES;
    
    [MyAppDelegate.mainViewController.navigationController pushViewController:photoVC animated:YES];
}
/**
 *  设置
 */
- (IBAction)gotoMyPhotoView:(id)sender {
    [self hideSideView];
    
    MyAccountInfoViewController *accountVC = [[MyAccountInfoViewController alloc]init];
    accountVC.hideBackButton = YES;
    [MyAppDelegate.mainViewController.navigationController pushViewController:accountVC animated:YES];
}

- (void)changeCurrentImage1:(NSNotification *)notify{
    
    NSDictionary *userinfo = MyAppDelegate.userInfo;
    //头像
    [imgHead sd_setImageWithURL:[NSURL URLWithString:[userinfo objectForKey:@"head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
    
    //名字
    self.nameLabel.text = [userinfo objectForKey:@"realname"];
  
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshCurrentImage" object:nil];
    
}

- (void)changeCurrentImage2:(NSNotification *)notify{
    
    NSDictionary *userinfo = MyAppDelegate.userInfo;
    //头像
    [imgHead sd_setImageWithURL:[NSURL URLWithString:[userinfo objectForKey:@"head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
    
    //名字
    self.nameLabel.text = [userinfo objectForKey:@"realname"];
    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshUserImage" object:nil];
    
}
- (void)changeCurrentImage3:(NSNotification *)notify{
    
    NSDictionary *userinfo = MyAppDelegate.userInfo;
    //头像
    [imgHead sd_setImageWithURL:[NSURL URLWithString:[userinfo objectForKey:@"head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
    
    //名字
    self.nameLabel.text = [userinfo objectForKey:@"realname"];
    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshUserImage" object:nil];
    
}

@end
