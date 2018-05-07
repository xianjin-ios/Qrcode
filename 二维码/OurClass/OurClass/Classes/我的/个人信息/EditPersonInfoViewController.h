//
//  EditPersonInfoViewController.h
//  OurClass
//
//  Created by siqiyang on 16/4/7.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "BaseViewController.h"

@interface EditPersonInfoViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *sexView;

//选择男时
@property (weak, nonatomic) IBOutlet UIImageView *selectManview;

//选择女时
@property (weak, nonatomic) IBOutlet UIImageView *selectWomanview;

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@property (weak, nonatomic) IBOutlet UIImageView *picimageView;

/**
 *  判断是否是从登陆界面而来
 */
@property (nonatomic,assign) BOOL isFromLogin;

- (IBAction)editPic:(id)sender;
/**
 *  选择男的按钮
 */
- (IBAction)selectMan:(id)sender;


/**
 *  选择女的按钮
 *
 */
- (IBAction)selectWoman:(id)sender;


@end
