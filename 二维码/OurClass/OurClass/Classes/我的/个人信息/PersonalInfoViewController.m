//
//  PersonalInfoViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "EditPersonInfoViewController.h"
#import "VIPhotoView.h"

@interface PersonalInfoViewController ()

//人头像
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;

//名字
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

//性别
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;


@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   self.title = @"个人信息";
    [self addEditBtn];

    NSDictionary *userinfo = MyAppDelegate.userInfo;
    //头像
    //处理url中的转义串
    NSString *url = [self dealWithUrlStr:[userinfo objectForKey:@"head_icon"]];
    [self.picImageView sd_setImageWithURL:[NSURL URLWithString:url]placeholderImage:[UIImage imageNamed:@"default_head"]];
    
    //名字
    self.nameLabel.text = [userinfo objectForKey:@"realname"];
    
    //性别
    NSString *sex = [userinfo objectForKey:@"sex"];
    if (sex.intValue ==1) {
         self.genderLabel.text =@"男";
    }
    else
    self.genderLabel.text = @"女";
    
    self.picImageView.layer.masksToBounds = YES;
    self.picImageView.layer.cornerRadius = 14.5;
    
    [self cancelTapHideKeyBoard:YES];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigView)];
    imageTap.cancelsTouchesInView = YES;
    [self.picImageView addGestureRecognizer:imageTap];
    
    //注册通知，更新个人信息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurrentImage:) name:@"refreshCurrentImage" object:nil];
   
}
//url的处理
- (NSString *)dealWithUrlStr:(NSString *)urlStr{
    
    NSMutableString *responseString = [NSMutableString stringWithString:urlStr];
      NSString *character = nil;
         for (int i = 0; i < responseString.length; i ++) {
                character = [responseString substringWithRange:NSMakeRange(i, 1)];
                if ([character isEqualToString:@"\\"])
                       [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
        }

    return responseString;
}

/**
 *  编辑按钮
 */
- (void)addEditBtn{
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(0, 0, 40, 30);
    [deleteBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:DefaultBtnFont]];
    [deleteBtn setTitleColor:[UIColor colorWithHexString:@"#0032a5"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(gotoEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:deleteBtn]];
    
    
}
- (void)gotoEdit:(id)sender{
    
    EditPersonInfoViewController *edit = [[EditPersonInfoViewController alloc]init];
    [self.navigationController pushViewController:edit animated:YES];
    
}
- (void)changeCurrentImage:(NSNotification *)notify{
    
    //编辑完成后，重新获取个人信息
    NSDictionary *userinfo = MyAppDelegate.userInfo;
    //头像
    //处理url中的转义串
    NSString *url = [self dealWithUrlStr:[userinfo objectForKey:@"head_icon"]];
    [self.picImageView sd_setImageWithURL:[NSURL URLWithString:url]placeholderImage:[UIImage imageNamed:@"default_head"]];
    
    //名字
    self.nameLabel.text = [userinfo objectForKey:@"realname"];
    
    //性别
    NSString *sex = [userinfo objectForKey:@"sex"];
    if (sex.intValue ==1) {
        self.genderLabel.text =@"男";
    }
    else
        self.genderLabel.text = @"女";
    
    self.picImageView.layer.masksToBounds = YES;
    self.picImageView.layer.cornerRadius = 14.5;
    

    
}

- (void)showBigView{
    //把本来背景挡住
    UIView *bgBigPic = [[UIView alloc] initWithFrame:self.view.bounds];
    bgBigPic.backgroundColor = [UIColor blackColor];
    bgBigPic.tag = 1102;
    [MyAppDelegate.window addSubview:bgBigPic];
    
    float valueWidth = ((NSString*)MyAppDelegate.userInfo[@"old_image_width"]).floatValue;
    float valueHeight = ((NSString*)MyAppDelegate.userInfo[@"old_image_height"]).floatValue;
    NSString *imageUrl = [MyAppDelegate.userInfo objectForKey:@"head_icon"];
    ZLog(@"imageUrl : %@",imageUrl);
    UIImageView *showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, valueWidth, valueHeight)];
    [showImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"default_head"]];
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:self.view.bounds andImage:showImageView.image];
    photoView.autoresizingMask = (1 << 6) -1;
    photoView.tag = 1101;
    [MyAppDelegate.window addSubview:photoView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
