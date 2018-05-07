//
//  SelectClassViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/12.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "SelectClassViewController.h"
#import "CreateClassViewController.h"
#import "MainViewController.h"
@interface SelectClassViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger currentIndex;
    NSInteger currentsection;
}
@property (nonatomic,strong) NSMutableArray *classArray;
@property (nonatomic,strong) UITableView *classTableview;
@property (nonatomic,strong) NSMutableArray *indexArr;
@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (nonatomic,strong) UIView *noView;

@end

@implementation SelectClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   self.title = @"选择班级";
    _classArray = [[NSMutableArray alloc]init];
    _indexArr = [[NSMutableArray alloc]init];
    _dataDic = [[NSMutableDictionary alloc]init];
    currentIndex = -1;
    currentsection = -1;
    [self addSelectedSchoolUI];
    _classTableview = [[UITableView alloc]initWithFrame:CGRectMake(0,  27*MyAppDelegate.autoSizeScaleFont + 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 -27*MyAppDelegate.autoSizeScaleFont) style:UITableViewStylePlain];
    _classTableview.delegate = self;
    _classTableview.dataSource = self;
    _classTableview.tableFooterView = [[UIView alloc]init];
    if ([_classTableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [_classTableview setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_classTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [_classTableview setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [self.view addSubview:_classTableview];
    [self getClassData];
    [self cancelTapHideKeyBoard:YES];
    [self addSelectedSchoolLabel];
    [self addCreateClassBtn];
    
}
//已选学校
- (void)addSelectedSchoolUI{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 27*MyAppDelegate.autoSizeScaleFont)];
    topView.backgroundColor = [UIColor colorWithHexString:@"#363636"];
    [self.view addSubview:topView];
    UILabel *selectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH  - 8, 27*MyAppDelegate.autoSizeScaleFont)];
    selectedLabel.textColor = [UIColor whiteColor];
    selectedLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    selectedLabel.font = [UIFont systemFontOfSize:DefaultTitleFont];
    selectedLabel.text = [NSString stringWithFormat:@"已选择学校：%@",[_schoolDic objectForKey:@"schoolname"]];
    [topView addSubview:selectedLabel];
}

- (void)addCreateClassBtn{
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT -40-50, 50, 50);
 
    [createBtn addTarget:self action:@selector(createClass:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    UIImageView *creatIamge = [[UIImageView alloc]initWithFrame:CGRectMake(19, 9, 31, 31)];
    creatIamge.image = [UIImage imageNamed:@"createclass_btn"];
    [createBtn addSubview:creatIamge];
}
#pragma mark -- 创建学校
- (void)createClass:(id)sender{
    CreateClassViewController *createClass = [[CreateClassViewController  alloc]init];
    createClass.schoolDic = self.schoolDic;
    [self.navigationController pushViewController:createClass animated:YES];
}
- (void)addSelectedSchoolLabel{
    UILabel *selectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    selectedLabel.backgroundColor = [UIColor colorWithHexString:@"#363636"];
    selectedLabel.textColor = [UIColor whiteColor];
    selectedLabel.text = [NSString stringWithFormat:@"%@:%@",@"已选择学校",self.schoolDic[@"schoolname"]];
    [self.view addSubview:selectedLabel];
    
}
/**
 *  获取班级列表信息
 */
- (void)getClassData{
    [self showHUD];
    NSDictionary *dic = @{
                          @"sid":self.schoolDic[@"id"]//schoolid
                          };
    
    [MYRequest requstWithDic:dic withUrl:API_Class_Select withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
       
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
        NSArray *classes = [resultDic objectForKey:@"classes"];
        [classes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            [_classArray addObject:obj];
            
        }];
        if (_classArray.count == 0) {
            
            //无数据提示
            if (!_noView) {
                _noView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *05 - 50, SCREEN_HEIGHT* 0.5 - 50, 100, 100)];
                _noView.backgroundColor = [UIColor clearColor];
                _noView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 50);
                UIImageView *bigbeen = [[UIImageView alloc]initWithFrame:CGRectMake(26, 10, 48, 45)];
                bigbeen.image = [UIImage imageNamed:@"icon_home_empty"];
                UILabel *labela = [[UILabel alloc]initWithFrame:CGRectMake(20, 65, 60, 30)];
                labela.backgroundColor = [UIColor clearColor];
                labela.text = @"暂无内容";
                labela.textAlignment = 1;
                labela.font = [UIFont systemFontOfSize:15];
                labela.textColor = [UIColor lightGrayColor];
                [_noView addSubview:labela];
                [_noView addSubview:bigbeen];
                [_classTableview addSubview:_noView];
            }
        }
        else{
            
            if (_noView) {
                [_noView removeFromSuperview];
                _noView = nil;
            }
            if (_dataDic == nil) {
                _dataDic = [[NSMutableDictionary alloc]init];
            }
            _indexArr = [self getIndexArr:_classArray];
            NSLog(@"%@",_indexArr);
            for (NSString *indexStr in _indexArr) {
                NSMutableArray *rowSource = [[NSMutableArray alloc] init];
                for (NSDictionary *classDic in _classArray) {
                    NSString *charString = [classDic objectForKey:@"classname"];
                    char firstChar = pinyinFirstLetter([charString characterAtIndex:0]);
                    NSString *youName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
                    if ([indexStr isEqualToString:youName]) {
                        [rowSource addObject:classDic];
                    }
                }
                [_dataDic setValue:rowSource forKey:indexStr];
            }

            
        }
        [_classTableview reloadData];
    }];

    
    
}
#pragma mark -- 获取数组中的首字母合集
//获取数组中的首字母合集
- (NSMutableArray *)getIndexArr:(NSArray *)arr{
    NSMutableArray *indexArray = [NSMutableArray array];
    //获取字母列表
    for (int i = 0; i <arr.count; i++) {
        NSString *classname = [[arr objectAtIndex:i]objectForKey:@"classname"];
        char firstChar = pinyinFirstLetter([classname characterAtIndex:0]);
        NSString *schoolName = [NSString stringWithFormat:@"%c",firstChar];
        //不添加重复元素
        if (![indexArray containsObject:[schoolName uppercaseString]]) {
            [indexArray addObject:[schoolName uppercaseString]];
        }
        
    }
    [indexArray sortUsingSelector:@selector(compare:)];
    if ([indexArray[0] isEqualToString:@"#"]) {
        [indexArray removeObjectAtIndex:0];
        [indexArray insertObject:@"#" atIndex:indexArray.count];

    }

    return indexArray;
}
#pragma mark -- tableViewdatasource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView == _classTableview) {
        return _indexArr;
    }
    return nil;
}
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {

    
    NSInteger tempSection = section;
    NSString *key = [_indexArr objectAtIndex:tempSection];
    return [@"  " stringByAppendingString:key];


    return nil;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _indexArr.count;
    
}
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    
    NSInteger count = 0;
    
    for(NSString *character in _indexArr)
    {
        if([character isEqualToString:title]) return count;
        count ++;
    }
    
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *tempArr = [NSArray array];
    if (_dataDic && _indexArr) {
        tempArr = [_dataDic objectForKey:[_indexArr objectAtIndex:section]];
    }
    if (tempArr.count != 0) {
        return tempArr.count;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"class";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取section上的串
    NSString *sectionStr = [NSString stringWithFormat:@"%@",_indexArr[indexPath.section]];
    NSArray *classArr = [_dataDic objectForKey:sectionStr];
    NSDictionary *classDic = classArr[indexPath.row];
    cell.textLabel.text = [classDic objectForKey:@"classname"];
    if (currentsection == indexPath.section) {
        if (indexPath.row == currentIndex) {
            UIImageView *accessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 19, 16)];
            accessoryView.image = [UIImage imageNamed:@"icon_check_sel"];
            cell.accessoryView = accessoryView;
        }
        else
            cell.accessoryView = nil;
    }
    else
        cell.accessoryView = nil;
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    currentIndex = indexPath.row;
    currentsection = indexPath.section;
    [_classTableview reloadData];
    //获取section上的串
    NSString *sectionStr = [NSString stringWithFormat:@"%@",_indexArr[indexPath.section]];
    NSArray *classArr = [_dataDic objectForKey:sectionStr];
    NSDictionary *classDic = classArr[indexPath.row];
    NSString *isChecked = [classDic objectForKey:@"is_checked"];
    if ([isChecked isEqualToString:@"1"]) {//已加入班级，进入班级详情
        
        MyAppDelegate.classInfo = classDic;
        MyAppDelegate.mainViewController.NeedRefresh = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{//未加入班级
        
        [self submitApplictionWithClassDic:classDic];

    }
    
}
- (void) submitApplictionWithClassDic:(NSDictionary *)classDic{
    //申请加入
    [self showHUD];
    NSDictionary *dic = @{@"cid":[classDic objectForKey:@"id"]
                          };
    [MYRequest requstWithDic:dic withUrl:API_AddTo_Class withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
    
     //申请成功
        [self joinClassSuccess];
    }];
    
}
/**
 *  申请成功
 */
- (void)joinClassSuccess{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.7;
    backView.tag = 555;
    [self.view addSubview:backView];
    UIView *alertView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*0.5 - 145*0.5, SCREEN_HEIGHT *0.5 - 90, 145, 90)];
    alertView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    alertView.alpha = 0.8;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 145, 30)];
    titleLabel.font = [UIFont systemFontOfSize:10];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"申请加入班级";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 125, 25)];
    messageLabel.textColor = [UIColor colorWithHexString:@"#acacac"];
    messageLabel.text = @"你的申请已提交，正在等待同学认证";
    messageLabel.numberOfLines = 2;
    messageLabel.font = [UIFont systemFontOfSize:9];
    [alertView addSubview:messageLabel];
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(145*0.5 - 50, 65, 100, 20);
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [confirmBtn addTarget:self action:@selector(submitApplication:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:confirmBtn];
    [self.view addSubview:alertView];
    alertView.tag = 600;

}
- (void)submitApplication:(id)sender{
    UIView *backView = (UIView *)[self.view viewWithTag:555];
    if (backView != nil) {
        [backView removeFromSuperview];
    }
    UIView *alertView = (UIView *)[self.view viewWithTag:600];
    if (alertView != nil) {
        [alertView removeFromSuperview];
    }
    //发送通知，刷新我的班级列表
     [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshClassList" object:nil];

         [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];


}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


@end
