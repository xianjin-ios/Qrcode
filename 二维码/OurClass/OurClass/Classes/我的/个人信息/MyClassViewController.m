//
//  MyClassViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "MyClassViewController.h"
#import "SelectSchoolViewController.h"
#import "CreateClassViewController.h"
#import "MainViewController.h"

@interface MyClassViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;


@property (nonatomic,strong) UITableView *classTable;
@property (nonatomic,strong) NSMutableArray *classArray;
@property (nonatomic,assign) NSInteger indexPath;
@property (nonatomic,strong) UIView *noView;

@end

@implementation MyClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的班级";
    [self cancelTapHideKeyBoard:YES];
    
    //初始化数据源
    _classArray = [[NSMutableArray alloc]init];
    
    _classTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - AltitudeHeight)];
    _classTable.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    _classTable.delegate = self;
    _classTable.dataSource = self;
    _classTable.scrollEnabled = YES;
    [_classTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    _classTable.tableFooterView = [[UIView alloc]init];
    [self getClassList];
    //tableview 分割线
    if ([_classTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_classTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_classTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.classTable setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [self.mainScrollView addSubview:_classTable];
    [self addJoinAndCreateBtns];
    //注册通知，刷新我的班级列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshClassList:) name:@"refreshClassList" object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_classTable setEditing:NO];
}
/**
 *  添加加入和创建的按钮
 */
- (void)addJoinAndCreateBtns{
    UIImageView *joinImage = [[UIImageView alloc]initWithFrame:CGRectMake( 19, 9, 31, 31)];
    [joinImage setImage:[UIImage imageNamed:@"joinclass_btn"]];
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    joinBtn.frame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 110 -64, 50, 40);
    [joinBtn addTarget:self action:@selector(gotoJoin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinBtn];
    [joinBtn addSubview:joinImage];
    
    UIImageView *createImage = [[UIImageView alloc]initWithFrame:CGRectMake( 19, 9, 31, 31)];
    createImage.image = [UIImage imageNamed:@"createclass_btn"];
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 70 - 64, 50, 40);
    [createBtn addTarget:self action:@selector(gotoCreate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    [createBtn addSubview:createImage];
    
}
//重写基类返回按钮的触发方法
- (void)goBack:(id)sender{
    
    [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
}
/**
 *  获取班级列表
 */
- (void)getClassList{
    [self showHUD];
    
    NSDictionary *dic = @{};
    
    [MYRequest requstWithDic:dic withUrl:API_Myclass_List withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
        if (_classArray.count > 0) {
            [_classArray removeAllObjects];
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
                [_classTable addSubview:_noView];
            }
            
            MyAppDelegate.classInfo = nil;
            MyAppDelegate.mainViewController.NeedRefresh = YES;
        }
        else{
            
            if (_noView) {
                [_noView removeFromSuperview];
                _noView = nil;
            }
            
            //
            for (NSDictionary *classDic in  _classArray) {
                if ([[classDic objectForKey:@"isdefault"] isEqualToString:@"1"]) {
                    MyAppDelegate.classInfo = classDic;
                }
                else{
                    MyAppDelegate.classInfo = nil;
                    MyAppDelegate.mainViewController.NeedRefresh = YES;
                }
            }
        }
        [_classTable reloadData];
    }];
    
}
#pragma mark -- tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ZLog(@"%@",_classArray);
    return _classArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"class";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor whiteColor];
        //学校
        UILabel *schoolLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 150, 20)];
        schoolLabel.font = [UIFont systemFontOfSize:DefaultTitleFont];
        schoolLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [cell.contentView addSubview:schoolLabel];
        schoolLabel.tag = 101;
        //班级
        UILabel *classLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 28, 200, 20)];
        classLabel.font = [UIFont systemFontOfSize:DefaultTitleFont];
        classLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [cell.contentView addSubview:classLabel];
        classLabel.tag = 102;
        //状态
        UIButton *statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        statusBtn.frame = CGRectMake(SCREEN_WIDTH -105, 0, 100, 55);
        statusBtn.titleLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
        statusBtn.tag = 103;
        statusBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [statusBtn addTarget:self action:@selector(setMorenClass:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:statusBtn];
        
    }
    //判断班级类型（默认，审核中，设为默认）
    cell.contentView.tag = indexPath.row + 1000;
    
    NSDictionary *classDic = [_classArray objectAtIndex:indexPath.row];
    NSString *status = [classDic objectForKey:@"is_checked"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //学校
    UILabel *schoolLabel = (UILabel *)[cell.contentView viewWithTag:101];
    schoolLabel.text = classDic[@"schoolname"];
    //班级
    UILabel *classLabel = (UILabel *)[cell.contentView viewWithTag:102];
    classLabel.text = [classDic objectForKey:@"classname"];
    //班级状态
    UIButton *statusBtn = (UIButton *)[cell.contentView viewWithTag:103];
    NSString *isdefault = [classDic objectForKey:@"isdefault"];
    if ([status isEqualToString:@"0"]) {
        [statusBtn setTitleColor:[UIColor colorWithHexString:@"#d5d5d5"] forState:UIControlStateNormal];
        [statusBtn setTitle:@"[审核中]" forState:UIControlStateNormal];
        statusBtn.userInteractionEnabled = NO;
        //        cell.userInteractionEnabled = NO;
    }else{
        if([isdefault isEqualToString:@"1"]){
            //存储默认班级
            MyAppDelegate.classInfo = classDic;
            [statusBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [statusBtn setTitle:@"默认班" forState:UIControlStateNormal];
            statusBtn.userInteractionEnabled = NO;
            //            cell.userInteractionEnabled = YES;
        }else{
            [statusBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [statusBtn setTitle:@"设为默认班" forState:UIControlStateNormal];
            statusBtn.userInteractionEnabled = YES;
            //            cell.userInteractionEnabled = YES;
        }
    }
    
    return cell;
    
}
- (void)setMorenClass:(id)sender{
    UIButton *setBtn = (UIButton *)sender;
    NSInteger tag = setBtn.superview.tag;
    
    _indexPath = tag - 1000;
    [self modifyData:_indexPath];
}
//修改数据源
- (void)modifyData:(NSInteger)index{
    [self showHUD];
    NSDictionary *dic = @{
                          @"cid":[[_classArray objectAtIndex:index]objectForKey:@"id"]
                          };
    
    [MYRequest requstWithDic:dic withUrl:API_Set_Default withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
        
        [self getClassList];
        
    }];
    
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 55;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *classDic = [_classArray objectAtIndex:indexPath.row];
    NSString *status = [classDic objectForKey:@"is_checked"];
    if ([status isEqualToString:@"0"]) {
        [self showAlert:@"未加入班级" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    MyAppDelegate.classInfo = classDic;
    MyAppDelegate.mainViewController.NeedRefresh = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -- cell左滑动退出班级
//设cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"_classArray.count = %lu",(unsigned long)_classArray.count);
    NSDictionary *classDic = [_classArray objectAtIndex:indexPath.row];
    
    NSString *status = [classDic objectForKey:@"is_checked"];
    if ([status isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
    
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *classDic = [_classArray objectAtIndex:indexPath.row];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSString *manager = [classDic objectForKey:@"manager"];
    UITableViewRowAction *aa = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"退出" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定退出该班级？" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self showHUD];
            NSDictionary *classDic = _classArray[indexPath.row];
            //退出班级
            NSDictionary *dic = @{
                                  @"cid":classDic[@"id"]
                                  };
            [MYRequest requstWithDic:dic withUrl:API_Exit_Class withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
                
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
                [_classArray removeObjectAtIndex:indexPath.row];
                NSArray *paths = [NSArray arrayWithObject:indexPath];
                [tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
                
                [self showAlert:@"退出成功" withTitle:@"提示" haveCancelButton:NO];

            }];
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    [arr addObject:aa];
    if ([manager isEqualToString:[MyAppDelegate.userInfo objectForKey:@"id"]]) {//班级创建者(manager的id和用户的id一样)
        UITableViewRowAction *aa1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"解散" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定解散该班级？" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self showHUD];
                NSDictionary *classDic = _classArray[indexPath.row];
                //退出班级
                NSDictionary *dic = @{
                                      @"cid":classDic[@"id"]
                                      };
                [MYRequest requstWithDic:dic withUrl:API_Class_Disband withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
                    
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
                    [_classArray removeObjectAtIndex:indexPath.row];
                    NSArray *paths = [NSArray arrayWithObject:indexPath];
                    [tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
                    [self showAlert:@"解散成功" withTitle:@"提示" haveCancelButton:NO];
                    ZLog(@"解散成功，刷新列表");
                }
                 ];
                
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            
        }];
        [arr addObject:aa1];
    }
    
    
    return arr;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"退出成功"]||[alertView.message isEqualToString:@"解散成功"]) {
        [_classArray removeAllObjects];
        [self getClassList];
    }
    
}

#pragma mark -- 加入和创建班级的按钮的响应事件
- (void)gotoJoin:(id)sender{
    SelectSchoolViewController *selectSchool = [[SelectSchoolViewController alloc]init];
    selectSchool.isFromClassList = YES;
    [self.navigationController pushViewController:selectSchool animated:YES];
    
}

- (void)gotoCreate:(id)sender{
    SelectSchoolViewController *selectSchool = [[SelectSchoolViewController alloc]init];
    selectSchool.isfromCreateClass = YES;
    [self.navigationController pushViewController:selectSchool animated:YES];
    
}

- (void)refreshClassList:(NSNotification *)notify{
    
    [self getClassList];
    
    
}
//进入编辑模式，点击出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
       
}
#pragma mark ---  分割线
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
