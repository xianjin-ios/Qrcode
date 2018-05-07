//
//  SelectPeopleVC.m
//  OurClass
//
//  Created by STAR on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "SelectPeopleVC.h"

@interface SelectPeopleVC ()<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *iTableView;
    NSMutableArray *_dataArray;
    
    NSMutableArray *_selectArray;
    
    NSMutableArray *_selectIndexRow;
}


@end

@implementation SelectPeopleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消点击手势
    [self cancelTapHideKeyBoard:YES];
    
    [self addRightBtn];
    
    [self changeTitle];
    
    _selectArray = [[NSMutableArray alloc]init];
    _selectIndexRow = [[NSMutableArray alloc]init];
    [self getClassMate];
}

- (void)getClassMate{
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:self.delId?self.delId:[MyAppDelegate.classInfo objectForKey:@"id"] forKey:@"cid"];
    [MYRequest requstWithDic:contentDic withUrl:API_Classmates_List withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        
        _dataArray = [resultDic objectForKey:@"classmates"];
        [iTableView reloadData];
        
    }];
}

- (void)changeTitle{
    self.title = [NSString stringWithFormat:@"已选%ld名",(unsigned long)[_selectArray count]];
    
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
    [btnRight addTarget:self action:@selector(selectOk) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItemRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    barItemRight.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = barItemRight;
}

//选好了好友
- (void)selectOk{
    
    //如果是发布照片，最多@9名
    //如果是删除照片，选中5-9名
    if (self.isPublish) {
        if (_selectArray.count > 9) {
            [self showAlert:@"你最多可选择9名同学" withTitle:@"提示" haveCancelButton:NO];
            return;
        }
    }else{
        if (_selectArray.count > 9 || _selectArray.count < 5) {
            [self showAlert:@"请选择5-9名同学" withTitle:@"提示" haveCancelButton:NO];
            return;
        }
    }

    if ([self.delegate respondsToSelector:@selector(selectPeopleArr:)]) {
        [self.delegate selectPeopleArr:_selectArray];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 列表
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *commonIdentifier = @"commonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commonIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        //头像
        UIImageView *vImgHead = [[UIImageView alloc]initWithFrame:CGRectMake(8, 17*MyAppDelegate.autoSizeScaleY/2.0, 28*MyAppDelegate.autoSizeScaleY, 28*MyAppDelegate.autoSizeScaleY)];
        vImgHead.tag = 1001;
        vImgHead.layer.cornerRadius = vImgHead.frame.size.width/2.0;
        vImgHead.layer.masksToBounds = YES;
        [cell.contentView addSubview:vImgHead];
        
        
        //名称
        UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(vImgHead.frame.origin.x + 28*MyAppDelegate.autoSizeScaleY + 10, 25*MyAppDelegate.autoSizeScaleY/2.0, 200*MyAppDelegate.autoSizeScaleFont, 20*MyAppDelegate.autoSizeScaleY)];
        lbName.font = [UIFont systemFontOfSize:DefaultContentFont];
        lbName.tag = 1002;
        [cell.contentView addSubview:lbName];
        
        UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(0, 45*MyAppDelegate.autoSizeScaleY - ONE_PIXL, SCREEN_WIDTH, ONE_PIXL)];
        vLine.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
        [cell.contentView addSubview:vLine];
        
        
        
    }
    
    NSDictionary *curDic = [_dataArray objectAtIndex:(indexPath.row)];
    UIImageView *vImgHead = (UIImageView*)[cell.contentView viewWithTag:1001];
    [vImgHead sd_setImageWithURL:[NSURL URLWithString:[curDic objectForKey:@"head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
    
    UILabel *lbName = (UILabel*)[cell.contentView viewWithTag:1002];
    lbName.text = [curDic objectForKey:@"realname"];
    
    NSString *imageName = @"icon_check.png";
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        imageName = @"icon_check_sel.png";
    UIImageView *iView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    iView.frame = CGRectMake(0, 0, 10*MyAppDelegate.autoSizeScaleY, 8*MyAppDelegate.autoSizeScaleY);
    cell.accessoryView = iView;
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45*MyAppDelegate.autoSizeScaleY;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([_selectIndexRow containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        //判断是否存在
        //删除选中
        [_selectIndexRow removeObject:[NSNumber numberWithInteger:indexPath.row]];
        [_selectArray removeObject:_dataArray[indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else{
        //如果是发布照片，最多@9名
        //如果是删除照片，选中5-9名
        if (self.isPublish) {
            if (_selectArray.count >= 9) {
                [self showAlert:@"你最多可选择9名同学" withTitle:@"提示" haveCancelButton:NO];
                return;
            }
        }else{
            if (_selectArray.count >= 9) {
                [self showAlert:@"请选择5-9名同学" withTitle:@"提示" haveCancelButton:NO];
                return;
            }
        }
        
        [_selectIndexRow addObject:[NSNumber numberWithInteger:indexPath.row]];
        [_selectArray addObject:_dataArray[indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    }
    
    [self changeTitle];
    [tableView reloadData];
}

@end
