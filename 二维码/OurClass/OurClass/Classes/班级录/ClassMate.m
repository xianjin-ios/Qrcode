//
//  ClassMate.m
//  OurClass
//
//  Created by STAR on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "ClassMate.h"

@interface ClassMate ()<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *iTableView;
    
    NSMutableArray *_dataArray;
    NSMutableArray *_indexArray;
    NSMutableDictionary *_dataDic;
    
    //允许编辑班级人员
    BOOL allowRemoveMate;
}

@end

@implementation ClassMate

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"同学";
    
    _dataArray = [[NSMutableArray alloc]init];
    _indexArray = [[NSMutableArray alloc]init];
    _dataDic = [[NSMutableDictionary alloc]init];
    
    _dataArray = self.classMatesArr;
    ZLog(@"%@",_dataArray);
    [self initData];

    allowRemoveMate = NO;
    if ([[self.classInfo objectForKey:@"manager"] isEqualToString:[MyAppDelegate.userInfo objectForKey:@"id"]]){
        //允许编辑删除人员
        allowRemoveMate = YES;
    }
}

- (void)initData{
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < _dataArray.count; i++){
        [array addObject: [_dataArray[i] objectForKey:@"realname"]];
    }
    _indexArray = [self getIndexArr:array];
    
    for (NSString *indexStr in _indexArray) {
        NSMutableArray *rowSource = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in _dataArray) {
            NSString *charString = [dic objectForKey:@"realname"];
            char firstChar = pinyinFirstLetter([charString characterAtIndex:0]);
            NSString *youName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
            if ([indexStr isEqualToString:youName]) {
                [rowSource addObject:dic];
            }
        }
        
        [_dataDic setValue:rowSource forKey:indexStr];
    }
    
    if ([iTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [iTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([iTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [iTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [iTableView reloadData];

}

//获取数组中的首字母合集
- (NSMutableArray *)getIndexArr:(NSArray *)arr{

    NSMutableArray *indexArr = [NSMutableArray array];
    //获取省份首字母列表
    for (int i = 0; i < arr.count; i++) {
        char firstChar = pinyinFirstLetter([[arr objectAtIndex:i] characterAtIndex:0]);
        NSString *youName = [NSString stringWithFormat:@"%c",firstChar];
        //不添加重复元素
        if (![indexArr containsObject:[youName uppercaseString]]) {
            [indexArr addObject:[youName uppercaseString]];
        }
    }
    [indexArr sortUsingSelector:@selector(compare:)];
    if ([indexArr[0] isEqualToString:@"#"]) {
        [indexArr removeObjectAtIndex:0];
        [indexArr insertObject:@"#" atIndex:indexArr.count];
    }
    return indexArr;
}

#pragma mark - indexsources
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexArray;
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    
    NSInteger count = 0;
    
    for(NSString *character in _indexArray)
    {
        if([character isEqualToString:title]) return count;
        count ++;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    
    NSInteger tempSection = section;
    NSString *key = [_indexArray objectAtIndex:tempSection];
    return [@"  " stringByAppendingString:key];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _indexArray.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *tempArr = [NSArray array];
    if (_dataDic && _indexArray) {
        tempArr = [_dataDic objectForKey:[_indexArray objectAtIndex:section]];
    }
    if (tempArr.count != 0) {
        return tempArr.count;
    }else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45*MyAppDelegate.autoSizeScaleY;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *commonIdentifier = @"commonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commonIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //头像
        UIImageView *vImgHead = [[UIImageView alloc]initWithFrame:CGRectMake(8, 17*MyAppDelegate.autoSizeScaleY/2.0, 28*MyAppDelegate.autoSizeScaleY, 28*MyAppDelegate.autoSizeScaleY)];
        vImgHead.tag = 1001;
        vImgHead.layer.cornerRadius = vImgHead.frame.size.width/2;
        vImgHead.layer.masksToBounds = YES;
        [cell.contentView addSubview:vImgHead];
        
        
        //名称
        UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(vImgHead.frame.origin.x + 28*MyAppDelegate.autoSizeScaleY + 10, 25*MyAppDelegate.autoSizeScaleY/2.0, 200*MyAppDelegate.autoSizeScaleY, 20*MyAppDelegate.autoSizeScaleY)];
        lbName.font = [UIFont systemFontOfSize:DefaultContentFont];
        lbName.tag = 1002;
        [cell.contentView addSubview:lbName];
        
        UIImageView *whoIsLeader = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - 7*MyAppDelegate.autoSizeScaleY, 27*MyAppDelegate.autoSizeScaleY/2.0, 7*MyAppDelegate.autoSizeScaleY, 18*MyAppDelegate.autoSizeScaleY)];
        whoIsLeader.tag = 1003;
        whoIsLeader.layer.masksToBounds = YES;
        [cell.contentView addSubview:whoIsLeader];

    }
    
    //获取当前section中的数组
    NSInteger tempSection = indexPath.section;
    NSString *key = [_indexArray objectAtIndex:tempSection];
    NSArray *allShowName = [_dataDic objectForKey:key];
    
    //显示
    UIImageView *vImgHead = (UIImageView*)[cell.contentView viewWithTag:1001];
    [vImgHead sd_setImageWithURL:[NSURL URLWithString:allShowName[indexPath.row][@"head_icon"]] placeholderImage:[UIImage imageNamed:@"default_head"]];
    UILabel *lbName = (UILabel*)[cell.contentView viewWithTag:1002];
    lbName.text = allShowName[indexPath.row][@"realname"];
    
    UIImageView *whoIsLeader = (UIImageView*)[cell.contentView viewWithTag:1003];
    if ([[self.classInfo objectForKey:@"manager"] isEqualToString:allShowName[indexPath.row][@"id"]]){
        //管理员
        whoIsLeader.image = [UIImage imageNamed:@"class_manager"];
    }else{
        whoIsLeader.image = nil;

    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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

#pragma mark - 管理员能删除同学
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return allowRemoveMate;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"移除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
        [contentDic setObject:[self.classInfo objectForKey:@"id"]?[self.classInfo objectForKey:@"id"]:@"" forKey:@"cid"];
        
        NSInteger tempSection = indexPath.section;
        NSString *key = [_indexArray objectAtIndex:tempSection];
        NSArray *allShowName = [_dataDic objectForKey:key];
        NSString *delPeople = [[allShowName objectAtIndex:indexPath.row] objectForKey:@"id"];
        [contentDic setObject:delPeople forKey:@"delete_id"];
        if([[MyAppDelegate.userInfo objectForKey:@"id"] isEqualToString:delPeople]){
            //不能删除自己
            [self showAlert:@"不能移除自己！" withTitle:nil haveCancelButton:NO];
            return;
        }

        [MYRequest requstWithDic:contentDic withUrl:API_Remove_Classmates withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO  andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
            
            //若存在error，则网络有问题
            if (error) {
                ZLog(@"%@",error);
                [self showAlert:@"网络尚未接入互联网，请检查你的网络连接！"withTitle:@"网络错误" haveCancelButton:NO];
                return ;
            }
            
            //解析数据
            NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            //如果存在erro则接口调用失败
            if ([resultDic objectForKey:@"error"]) {
                [self showAlert:[resultDic objectForKey:@"error"] withTitle:@"温馨提示" haveCancelButton:NO];
                return;
            }
            
            if(![[resultDic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:1]]){
                //删除失败
                return;
            }
            for(int i = 0; i < self.classMatesArr.count; i++){
                if([delPeople isEqualToString:[self.classMatesArr[i] objectForKey:@"id"]]){
                    self.classMatesArr = [_classMatesArr mutableCopy];
                    [self.classMatesArr removeObjectAtIndex:i];
                    _dataArray = self.classMatesArr;
                    [self initData];
                    break;
                }
            }
            refreshBlock();
            
        }];
        
    }
}
@end
