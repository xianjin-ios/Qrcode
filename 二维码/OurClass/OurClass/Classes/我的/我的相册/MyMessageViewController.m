//
//  MyMessageViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "MyMessageViewController.h"
#import "PictureDetailVC.h"

@interface MyMessageViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>
{
    
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    int indexNum;//1-下拉刷新，0-上拉加载
}
@property (nonatomic,strong) NSMutableString *totalCount;
@property (nonatomic,strong) NSMutableArray *messageArray;
@property (nonatomic,strong) UIView *noView;

@end

@implementation MyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    indexNum = 1;
    [self cancelTapHideKeyBoard:YES];
    _messageArray = [[NSMutableArray alloc]init];
    [self getMessageDataWithPageIndex:nil];
    [self addDeleteAllMessageBtn];
    _messageTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    _messageTableView.backgroundColor = [UIColor colorWithHexString:@"efeff4"];
    [self.view addSubview:_messageTableView];
    _messageTableView.tableFooterView = [[UIView alloc]init];
    //tableview 分割线
    if ([_messageTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_messageTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_messageTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_messageTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    _header = [MJRefreshHeaderView header];
    _header.scrollView = _messageTableView;
    _header.delegate = self;
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = _messageTableView;
    _footer.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //刷新push数量
    [MyAppDelegate getPushCount];
}

#pragma mark - 刷新的代理方法---进入下拉刷新\上拉加载
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if(refreshView == _header) {// 下拉刷新
        indexNum = 1;
        [self getMessageDataWithPageIndex:nil];
        [self performSelector:@selector(endHeaderFooterLoading) withObject:nil afterDelay:1];
       
    }else if (refreshView == _footer){//上拉加载更多
        indexNum = 0;
        if (_messageArray.count != 0) {
            NSString *lastId = [[_messageArray objectAtIndex:_messageArray.count-1] objectForKey:@"id"];
            [self getMessageDataWithPageIndex:lastId ];
        }

        [self performSelector:@selector(endHeaderFooterLoading) withObject:nil afterDelay:1];
    }
}
- (void)endHeaderFooterLoading{
    [self hideHUD];
    [_header endRefreshing];
    [_footer endRefreshing];
}

//刷新push数量
- (void)updatePushCount:(NSString *)nid{
    
    if (![SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserId]) {
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserId] forKey:@"uid"];
    [contentDic setObject:nid forKey:@"nid"];
    
    [MYRequest requstWithDic:contentDic withUrl:API_PUSH_Notice_Isread withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            return ;
        }
        
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            return;
        }
        
        NSString *user_notice_count = [SSKeychain passwordForService:keyChainAccessGroup account:keyChainAppIconNumber];
        [MyAppDelegate setAppIconNumber:user_notice_count.intValue - 1];

        //重新获取push数量
        [MyAppDelegate getPushCount];
        
    }];
    
}

- (void)addDeleteAllMessageBtn{
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    deleteBtn.frame = CGRectMake(0, 0, 15, 18);
    [deleteBtn setImage:[UIImage imageNamed:@"delete_btn"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:deleteBtn]];
    
}
/**
 *  清空所有
 */
- (void)deleteAll:(id)sender{
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除所有" preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showHUD];
        NSDictionary *dic = @{};
        
        [MYRequest requstWithDic:dic withUrl:API_Clear_Notice withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
            
            //刷新push数量
            [MyAppDelegate getPushCount];
            
            //删除所有成功
            [_messageArray removeAllObjects];
            indexNum = 1;
            //无数据时的提示
            if (_messageArray.count == 0) {
                int width = _messageTableView.frame.size.width;
                int height = _messageTableView.frame.size.height;
                //无数据提示
                if (!_noView) {
                    _noView = [[UIView alloc]initWithFrame:CGRectMake(width *05 - 50, height* 0.5 - 10, 100, 100)];
                    _noView.backgroundColor = [UIColor clearColor];
                    _noView.center = CGPointMake(width/2, height/2);
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
                    [_messageTableView addSubview:_noView];
                }
            }
            else{
                
                if (_noView) {
                    [_noView removeFromSuperview];
                    _noView = nil;
                }
                
            }            
            [_messageTableView reloadData];
            
            
            
        }];
        
        
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }]];
    
    [self presentViewController:alertVc animated:YES completion:nil];
    
}
/**
 *  获取消息数据
 */
- (void)getMessageDataWithPageIndex:(NSString *)lastId{
    [self showHUD];

    if (lastId == nil) {
        lastId = @"";
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
   
    [dic setObject:lastId forKey:@"lastid"];
    [MYRequest requstWithDic:dic withUrl:API_Notice_List withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        [self hideHUD];
        
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            [self showAlert:@"网络尚未接入互联网，请检查你的网络连接！" withTitle:@"网络错误" haveCancelButton:NO];
            return ;
        }
        if (indexNum == 1) {
            [_messageArray removeAllObjects];
        }
        if (!_messageArray) {
            _messageArray = [[NSMutableArray alloc]init];
        }
        //解析数据
        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        //如果存在erro则接口调用失败
        if ([resultDic objectForKey:@"error"]) {
            [self showAlert:[resultDic objectForKey:@"error"] withTitle:@"温馨提示" haveCancelButton:NO];
            return;
        }

        //获取数据成功
        NSArray *notices = [resultDic objectForKey:@"notices"];
    
        
        [notices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [_messageArray addObject:obj];
        }];
        
        //无数据时的提示
        if (_messageArray.count == 0) {
            int width = _messageTableView.frame.size.width;
            int height = _messageTableView.frame.size.height;
            //无数据提示
            if (!_noView) {
                _noView = [[UIView alloc]initWithFrame:CGRectMake(width *05 - 50, height* 0.5 - 10, 100, 100)];
                _noView.backgroundColor = [UIColor clearColor];
                _noView.center = CGPointMake(width/2, height/2);
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
                [_messageTableView addSubview:_noView];
            }
        }
        else{
            
            if (_noView) {
                [_noView removeFromSuperview];
                _noView = nil;
            }
            if (notices.count == 0) {
                [self showAlert:@"没有更多数据" withTitle:@"提示" haveCancelButton:NO];
            }
        }
        [_messageTableView reloadData];
    }];
    
}
#pragma mark-- uitableViewdatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [_messageArray objectAtIndex:indexPath.row];
    NSString *messageType = [dic objectForKey:@"type"];//消息类型
    NSString *isDeal = [dic objectForKey:@"isdeal"];//处理状态
    
    if ([messageType isEqualToString:@"4"]) {//删除申请
        static NSString *cellId = @"helpdelete";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //头像
            UIImageView *mesImaeView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 29, 29)];
//            mesImaeView.layer.masksToBounds = YES;
            mesImaeView.layer.cornerRadius = mesImaeView.frame.size.width/2;
            [cell.contentView addSubview:mesImaeView];
            mesImaeView.tag = 101;
            
            UIView *noreadView = [self getNoReadViewWithSuperFrame:mesImaeView.frame];
            [noreadView setHidden:YES];
            [noreadView setTag:1011];
            [mesImaeView addSubview:noreadView];
            //用户
            UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2, 5, SCREEN_WIDTH - (mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2) - 100, 12)];
            userLabel.text = @"王涛涛";
            userLabel.textColor = [UIColor colorWithHexString:@"#000000"];
            userLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            [cell.contentView addSubview:userLabel];
            userLabel.tag = 102;
            //标题
            UILabel *mestitle = [[UILabel alloc]initWithFrame:CGRectMake(mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2, 18, SCREEN_WIDTH - (mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2) - 100, 20)];
            mestitle.font = [UIFont systemFontOfSize:DefaultContentFont];
            mestitle.textColor = [UIColor colorWithHexString:@"#000000"];
            mestitle.numberOfLines = 2;
            [cell.contentView addSubview:mestitle];
            mestitle.tag = 103;
            
            //状态
            UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, mesImaeView.frame.size.height + mesImaeView.frame.origin.y + 2, 55, 12)];
            stateLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            [cell.contentView addSubview:stateLabel];
            stateLabel.tag = 104;
            //图片标题
            UILabel *pictitle = [[UILabel alloc]initWithFrame:CGRectMake(55, 40, SCREEN_WIDTH - 74 - 80, 12)];
            pictitle.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            pictitle.font = [UIFont systemFontOfSize:DefaultContentFont];
            [cell.contentView addSubview:pictitle];
            pictitle.tag = 105;
            
            //时间
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 60, SCREEN_WIDTH *0.5, 10)];
            timeLabel.font = [UIFont systemFontOfSize:8*MyAppDelegate.autoSizeScaleFont];
            timeLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            [cell.contentView addSubview:timeLabel];
            timeLabel.tag = 106;
            
            //图片
            UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 8 - 63, 8,63 , 63)];
            picView.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
            [cell.contentView addSubview:picView];
            picView.tag = 107;
            
        }
        //头像
        UIImageView *mesImaeView = (UIImageView *)[cell.contentView viewWithTag:101];
        [mesImaeView sd_setImageWithURL:[NSURL URLWithString:dic[@"small_head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
        
        UIView *noreadView = [cell.contentView viewWithTag:1011];
        if ([dic[@"isread"] isEqualToString:@"0"]) {
            [noreadView setHidden:NO];
        }else{
            [noreadView setHidden:YES];

        }
        //用户
        NSString *content = dic[@"content"];
        NSRange range = [content rangeOfString:@"@"];
        NSString *user = [content substringToIndex:range.location];
        NSString *messageTitle = [content substringFromIndex:range.location];
        UILabel *userLabel = (UILabel *)[cell.contentView viewWithTag:102];
        userLabel.text = user;
        
        UILabel *mestitle = (UILabel *)[cell.contentView viewWithTag:103];
        mestitle.text = messageTitle;
        
        UILabel *stateLabel = (UILabel *)[cell.contentView viewWithTag:104];
        if ([isDeal isEqualToString:@"0"]) {
            stateLabel.textColor = [UIColor colorWithHexString:@"#0032a5"];
            stateLabel.text = @"[待处理]";
        }
        else{
            stateLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            stateLabel.text = @"[已同意]";
            
        }
        
        UILabel *pictitle = (UILabel *)[cell.contentView viewWithTag:105];
        pictitle.text = dic[@"picture_content"];
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:106];
        NSString *timeStamp = dic[@"ctime"];
        NSString *timeStr = [self stampToDate:timeStamp format:@"yyyy-MM-dd HH:mm:ss"];
        timeLabel.text = timeStr;
        UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:107];
        [picView sd_setImageWithURL:[NSURL URLWithString:dic[@"smallpicture"] ] placeholderImage:[UIImage imageNamed:@"default_photo"]];
        
        return cell;
        
    }
    else if ([messageType isEqualToString:@"2"]){
        //@你
        static NSString *cellId = @"you";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.userInteractionEnabled = YES;
            //头像
            UIImageView *mesImaeView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 29, 29)];
//            mesImaeView.layer.masksToBounds = YES;
            mesImaeView.layer.cornerRadius = mesImaeView.frame.size.width/2;
            [cell.contentView addSubview:mesImaeView];
            mesImaeView.tag = 301;
            
            UIView *noreadView = [self getNoReadViewWithSuperFrame:mesImaeView.frame];
            [noreadView setHidden:YES];
            [noreadView setTag:3011];
            [mesImaeView addSubview:noreadView];
            
            //用户
            UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2, 5, SCREEN_WIDTH - 100 - (mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2), 12)];
            userLabel.text = @"王涛涛";
            userLabel.textColor = [UIColor colorWithHexString:@"#000000"];
            userLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            [cell.contentView addSubview:userLabel];
            userLabel.tag = 302;
            //标题
            UILabel *mestitle = [[UILabel alloc]initWithFrame:CGRectMake(mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2, 18, SCREEN_WIDTH - (mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2) - 100, 20)];
            mestitle.font = [UIFont systemFontOfSize:DefaultContentFont];
            mestitle.textColor = [UIColor colorWithHexString:@"#000000"];
            mestitle.numberOfLines = 2;
            [cell.contentView addSubview:mestitle];
            mestitle.tag = 303;
            
            //班级
            
            UILabel *classLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 40, SCREEN_WIDTH - 8 - 100, 20)];
            classLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            classLabel.textColor  = [UIColor colorWithHexString:@"#b0b0b0"];
            classLabel.text = @"三年一班";
            classLabel.tag = 304;
            [cell.contentView addSubview:classLabel];
            //时间
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 60, SCREEN_WIDTH *0.5, 10)];
            timeLabel.font = [UIFont systemFontOfSize:8*MyAppDelegate.autoSizeScaleY];
            timeLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            [cell.contentView addSubview:timeLabel];
            timeLabel.tag = 305;
            
            //图片
            UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 8 - 63, 8,63 , 63)];
            picView.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
            [cell.contentView addSubview:picView];
            picView.tag = 306;
            
        }
        
        UIImageView *mesImaeView = (UIImageView *)[cell.contentView viewWithTag:301];
        [mesImaeView sd_setImageWithURL:[NSURL URLWithString:dic[@"small_head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
        
        UIView *noreadView = [cell.contentView viewWithTag:3011];
        if ([dic[@"isread"] isEqualToString:@"0"]) {
            [noreadView setHidden:NO];
        }else{
            [noreadView setHidden:YES];
            
        }
        
        NSString *content = dic[@"content"];
        NSRange range = [content rangeOfString:@"@"];
        NSString *user = [content substringToIndex:range.location];
        NSString *messageTitle = [content substringFromIndex:range.location];
        UILabel *userLabel = (UILabel *)[cell.contentView viewWithTag:302];
        userLabel.text = user;
        
        UILabel *mestitle = (UILabel *)[cell.contentView viewWithTag:303];
        mestitle.text = messageTitle ;
        
        UILabel *classLabel = (UILabel *)[cell.contentView viewWithTag:304];
        classLabel.text = dic[@"expand"];
        
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:305];
        NSString *timeStamp = dic[@"ctime"];
        NSString *timeStr = [self stampToDate:timeStamp format:@"yyyy-MM-dd HH:mm:ss"];
        timeLabel.text = timeStr;
        
        UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:306];
        [picView sd_setImageWithURL:[NSURL URLWithString:dic[@"smallpicture"] ]placeholderImage:[UIImage imageNamed:@"default_photo"] ];
        
        return cell;
        
        
    }
    else if ([messageType isEqualToString:@"3"]){
        //系统消息
        static NSString *cellId = @"system";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.userInteractionEnabled = NO;
            UIImageView *messageImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 29, 29)];
            messageImageView.image = [UIImage imageNamed:@"message_btn1"];
            messageImageView.tag = 401;
            [cell.contentView addSubview:messageImageView];
            
            //
            UILabel *desLabel = [[UILabel alloc]initWithFrame:CGRectMake(messageImageView.frame.origin.x + messageImageView.frame.size.width + 2, 8, SCREEN_WIDTH - (messageImageView.frame.origin.x + messageImageView.frame.size.width + 2 + 8), 32)];
            desLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            desLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            desLabel.numberOfLines = 3;
            desLabel.tag = 402;
            [cell.contentView addSubview:desLabel];
            
            //
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(messageImageView.frame.origin.x + messageImageView.frame.size.width + 2, 40, SCREEN_WIDTH *0.5, 10)];
            timeLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            timeLabel.font = [UIFont systemFontOfSize:8*MyAppDelegate.autoSizeScaleY];
            timeLabel.tag = 403;
            [cell.contentView addSubview:timeLabel];
        }
        
        
        UILabel *desLabel = (UILabel *)[cell.contentView viewWithTag:402];
        desLabel.text = dic[@"content"];
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:403];
        NSString *timeStamp = dic[@"ctime"];
        NSString *timeStr = [self stampToDate:timeStamp format:@"yyyy-MM-dd HH:mm:ss"];
        timeLabel.text = timeStr;
        
        return cell;
        
    }
    
    else{
        static NSString *cellId = @"joinyou";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //头像
            UIImageView *mesImaeView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 29, 29)];
//            mesImaeView.layer.masksToBounds = YES;
            mesImaeView.layer.cornerRadius = mesImaeView.frame.size.width/2;
            [cell.contentView addSubview:mesImaeView];
            mesImaeView.tag = 501;
            
            UIView *noreadView = [self getNoReadViewWithSuperFrame:mesImaeView.frame];
            [noreadView setHidden:YES];
            [noreadView setTag:5011];
            [mesImaeView addSubview:noreadView];
            
            UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2, 8, SCREEN_WIDTH - (mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2 + 8), 29)];
            userLabel.text = @"王涛涛";
            userLabel.textColor = [UIColor colorWithHexString:@"#000000"];
            userLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            userLabel.numberOfLines = 2;
            [cell.contentView addSubview:userLabel];
            userLabel.tag = 502;
            
            UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, mesImaeView.frame.size.height + mesImaeView.frame.origin.y + 2, SCREEN_WIDTH - (mesImaeView.frame.origin.x + mesImaeView.frame.size.width + 2), 13)];
            stateLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            
            [cell.contentView addSubview:stateLabel];
            stateLabel.tag = 503;
            //时间
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, stateLabel.frame.size.height + stateLabel.frame.origin.y + 3, SCREEN_WIDTH *0.5, 10)];
            timeLabel.font = [UIFont systemFontOfSize:8*MyAppDelegate.autoSizeScaleY];
            timeLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            [cell.contentView addSubview:timeLabel];
            timeLabel.tag = 504;
            
        }
        UIImageView *mesImaeView = (UIImageView *)[cell.contentView viewWithTag:501];
        [mesImaeView sd_setImageWithURL:[NSURL URLWithString:dic[@"small_head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
        

        UIView *noreadView = [cell.contentView viewWithTag:5011];
        if ([dic[@"isread"] isEqualToString:@"0"]) {
            [noreadView setHidden:NO];
        }else{
            [noreadView setHidden:YES];
            
        }
        
        UILabel *userLabel = (UILabel *)[cell.contentView viewWithTag:502];
        userLabel.text = dic[@"content"];
        
        UILabel *stateLabel = (UILabel *)[cell.contentView viewWithTag:503];
        if ([isDeal isEqualToString:@"0"]) {
            stateLabel.textColor = [UIColor colorWithHexString:@"#0032a5"];
            stateLabel.text = @"[待处理]";
        }
        else{
            stateLabel.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
            stateLabel.text = @"[已同意]";
        }
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:504];
        NSString *timeStamp = dic[@"ctime"];
        NSString *timeStr = [self stampToDate:timeStamp format:@"yyyy-MM-dd HH:mm:ss"];
        timeLabel.text = timeStr;
        
        return cell;
        
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_messageArray.count ==0) {
        return 0;
    }
    NSDictionary *dic = [_messageArray objectAtIndex:indexPath.row];
    NSString *messageType = [dic objectForKey:@"type"];//消息类型
    CGFloat height = 0;
    switch (messageType.intValue) {
        case 1:
            height = 70;
            break;
        case 2:
            height = 79;
            break;
        case 3:
            height = 55;
            break;
        case 4:
            height = 79;
            break;
        default:
            break;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:[_messageArray objectAtIndex:indexPath.row]];
    NSString *messageType = [dic objectForKey:@"type"];//消息类型
    NSString *isDeal = [dic objectForKey:@"isdeal"];//处理状态

    if ([messageType isEqualToString:@"4"]) {
        //删除信息
        [self updatePushCount:[dic objectForKey:@"id"]];
        //去掉红点
        [_messageArray removeObjectAtIndex:indexPath.row];
        //在此处理删除
        [dic setValue:@"1" forKey:@"isread"];
        [_messageArray insertObject:dic atIndex:indexPath.row];
        [_messageTableView reloadData];
        if ([isDeal isEqualToString:@"0"]) {
            //待处理
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"我同意删除该照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showHUD];

#pragma mark ----- 同意删除 接口
                NSDictionary *content = @{@"nid":[dic objectForKey:@"id"],
                                          };
                [MYRequest requstWithDic:content withUrl:API_Agree_Apply withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
                    
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
                    [_messageArray removeObjectAtIndex:indexPath.row];
                    //在此处理删除
                    [dic setValue:@"1" forKey:@"isdeal"];
                    [dic setValue:@"1" forKey:@"isread"];
                    [_messageArray insertObject:dic atIndex:indexPath.row];
                    [_messageTableView reloadData];

                }];
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    }
    else if ([messageType isEqualToString:@"1"]) {
        [self updatePushCount:[dic objectForKey:@"id"]];
        //去掉红点
        [_messageArray removeObjectAtIndex:indexPath.row];
        //在此处理删除
        [dic setValue:@"1" forKey:@"isread"];
        [_messageArray insertObject:dic atIndex:indexPath.row];
        [_messageTableView reloadData];
        
        if ([isDeal isEqualToString:@"0"]) {
            //确定让其加入
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"我同意该同学加入班级" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //在此处理同意加入
                [self showHUD];

                NSDictionary *agreeDic = @{@"nid":[dic objectForKey:@"id"]};
                
                [MYRequest requstWithDic:agreeDic withUrl:API_Agree_Apply withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
                    [_messageArray removeObjectAtIndex:indexPath.row];
                    //在此处理删除
                    [dic setValue:@"1" forKey:@"isdeal"];
                    [dic setValue:@"1" forKey:@"isread"];
                    [_messageArray insertObject:dic atIndex:indexPath.row];
                    [_messageTableView reloadData];


                }];
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    }else if ([messageType isEqualToString:@"2"]){
        //@你  进入信息详情
        NSString *aid = dic[@"aid"];
        NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 aid,@"id",
                                 nil];
        [self updatePushCount:[dic objectForKey:@"id"]];

        [_messageArray removeObjectAtIndex:indexPath.row];
        [dic setValue:@"1" forKey:@"isread"];
        [_messageArray insertObject:dic atIndex:indexPath.row];
        [_messageTableView reloadData];
        
        PictureDetailVC *vc = [[PictureDetailVC alloc] initWithInfoDic:tempDic];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }
    
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