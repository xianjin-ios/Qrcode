//
//  MyPhotoViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "MyPhotoViewController.h"
#import "MyMessageViewController.h"
#import "PictureDetailVC.h"
@interface MyPhotoViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,ChangeDianzan_delegate>
{
    NSInteger _index;//标记年份
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    BOOL yearIsChange;
    int indexNum;//1-下拉刷新，0-上拉加载
    
    NSInteger selectIndex;
    
    UIView *noReadView;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (nonatomic,strong) NSMutableString *totalCount;
@property (nonatomic,strong) NSMutableArray *photoArray;
@property (nonatomic,strong) UITableView *photoTableView;
@property (nonatomic,strong) UIView *noView;
@property (nonatomic,strong) NSString *today;//存储今天的时间
@property (nonatomic,strong) NSString *nowYear;//现年年份字符串
@property (nonatomic,strong) UITableView *timeBtnTableView;
@property (nonatomic,strong) NSMutableArray *timeBtnArray;


@end

@implementation MyPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"相册";
    _index = 0;
    indexNum = 1;
    _mainScrollView.scrollEnabled = NO;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    _timeBtnArray = [[NSMutableArray alloc]init];
     _photoArray = [[NSMutableArray alloc]init];
    NSDate *dateNow = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy:MM:dd"];
    _today = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate: dateNow]];
    _nowYear = [NSString stringWithFormat:@"%@",[_today substringToIndex:4]];
    
    [self cancelTapHideKeyBoard:YES];
    [self addMyMessage];
    [self hideBackButton:NO];
    [self initUI];
    [self getDatafromNetWithYear:[self stringToStamp:[NSString stringWithFormat:@"%@",_nowYear] format:@"yyyy"] withLastId:@""];
    _header = [MJRefreshHeaderView header];
    _header.scrollView = _photoTableView;
    _header.delegate = self;
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = _photoTableView;
    _footer.delegate = self;
    
    //注册通知，刷新未读提示
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNoread) name:@"refreshNoreadView" object:nil];
}

- (void)refreshNoread{
    if (MyAppDelegate.NoticeCount.intValue > 0) {
        [noReadView setHidden:NO];
    }else{
        [noReadView setHidden:YES];
    }
}

#pragma mark - 刷新的代理方法---进入下拉刷新\上拉加载
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if(refreshView == _header) {// 下拉刷新
        indexNum = 1;
        NSString *year = [self stringToStamp:[NSString stringWithFormat:@"%@",_timeBtnArray[_index]] format:@"yyyy"];
        [self getDatafromNetWithYear:year withLastId:@""];
        [self performSelector:@selector(endHeaderFooterLoading) withObject:nil afterDelay:1];
    }else if (refreshView == _footer){//上拉加载更多
        indexNum = 0;
            NSString *year = [self stringToStamp:[NSString stringWithFormat:@"%@",_timeBtnArray[_index]] format:@"yyyy"];
        if (_photoArray.count != 0) {
            NSString *lastId = [[_photoArray objectAtIndex:_photoArray.count - 1] objectForKey:@"id"];
            [self getDatafromNetWithYear:year withLastId:lastId];
        }
        

        [self performSelector:@selector(endHeaderFooterLoading) withObject:nil afterDelay:1];
    }
}
- (void)endHeaderFooterLoading{
    [self hideHUD];
    [_header endRefreshing];
    [_footer endRefreshing];
}
- (void)initUI{
    [self initTableview];
    NSDictionary *userinfo = MyAppDelegate.userInfo;
    //头像
    UIView *topview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 102)];
    topview.backgroundColor = [UIColor clearColor];
    [_mainScrollView addSubview:topview];
    UIImageView *picImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 50, 42, 42)];
    [picImageView  sd_setImageWithURL:[NSURL URLWithString:[userinfo objectForKey:@"head_icon"]]placeholderImage:[UIImage imageNamed:@"default_head"]];
    picImageView.layer.masksToBounds = YES;
    picImageView.layer.cornerRadius = 21;
    [topview addSubview:picImageView];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(8, 101, SCREEN_WIDTH - 16, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [topview addSubview:lineView];
    //名字
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(53, 70, SCREEN_WIDTH - 80, 22)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:13];
    nameLabel.text = [userinfo objectForKey:@"realname"];
    [topview addSubview:nameLabel];
    [self addTimeBtns];//获取时间Data
}
- (void)initTableview{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(60, 112, SCREEN_WIDTH - 60, SCREEN_HEIGHT - 112 - 3- AltitudeHeight)];
    backView.backgroundColor = [UIColor clearColor];
    [_mainScrollView addSubview:backView];
    _photoTableView = [[UITableView alloc]initWithFrame:backView.bounds style:UITableViewStylePlain];
    _photoTableView.backgroundColor = [UIColor clearColor];
//    _photoTableView.bounces = NO;
    _photoTableView.delegate = self;
    _photoTableView.dataSource = self;
    _photoTableView.showsVerticalScrollIndicator = NO;
    _photoTableView.showsHorizontalScrollIndicator = NO;
    //分割线
    if ([_photoTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_photoTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_photoTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_photoTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    _photoTableView.tableFooterView = [[UIView alloc]init];
    _photoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [backView addSubview:_photoTableView];
    _timeBtnTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 112 , 50, SCREEN_HEIGHT - 64 -112) style:UITableViewStylePlain];
    _timeBtnTableView.delegate = self;
    _timeBtnTableView.dataSource = self;
    _timeBtnTableView.showsHorizontalScrollIndicator = NO;
    _timeBtnTableView.showsVerticalScrollIndicator = NO;
    _timeBtnTableView.tableFooterView = [[UIView alloc]init];
    _timeBtnTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _timeBtnTableView.backgroundColor = [UIColor clearColor];
    [_mainScrollView addSubview:_timeBtnTableView];
    
}
- (void)addTimeBtns{
   //注册的年份
    NSString *ctime = [self stampToDate:[MyAppDelegate.userInfo objectForKey:@"ctime"] format:@"yyyy"];
    for (int i = _nowYear.intValue; i >= ctime.intValue; i--) {
       
        [_timeBtnArray addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    if (_timeBtnTableView.frame.size.height / 35 >_timeBtnArray.count) {
        _timeBtnTableView.scrollEnabled = NO;
    }
    else
        _timeBtnTableView.scrollEnabled = YES;

}

- (void)getDatafromNetWithYear:(NSString *)year withLastId:(NSString *)lastId{
    [self showHUD];
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc]init];

    [contentDic setObject:year forKey:@"year"];
    [contentDic setObject:lastId forKey:@"lastid"];
  
    NSLog(@"contentDic = %@",contentDic);
    [MYRequest requstWithDic:contentDic withUrl:API_My_Album withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
        if (yearIsChange) {
            yearIsChange = NO;
            [_photoArray removeAllObjects];
        }
        if (indexNum == 1) {
            [_photoArray removeAllObjects];
        }
    
        if (!_photoArray) {
            _photoArray = [[NSMutableArray alloc]init];
        }
        //获取数据成功
        NSArray *albums = [resultDic objectForKey:@"album"];
       
        [albums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_photoArray addObject:obj];
        }];
        if (_photoArray.count == 0) {
            int width = _photoTableView.frame.size.width;
            int height = _photoTableView.frame.size.height;
            //无数据提示
            if (!_noView) {
                _noView = [[UIView alloc]initWithFrame:CGRectMake(width *05+200, height* 0.5, 100*MyAppDelegate.autoSizeScaleFont, 100*MyAppDelegate.autoSizeScaleFont)];
                _noView.backgroundColor = [UIColor clearColor];
                _noView.center = CGPointMake(width/2 , height/2 - 100);
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
                [_photoTableView addSubview:_noView];
            }
        }
        else{
            
            if (_noView) {
                [_noView removeFromSuperview];
                _noView = nil;
            }
           if (albums.count == 0) {
                    [self showAlert:@"没有更多内容了" withTitle:@"提示" haveCancelButton:NO];
                
                }
    
        }
        
        [_photoTableView reloadData];
        
    }];
    
}



/**
 *  我的消息的按钮
 */
- (void)addMyMessage{
    
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    messageBtn.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 30, (self.navigationController.navigationBar.frame.size.height - 18)/2, 16, 18);
    [messageBtn setImage:[UIImage imageNamed:@"icon_home_ring"] forState:UIControlStateNormal];
    
    noReadView = [self getNoReadViewWithSuperFrame:messageBtn.frame];
    [messageBtn addSubview:noReadView];
    
    if (MyAppDelegate.NoticeCount.intValue > 0) {
        [noReadView setHidden:NO];
    }else{
        [noReadView setHidden:YES];
    }
    
    [messageBtn addTarget:self action:@selector(gotoMyMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:messageBtn];
}

- (void)goBack:(id)sender{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self showSideView];
}

/**
 *  进入我的消息
 */
- (void)gotoMyMessage:(id)sender{
    MyMessageViewController *messageVC = [[MyMessageViewController alloc]init];
    
    [self.navigationController pushViewController:messageVC animated:YES];
    
}

#pragma mark-- tableViewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _timeBtnTableView) {
        return _timeBtnArray.count;
    }
    return _photoArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _timeBtnTableView) {
        static NSString *cellid = @"year";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIButton *timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            timeBtn.userInteractionEnabled = NO;
            timeBtn.frame = CGRectMake(0,5, 40, 20);
            timeBtn.tag = 200;
            timeBtn.backgroundColor = [UIColor cyanColor];
            [cell.contentView addSubview:timeBtn];
            UILabel *lbBtn = [[UILabel alloc]initWithFrame:timeBtn.frame];
            [lbBtn setTextColor:[UIColor whiteColor]];
            lbBtn.backgroundColor = [UIColor clearColor];
            [lbBtn setTextAlignment:NSTextAlignmentCenter];
            [lbBtn setFont:[UIFont systemFontOfSize:DefaultContentFont]];
            lbBtn.tag = 210;
            [cell.contentView addSubview:lbBtn];

        }
        UIButton *timeBtn = (UIButton *)[cell.contentView viewWithTag:200];
        if (_index == indexPath.row) {
            [timeBtn setBackgroundColor:[UIColor clearColor]];
            [timeBtn setAlpha:1];
            timeBtn.layer.cornerRadius = timeBtn.frame.size.height/2;
            timeBtn.layer.borderWidth = 0.5;
            timeBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        }
        else{
            
            [timeBtn setBackgroundColor:[UIColor whiteColor]];
            [timeBtn setAlpha:0.2];
            timeBtn.layer.cornerRadius = timeBtn.frame.size.height/2;
            timeBtn.layer.borderWidth = 0.5;
            timeBtn.layer.borderColor = [[UIColor clearColor] CGColor];
            
        }
        UILabel *lbBtn = (UILabel *)[cell.contentView viewWithTag:210];
        [lbBtn setText:[NSString stringWithFormat:@"%@",_timeBtnArray[indexPath.row]]];
        
        return cell;
    }
    else{
    NSDictionary *photoDic = [_photoArray objectAtIndex:indexPath.row];
   
    static NSString *cellId = @"photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        //时间
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 55, 17*MyAppDelegate.autoSizeScaleFont)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
        [cell.contentView addSubview:timeLabel];
        timeLabel.tag = 305;
        
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, _photoTableView.frame.size.width  - 75, 10*MyAppDelegate.autoSizeScaleFont)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
        [cell.contentView addSubview:titleLabel];
        titleLabel.tag = 301;
        //图片
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+70, 30, 63*MyAppDelegate.autoSizeScaleFont, 63*MyAppDelegate.autoSizeScaleFont)];
        imageView.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
        imageView.image = [UIImage imageNamed:@"default_photo"];
        imageView.tag = 302;
        [cell.contentView addSubview:imageView];
        //班级
        UILabel *classLabel = [[UILabel alloc]initWithFrame:CGRectMake(73*MyAppDelegate.autoSizeScaleFont+75, 60 + 1*MyAppDelegate.autoSizeScaleFont, _photoTableView.frame.size.width - 75 -75, 12*MyAppDelegate.autoSizeScaleFont)];
        classLabel.textColor = [UIColor colorWithHexString:@"#b0aeac"];
        classLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        classLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
        classLabel.text = @"三年三班";
        classLabel.tag = 303;
        [cell.contentView addSubview:classLabel];
        //学校
        UILabel *schoolLabel = [[UILabel alloc]initWithFrame:CGRectMake(73*MyAppDelegate.autoSizeScaleFont+75, 75 + 1*MyAppDelegate.autoSizeScaleFont, _photoTableView.frame.size.width - 75 -75, 12*MyAppDelegate.autoSizeScaleFont)];
        schoolLabel.textColor = [UIColor colorWithHexString:@"#b0aeac"];
        schoolLabel.text = @"北京小学";
        schoolLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        schoolLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
        schoolLabel.tag = 304;
        [cell.contentView addSubview:schoolLabel];
        //时间轴线
        //竖线
        UIView *lineView = [[UIView alloc]init];
        lineView.tag = 306;
        lineView.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:lineView];
        //白点
        UILabel *whiteLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 15, 7, 7)];
        whiteLabel.layer.masksToBounds = YES;
        whiteLabel.layer.cornerRadius = whiteLabel.bounds.size.width *0.5;
        whiteLabel.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:whiteLabel];
        
    }
    //时间
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:305];

     NSString *timeStamp = [photoDic objectForKey:@"ctime"];
    NSString *timeStr = [self stampToDate:timeStamp format:@"yyyy:MM:dd"];
    if ([timeStr isEqualToString:_today]) {
        timeLabel.font = [UIFont systemFontOfSize:12* MyAppDelegate.autoSizeScaleFont];
        timeLabel.text = @"今天";

    }
    else{

        NSString *day = nil;
        if ([timeStr substringFromIndex:8].intValue<10) {
           day = [[timeStr substringFromIndex:8] substringFromIndex:1];
        }
        else
           day = [timeStr substringFromIndex:8];
        
        //月份
        NSRange range = {5,2};
        NSString *month = [timeStr substringWithRange:range];
        if (month.intValue<10) {
            month = [month substringFromIndex:1];
        }

        NSString *monthStr = nil;
        switch (month.intValue) {
            case 1:
                monthStr = @"一月";
                break;
            case 2:
                monthStr = @"二月";
                break;
            case 3:
                monthStr = @"三月";
                break;
            case 4:
                monthStr = @"四月";
                break;
            case 5:
                monthStr = @"五月";
                break;
            case 6:
                monthStr = @"六月";
                break;
            case 7:
                monthStr = @"七月";
                break;
            case 8:
                monthStr = @"八月";
                break;
            case 9:
                monthStr = @"九月";
                break;
            case 10:
                monthStr = @"十月";
                break;
            case 11:
                monthStr = @"十一月";
                break;
            case 12:
                monthStr = @"十二月";
                break;
            default:
                break;
        }
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",day,monthStr]];
        int dayLength = day.length;
        [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12*MyAppDelegate.autoSizeScaleFont] range:NSMakeRange(0, dayLength)];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9*MyAppDelegate.autoSizeScaleFont] range:NSMakeRange(dayLength , monthStr.length )];
        timeLabel.font = [UIFont systemFontOfSize:9* MyAppDelegate.autoSizeScaleFont];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.attributedText = attributeString;
        
    }
    UIView *lineView = (UIView *)[cell.contentView viewWithTag:306];
        if (_photoArray.count >1) {
            
            if (indexPath.row == 0) {
                
                lineView.frame = CGRectMake(58 + 5, 15, 1, 105*MyAppDelegate.autoSizeScaleFont-15);
                
            }
            else if (indexPath.row == _photoArray.count - 1) {
                lineView.frame = CGRectMake(58 + 5, 0, 1, 16*MyAppDelegate.autoSizeScaleFont);
                
            }
            
            else{
                lineView.frame = CGRectMake(58 + 5, 0, 1, 105*MyAppDelegate.autoSizeScaleFont);
                
            }
        }
 
    //
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:301];
    titleLabel.text = [photoDic objectForKey:@"content"];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:302];
    [imageView sd_setImageWithURL:[NSURL URLWithString:photoDic[@"smallpicture"]] placeholderImage:[UIImage imageNamed:@"default_photo"]];
    
    UILabel *classLabel = (UILabel *)[cell.contentView viewWithTag:303];
    classLabel.text = [photoDic objectForKey:@"classname"];
    
    UILabel *schoolLabel = (UILabel *)[cell.contentView viewWithTag:304];
    schoolLabel.text = [photoDic objectForKey:@"schoolname"];
    return cell;
    
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _timeBtnTableView) {
        return 30;
    }
    return 105*MyAppDelegate.autoSizeScaleFont;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _timeBtnTableView) {
        if (_index == indexPath.row) {
            return;
        }
        _index = indexPath.row;
      
        yearIsChange = YES;
        NSString *year = [self stringToStamp:[NSString stringWithFormat:@"%@",_timeBtnArray[_index]] format:@"yyyy"];
        [self getDatafromNetWithYear:year withLastId:@""];
        [_timeBtnTableView reloadData];
    }
    
    else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[_photoArray objectAtIndex:indexPath.row]];
        [dic setValue:MyAppDelegate.userInfo[@"small_head_icon"] forKey:@"small_head_icon"];
        [dic setValue:MyAppDelegate.userInfo[@"id"] forKey:@"uid"];//发布者的id
        [dic setValue:MyAppDelegate.userInfo[@"realname"] forKey:@"realname"];
        
        selectIndex = indexPath.row;
        PictureDetailVC *picDetailVC = [[PictureDetailVC alloc]initWithInfoDic:dic];
        picDetailVC.delegate = self;
        [self.navigationController pushViewController:picDetailVC animated:YES];
    }
}

-(void)changeDianzan:(NSDictionary *)newDic{
    
    [_photoArray replaceObjectAtIndex:selectIndex withObject:newDic];
    
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
