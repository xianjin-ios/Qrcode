//
//  ClassEdit.m
//  OurClass
//
//  Created by STAR on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "ClassEdit.h"
#import "DateViewController.h"
#import "SelectSchoolViewController.h"



@interface ClassEdit ()<DateViewControllerDelegate>{
    
    IBOutlet UIScrollView *scrView;
    DateViewController *_picker;
    
    IBOutlet UITextField *tfClass;
    IBOutlet UITextField *tfSchool;
    IBOutlet UITextField *tfTimeFild;
    IBOutlet UITextField *tfTimeFildEnd;
    
    //学校信息
    NSDictionary  *_schoolDic;
    
    //第一次设置的是在校开始时间；第二次弹出是设置在校结束时间。
    BOOL isBeginTime;
    
    IBOutlet UIButton *beginBtn;
    
    NSDictionary *classInfo;
}

@end

@implementation ClassEdit

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"编辑班级信息";
    
    [self addRightBtn];
}

- (void)addRightBtn{
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.frame = CGRectMake(0.0, 0.0, 48, 22);
    UILabel *lbClose = [[UILabel alloc]initWithFrame:btnRight.bounds];
    lbClose.text = @"确定";
    lbClose.font = [UIFont systemFontOfSize:DefaultBtnFont];
    lbClose.textColor = [UIColor colorWithHexString:@"#0032a5"];
    lbClose.textAlignment = NSTextAlignmentCenter;
    [btnRight addSubview:lbClose];
    [btnRight addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItemRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    barItemRight.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = barItemRight;
}

- (ClassEdit *)initWithClassInfo : (NSDictionary *)info;{
    classInfo = [info copy];
    [self performSelector:@selector(setView) withObject:nil afterDelay:0.1];
    
    return  [self init];
}

- (void)setView{
    if(classInfo){
        tfClass.text = [classInfo objectForKey:@"classname"];
        tfSchool.text= [classInfo objectForKey:@"schoolname"];
        NSString *beginTime = [self stampToDate:[classInfo objectForKey:@"starttime"] format:@"YYYY年MM月"];
        NSString *endTime = [self stampToDate:[classInfo objectForKey:@"endtime"] format:@"YYYY年MM月"];
        tfTimeFild.text = beginTime;
        tfTimeFildEnd.text = endTime;
    }
}

- (void)doCommit:(UIButton *)sender{
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[MyAppDelegate.classInfo objectForKey:@"id"]?[MyAppDelegate.classInfo objectForKey:@"id"]:@""forKey:@"cid"];
    if([_schoolDic isKindOfClass:[NSDictionary class]]){
        [contentDic setObject:[_schoolDic objectForKey:@"id"]forKey:@"sid"];
    }else{
        [contentDic setObject:[MyAppDelegate.classInfo objectForKey:@"sid"]forKey:@"sid"];
    }
    [contentDic setObject:tfClass.text forKey:@"classname"];
    NSString *timeStr = tfTimeFild.text;
    NSString *timeStrEnd = tfTimeFildEnd.text;
    NSString *time1 = [self stringToStamp:timeStr format:@"yyyy年MM月"];
    NSString *time2 = [self stringToStamp:timeStrEnd format:@"yyyy年MM月"];
    [contentDic setObject:time1 forKey:@"starttime"];
    [contentDic setObject:time2 forKey:@"endtime"];
    [MYRequest requstWithDic:contentDic withUrl:API_Edit_Class withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO  andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        
        if([[resultDic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:1]]){
            [self showAlert:@"修改成功！" withTitle:@"提示" haveCancelButton:NO];
            refreshBlock();
            return;
        }
    }];
}

- (IBAction)showDatePicker:(id)sender{
    if(sender == beginBtn){
        isBeginTime = YES;
    }else{
        isBeginTime = NO;
    }
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(RefreshDate:) name:@"refreshDate" object:nil];
    [self showDatePickerView];
}

- (void)RefreshDate:(NSNotification *)notify{
    NSMutableDictionary * dateDic = notify.object;
    if (isBeginTime) {
        tfTimeFild.text = [dateDic objectForKey:@"date"];
    }else{
        tfTimeFildEnd.text = [dateDic objectForKey:@"date"];
    }
    [self.view endEditing:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshDate" object:nil];
    
}
#pragma mark DateViewControllerDelegate
- (void)selectFinish:(DateViewController*)ctrl withDate:(NSString*)date{
    if(isBeginTime){
        UIScrollView *scrollView = (UIScrollView*)[self.view viewWithTag:111];
        scrollView.userInteractionEnabled = YES;
        NSString * strTime = date;
        if(strTime.length >= 7){
            strTime = [strTime substringToIndex:7];
        }
        tfTimeFild.text = strTime;
        [ctrl.view removeFromSuperview];
        
    }else{
        //结束在校时间
        UIScrollView *scrollView = (UIScrollView*)[self.view viewWithTag:111];
        scrollView.userInteractionEnabled = YES;
        NSString * endTime = date;
        if(endTime.length >= 7){
            endTime = [endTime substringToIndex:7];
        }
        tfTimeFildEnd.text = endTime;
        [ctrl.view removeFromSuperview];
    }
}

- (void)selectCancel:(DateViewController*)ctrl{
    UIScrollView * scrollView = (UIScrollView*)[self.view viewWithTag:111];
    scrollView.userInteractionEnabled = YES;
    [ctrl.view removeFromSuperview];
}

#pragma mark - 编辑学校
- (IBAction)selectSchool:(id)sender {
    //注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSchoolName:) name:@"changeSchoolName" object:nil];
    SelectSchoolViewController *selectS = [[SelectSchoolViewController alloc]init];
    
    selectS.isFromClassEdit = YES;
    
    [self.navigationController pushViewController:selectS animated:YES];
    
    
}
- (void)changeSchoolName:(NSNotification *)notify{
    
    _schoolDic = notify.object;
    
    tfSchool.text = [_schoolDic objectForKey:@"schoolname"];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"changeSchoolName" object:nil];
    
}
@end
