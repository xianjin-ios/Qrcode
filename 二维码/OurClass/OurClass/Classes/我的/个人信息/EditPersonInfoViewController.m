//
//  EditPersonInfoViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/7.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "EditPersonInfoViewController.h"
#import "GTMBase64.h"
#import "MainViewController.h"

@interface EditPersonInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
{
    int genderIndex;//0-女，1-选男，2-未选
    BOOL _isChangeHeadImage;//用于判断用户是否修改了头像信息
}
@end

@implementation EditPersonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    if (_isFromLogin) {
        [self hideBackButton];
         genderIndex = 2;
    }
    else{
        
       NSString *sexStr = [MyAppDelegate.userInfo objectForKey:@"sex"];
        genderIndex = sexStr.intValue;
        _nameField.text = [MyAppDelegate.userInfo objectForKey:@"realname"];
        
        if (genderIndex == 0) {
            [self selectWoman:nil];
        }
        else
            [self selectMan:nil];
        
    }
    [_nameField addTarget:self action:@selector(limitLength:) forControlEvents:UIControlEventEditingChanged];

    //性别分界线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.5 -0.5, 35, 1, 40)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
    [_sexView addSubview:lineView];
    
    _picimageView.layer.masksToBounds = YES;
    self.picimageView.layer.cornerRadius = 14.5;
    [self addConfirmBtn];

    [_picimageView sd_setImageWithURL:[NSURL URLWithString:[MyAppDelegate.userInfo objectForKey:@"small_head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
    
}
- (void)addConfirmBtn{
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(0, 0, 40, 30);
    [deleteBtn setTitle:@"确定" forState:UIControlStateNormal];
    [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:DefaultBtnFont]];
    [deleteBtn setTitleColor:[UIColor colorWithHexString:@"#0032a5"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:deleteBtn]];
    
}
- (void)confirmClick:(id)sender{
     if (self.isFromLogin) {
         if (!_isChangeHeadImage) {
             [self showAlert:@"请选择头像信息" withTitle:@"温馨提示" haveCancelButton:NO];
         }
     }
    NSString *sex = nil;
    if (_nameField.text.length == 0) {
        [self showAlert:@"请填写姓名" withTitle:@"温馨提示" haveCancelButton:NO];
        return ;
    }
    if (genderIndex == 2) {
        //判断是否选择性别
        [self showAlert:@"请选择性别" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    else if(genderIndex == 1){
        sex = @"1";
    }
    else
        sex = @"0";
    
    [self showHUD];
    NSDictionary *dic = @{@"realname":_nameField.text,@"sex":sex};
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
    
    //判断是否修改了用户头像
    NSString *headStr;
    BOOL isMultiPart = NO;
    if (_isChangeHeadImage) {
        headStr = [HDImageObject saveImage:_picimageView.image];
        isMultiPart = YES;
    }
    [MYRequest requstWithDic:contentDic withUrl:API_Edit_Profile withRequestMethod:@"POST" isHTTPS:NO isMultiPart:isMultiPart andMultiPartFileUrl:headStr andGetData:^(id data, NSError *error) {
        [self hideHUD];
  
        
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
        
        MyAppDelegate.userInfo = [resultDic objectForKey:@"user"];
        
        //发送通知，刷新个人信息
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshCurrentImage" object:nil];
        
        //用户确定编辑完成
        if (self.isFromLogin) {
            //返回首页
            [self showAlert:@"个人信息设置成功" withTitle:@"提示" haveCancelButton:NO];
            [MyAppDelegate.deckController closeLeftViewAnimated:NO];
            MyAppDelegate.mainViewController.NeedRefresh = YES;
            [self dismissViewControllerAnimated:YES completion:^(void){
            }];
            
        }
        else{
           [self showAlert:@"个人信息修改成功" withTitle:@"提示" haveCancelButton:NO];
            [self goBack:nil];
        }
    }];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //判断是否是退格键
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return YES;
}

-(IBAction)limitLength:(UITextField *)sender
{
    bool isChinese;//判断当前输入法是否是中文
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString: @"en-US"]) {
        isChinese = false;
    }
    else
    {
        isChinese = true;
    }
    
    if(sender == _nameField) {
        // 10位
        NSString *str = [[_nameField text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
        if (isChinese) { //中文输入法下
            UITextRange *selectedRange = [_nameField markedTextRange];
            //获取高亮部分
            UITextPosition *position = [_nameField positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                NSLog(@"汉字");
                if ( str.length > 10) {
                    [self showAlert:@"字符超过限制" withTitle:@"提示" haveCancelButton:NO];
                    NSString *strNew = [NSString stringWithString:str];
                    [_nameField setText:[strNew substringToIndex:10]];
                }
            }
            else
            {
                NSLog(@"输入的英文还没有转化为汉字的状态");
                
            }
        }else{
            NSLog(@"str=%@; 本次长度=%ld",str,(unsigned long)[str length]);
            if ([str length]>10) {
                [self showAlert:@"字符超过限制" withTitle:@"提示" haveCancelButton:NO];
                NSString *strNew = [NSString stringWithString:str];
                [_nameField setText:[strNew substringToIndex:10]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  选择照片
 *
 */
- (IBAction)editPic:(id)sender {
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //判断拍照是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertVc addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            //    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            //        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //    }
            //sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
            //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
            //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
            picker.delegate = self;
            picker.allowsEditing = YES;//设置可编辑
            picker.sourceType = sourceType;
            [self presentModalViewController:picker animated:YES];//进入照相界面
            
        }]];
    }
    
    [alertVc addAction:[UIAlertAction actionWithTitle:@"从手机相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
            
        }
        pickerImage.delegate = self;
        pickerImage.allowsEditing = YES;
        [self presentModalViewController:pickerImage animated:YES];
        
    }]];
    
    [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"已取消！");
        
    }]];
    [self presentViewController:alertVc animated:YES completion:nil];
    
}

//选取了照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerEditedImage];

    [_picimageView setImage:selectImage];
    _isChangeHeadImage = YES;
    
    self.picimageView.layer.masksToBounds = YES;
    _picimageView.layer.cornerRadius = _picimageView.frame.size.width/2;
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
//用户点击了取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

- (IBAction)selectMan:(id)sender {
    
    genderIndex = 1;
    [self.selectManview setImage:[UIImage imageNamed:@"select_btn"]];
    [self.selectWomanview setImage:[UIImage imageNamed:@"unselect_btn"]];
}

- (IBAction)selectWoman:(id)sender {
    
    genderIndex = 0;
    [self.selectWomanview setImage:[UIImage imageNamed:@"select_btn"]];
    [self.selectManview setImage:[UIImage imageNamed:@"unselect_btn"]];
    
    
}

@end
