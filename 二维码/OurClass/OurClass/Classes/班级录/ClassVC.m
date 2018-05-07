//
//  ClassVC.m
//  OurClass
//
//  Created by STAR on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "ClassVC.h"
#import "ClassMate.h"
#import "ClassEdit.h"

@interface ClassVC (){
    IBOutlet UILabel *lbTitle;
    
    IBOutlet UILabel *lbClass;
    IBOutlet UILabel *lbSchool;
    IBOutlet UILabel *lbTime;
    
    __weak IBOutlet WeButton *_exitBtn;
    
    NSDictionary *classInfo;
    NSMutableArray *classMatesArr;
}

@end

@implementation ClassVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"班级主页";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [lbClass setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    [lbSchool setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    [lbTime setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    
    classInfo = [NSDictionary dictionary];
    classMatesArr = [[NSMutableArray alloc]init];
    
    [self getClassInfo];
}


- (IBAction)toSelectClassMate:(id)sender{
    if (classMatesArr.count == 0) {
        return;
    }
    ClassMate *vc = [[ClassMate alloc]init];
    vc.classMatesArr = classMatesArr;
    vc.classInfo = classInfo;
    [vc setRefreshBlock:^(void){
        [self getClassInfo];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)toClassEdit:(id)sender{
    ClassEdit *vc = [[ClassEdit alloc] initWithClassInfo:classInfo];
    [vc setRefreshBlock:^(void){
        [self getClassInfo];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 获取班级信息
- (void)getClassInfo{
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[MyAppDelegate.classInfo objectForKey:@"id"]?[MyAppDelegate.classInfo objectForKey:@"id"]:@""forKey:@"cid"];
    [MYRequest requstWithDic:contentDic withUrl:API_Class_Information withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO  andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        classInfo = [resultDic objectForKey:@"class"];
        
        if(classInfo){
            lbTitle.text = [classInfo objectForKey:@"classname"];
            lbClass.text = [classInfo objectForKey:@"classname"];
            lbSchool.text = [classInfo objectForKey:@"schoolname"];
            
            NSString *time1 = [classInfo objectForKey:@"starttime"];
            NSString *time2 = [classInfo objectForKey:@"endtime"];
            NSDate *date1 = [self stampToDate:time1];
            NSDate *date2 = [self stampToDate:time2];
            
            NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"YYYY年MM月"];
            NSString *  locationString = [dateformatter stringFromDate:date1];
            
            NSDateFormatter  *dateformatter2 = [[NSDateFormatter alloc] init];
            [dateformatter2 setDateFormat:@"YYYY年MM月"];
            NSString *  locationString2 = [dateformatter stringFromDate:date2];
            

            
            lbTime.text = [NSString stringWithFormat:@"%@-%@",locationString,locationString2];
            
            //判断是否有编辑权限
            if ([[classInfo objectForKey:@"manager"] isEqualToString:[MyAppDelegate.userInfo objectForKey:@"id"]]) {
                [_exitBtn setHidden:NO];
            }else{
                [_exitBtn setHidden:YES];
            }
        }
        
        classMatesArr = [resultDic objectForKey:@"classmates"];
        [self setClassMate:classMatesArr];
    }];
}

- (void)setClassMate:(NSArray *)cMate{
    NSMutableArray *mateArr = [NSMutableArray array];
    for(int i = 0; i < cMate.count; i ++){
        [mateArr addObject:[cMate[i] objectForKey:@"realname"]];
    }
    UIView *classMateView = [self.view viewWithTag:11];
    NSInteger mateX = 8;
    for (int i = 0; i < mateArr.count; i ++) {
        
        if (mateX < SCREEN_WIDTH - 60) {
            UIImageView *headIcon = [[UIImageView alloc]initWithFrame:CGRectMake(mateX, 7, 30, 30)];
            [headIcon sd_setImageWithURL:[NSURL URLWithString:[cMate[i] objectForKey: @"head_icon"]] placeholderImage:[UIImage imageNamed:@"default_head"]];
            headIcon.layer.cornerRadius = headIcon.frame.size.width/2.0;
            headIcon.layer.masksToBounds = YES;
            [classMateView addSubview:headIcon];
            
            mateX += 38;
        }
    }
}

@end
