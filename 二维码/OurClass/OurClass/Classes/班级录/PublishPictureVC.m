//
//  PublishPictureVC.m
//  OurClass
//
//  Created by STAR on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "PublishPictureVC.h"
#import "SelectPeopleVC.h"
#import "MainViewController.h"
#import "VIPhotoView.h"

@interface PublishPictureVC ()<UITextViewDelegate,SELECTPEOPLE_DELEGATE>
{
    IBOutlet UIView *_vTop;
    IBOutlet UITextView *_txView;
    IBOutlet UIImageView *_selectImageView;
    
    IBOutlet UIView *_vDown;
    IBOutlet UILabel *_lbTitle;
    IBOutlet UILabel *_lbAlert;
    IBOutlet UILabel *_lbSelectMate;
    //要@的人
    NSString *userids;
    UIButton *_confirmBtn;//确定按钮
}
@end

@implementation PublishPictureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userids = @"";
    
    
    [self setNavBtn];

    [self adjustView];
    
    [self setImageView];
    
}

- (void)setNavBtn{
    
    UIButton *bb1 = [UIButton buttonWithType:UIButtonTypeCustom];
    bb1.frame = CGRectMake(0, 0, 50, 44);
    _confirmBtn = bb1;
    [bb1 setTitleColor:[UIColor colorWithHexString:@"#0032a5"] forState:UIControlStateNormal];
    [bb1 setTitleColor:[UIColor colorWithHexString:@"#dfdfdf"] forState:UIControlStateSelected];
    [bb1 addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchDown];
    [bb1.titleLabel setFont:[UIFont systemFontOfSize:DefaultBtnFont]];
    [bb1 setTitle:@"确定" forState:UIControlStateNormal];
    [bb1 setTitle:@"确定" forState:UIControlStateHighlighted];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:bb1];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *bb = [UIButton buttonWithType:UIButtonTypeCustom];
    bb.frame = CGRectMake(-20, 0, 59, 44);
    [bb addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchDown];
    [bb setTitleColor:[UIColor colorWithHexString:@"#0032a5"] forState:UIControlStateNormal];
    [bb.titleLabel setFont:[UIFont systemFontOfSize:DefaultBtnFont]];
    [bb setTitle:@"取消" forState:UIControlStateNormal];
    [bb setTitle:@"取消" forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:bb];
    backItem.tag = 2222;
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)adjustView{
    
    //view适配
    [_vTop setFrame:CGRectMake(0, 0, SCREEN_VIEW_WIDTH, 155*MyAppDelegate.autoSizeScaleY)];
    [_vDown setFrame:CGRectMake(0, 155*MyAppDelegate.autoSizeScaleY + 10, SCREEN_VIEW_WIDTH, _vTop.frame.size.height*MyAppDelegate.autoSizeScaleY)];
    
    //图片适配
    [_selectImageView setFrame:CGRectMake(_selectImageView.frame.origin.x, _vTop.frame.size.height - _selectImageView.frame.size.height*MyAppDelegate.autoSizeScaleY - 10,_selectImageView.frame.size.width*MyAppDelegate.autoSizeScaleY, _selectImageView.frame.size.width*MyAppDelegate.autoSizeScaleY)];
    [_txView setFrame:CGRectMake(_txView.frame.origin.x, 0, _txView.frame.size.width, _vTop.frame.size.height - _selectImageView.frame.size.height*MyAppDelegate.autoSizeScaleY - 10)];

    //字体适配
    [_txView setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    [_lbTitle setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    [_lbAlert setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    [_lbSelectMate setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    
}

- (void)setImageView{
    
    ZLog(@"%@",self.selectImage);
    UIImage *image = [UIImage imageWithContentsOfFile:self.selectImage];
    ZLog(@"%@",image);
    CGSize size = [image getShowRect:_selectImageView.frame.size withImageSize:image.size];
    UIImage *image1 = [image thumbnailWithImage:image size:size];
    ZLog(@"%@",image1);
    [_selectImageView setUserInteractionEnabled:YES];
    [_selectImageView setImage:image1];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigView)];
    imageTap.cancelsTouchesInView = YES;
    [_selectImageView addGestureRecognizer:imageTap];
}

//huad,7.6新需求，点击预览图可以放大
- (void)showBigView{
    //把本来背景挡住
    UIView *bgBigPic = [[UIView alloc] initWithFrame:self.view.bounds];
    bgBigPic.backgroundColor = [UIColor blackColor];
    bgBigPic.tag = 1102;
    [MyAppDelegate.window addSubview:bgBigPic];
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.selectImage];
    ZLog(@"%@",image);
    CGSize size = [image getShowRect:_selectImageView.frame.size withImageSize:image.size];

    UIImageView *showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [showImageView setImage:image];
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:self.view.bounds andImage:showImageView.image];
    photoView.autoresizingMask = (1 << 6) -1;
    photoView.tag = 1101;
    [MyAppDelegate.window addSubview:photoView];
    
}

- (IBAction)doTapSelectMate:(id)sender {
    
    SelectPeopleVC *vc = [[SelectPeopleVC alloc]init];
    vc.delegate = self;
    vc.isPublish = YES;
    [self.navigationController pushViewController:vc animated:YES];

    
}

#pragma mark - selectPeopel_Delegate
-(void)selectPeopleArr:(NSMutableArray *)selectArr{
    
    ZLog(@"%@",selectArr); 
    [self adjustNameLabel:selectArr];
}

-(void)adjustNameLabel:(NSArray *)selectArray{
    NSMutableString *selectMateStr = [[NSMutableString alloc]init];
    userids = @"";
    for (int i = 0; i < selectArray.count; i ++) {
        [selectMateStr appendFormat:@"@%@",selectArray[i][@"realname"]];
        userids = [userids stringByAppendingString:selectArray[i][@"id"]];
        if (i < selectArray.count - 1) {
            userids = [userids stringByAppendingString:@","];
        }
    }
    [_lbSelectMate setText:selectMateStr];
    
    NSString *lbalertStr = [NSString stringWithFormat:@"您还可以@%ld名班级同学",9-(unsigned long)selectArray.count];
    [_lbAlert setText:lbalertStr];
    
}

#pragma mark - navbtn
-(void)goBack:(id)sender{
    //取消发布清除缓存
    [HDImageObject deleteImage];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)doCommit:(UIButton *)sender{
    UIButton *btn = sender;
    [btn setSelected:YES];
    [btn setUserInteractionEnabled:NO];
    
    [self showHUD];
    _confirmBtn.userInteractionEnabled = NO;
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[MyAppDelegate.classInfo objectForKey:@"id"]?[MyAppDelegate.classInfo objectForKey:@"id"]:@"" forKey:@"cid"];
    [contentDic setObject:[MyAppDelegate.classInfo objectForKey:@"sid"]forKey:@"sid"];

    [contentDic setObject:userids forKey:@"to_uids"];
    [contentDic setObject:_txView.text forKey:@"content"];
    if ([_txView.text isEqualToString:@"请输入文字"]) {
        [contentDic setObject:@"" forKey:@"content"];
    }
    
    //判断是否修改了用户头像
    [MYRequest requstWithDic:contentDic withUrl:API_Send_Album withRequestMethod:@"POST" isHTTPS:NO isMultiPart:YES andMultiPartFileUrl:self.selectImage andGetData:^(id data, NSError *error) {
        [self hideHUD];
        
        [btn setSelected:NO];
        [btn setUserInteractionEnabled:YES];

        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            [self showAlert:@"网络尚未接入互联网，请检查你的网络连接！" withTitle:@"网络错误" haveCancelButton:NO];
            _confirmBtn.userInteractionEnabled = YES;
            return ;
        }
        
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            [self showAlert:[resultDic objectForKey:@"error"] withTitle:@"温馨提示" haveCancelButton:NO];
            _confirmBtn.userInteractionEnabled = YES;
            return;
        }
        

        //提交照片清除缓存
        [HDImageObject deleteImage];

        [self showAlert:@"发布成功" withTitle:@"提示" haveCancelButton:NO];
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"发布成功"]) {
        MyAppDelegate.mainViewController.NeedRefresh = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - textDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (textView == _txView) {
        if ([textView.text isEqualToString:@"请输入文字"]) {
            [textView setText:@""];
            [textView setTextColor:[UIColor blackColor]];
        }
    }
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (textView == _txView && textView.text.length <= 0) {
        [textView setText:@"请输入文字"];
        [textView setTextColor:[UIColor colorWithHexString:@"#DFDFDF"]];
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length >= 500) {
        [self showAlert:@"提示" withTitle:@"最多输入500字" haveCancelButton:NO];
        return NO;
    }
    return YES;
}

@end
