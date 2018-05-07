//
//  SelectSchoolViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/11.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "SelectSchoolViewController.h"
#import "SelectClassViewController.h"
#import "CreateClassViewController.h"
@interface SelectSchoolViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSInteger currentSection;
    NSInteger currentIndex;
    BOOL isSelectProvince;
    BOOL isSelectCity;
    BOOL isShowIndex;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (nonatomic,strong) NSMutableArray *indexArr;
//存储学校信息
@property (nonatomic,strong) NSMutableArray *dataArray;

//存储全国的城市--假数据从area.plist文件中获取
@property (nonatomic,strong) NSMutableArray *cityArr;
@property (nonatomic,strong) NSMutableArray *provinceArray;
@property (nonatomic,strong) UIButton *provinceBtn;
@property (nonatomic,strong) UIButton *cityBtn;
@property (nonatomic,strong) UITableView *provinceTableView;
@property (nonatomic,strong) UITableView *cityTableView;
@property (nonatomic,strong) UITableView *schoolTableView;
@property (nonatomic,strong) UIImageView *provinceImageView;
@property (nonatomic,strong) UIImageView *cityImageView;
@property (nonatomic,strong) UIView *noView;


@end

@implementation SelectSchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择学校";
    _indexArr = [[NSMutableArray alloc]init];
    [_indexArr addObject:@""];
    currentIndex = -1;
    currentSection = -1;
    isShowIndex = 0;
    //初始化数据源
    _mainScrollView.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    _dataArray = [[NSMutableArray alloc]init];
    
    _cityArr = [[NSMutableArray alloc]init];
    _provinceArray = [[NSMutableArray alloc]init];
    isSelectCity = NO;
    isSelectProvince = NO;
    [self getCityData];
    //初始化tableView们
    [self initTableViews];
    [self addSchoolAtCityBtns];
    
    //取消view上的tap点击
    [self cancelTapHideKeyBoard:YES];
    [self addCreateSchoolBtn];

}
- (void)initTableViews{
    
    //school
    _schoolTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0 + 40, SCREEN_WIDTH, SCREEN_HEIGHT  - 64 - 40 - 0) style:UITableViewStylePlain];
    NSLog(@"Scroll = %f,%f,%f",_mainScrollView.frame.size.height,self.view.frame.size.height,_schoolTableView.frame.size.height);
    _schoolTableView.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    _schoolTableView.delegate = self;
    _schoolTableView.dataSource = self;
    //tableview 分割线
    if ([_schoolTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_schoolTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_schoolTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_schoolTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    _schoolTableView.tableFooterView = [[UIView alloc]init];
    [_mainScrollView addSubview:_schoolTableView];
    
    //province
    _provinceTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0+40, SCREEN_WIDTH *0.5 - 1, 0)];
    _provinceTableView.delegate = self;
    _provinceTableView.dataSource = self;
    _provinceTableView.backgroundColor = [UIColor lightGrayColor];
    _provinceTableView.tableFooterView = [[UIView alloc]init];
    //tableview 分割线
    if ([_provinceTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_provinceTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_provinceTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_provinceTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [_mainScrollView addSubview:_provinceTableView];
    
    //city
    _cityTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.5+0.5, 0+40, SCREEN_WIDTH *0.5-1, 0) style:UITableViewStylePlain];
    _cityTableView.delegate = self;
    _cityTableView.dataSource = self;
    _cityTableView.backgroundColor = [UIColor clearColor];
    _cityTableView.tableFooterView = [[UIView alloc]init];
    //tableview 分割线
    if ([_cityTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_cityTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_cityTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_cityTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [_mainScrollView addSubview:_cityTableView];
    
}
- (void)addSchoolAtCityBtns{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    topView.backgroundColor = [UIColor colorWithHexString:@"#aeaeae"];
    [_mainScrollView addSubview:topView];
    UIView *proView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH *0.5 - 0.5 , 35)];
    proView.backgroundColor = [UIColor colorWithHexString:@"#929292"];
    [topView addSubview:proView];
    UILabel *proviceLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.25 - 65, 0, 110, 35)];
    proviceLabel.textColor = [UIColor whiteColor];
    proviceLabel.text = @"学校所在省份";
    proviceLabel.font = [UIFont systemFontOfSize:DefaultTitleFont];
    proviceLabel.textAlignment = NSTextAlignmentRight;
    [proView addSubview:proviceLabel];
    self.provinceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.25 +50, 15, 13, 9)];
    _provinceImageView.image = [UIImage imageNamed:@"help_down"];
    [proView addSubview:_provinceImageView];
    _provinceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _provinceBtn.frame = proView.bounds;
    [_provinceBtn addTarget:self action:@selector(selectProvince:) forControlEvents:UIControlEventTouchUpInside];
    [proView addSubview:_provinceBtn];
    
    UIView *cityView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.5 , 0, SCREEN_WIDTH *0.5-0.5 , 35)];
    cityView.backgroundColor = [UIColor colorWithHexString:@"#929292"];
    [topView addSubview:cityView];
    
    UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.25 - 65, 0, 110, 35)];
    cityLabel.font = [UIFont systemFontOfSize:DefaultTitleFont];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"学校所在城市";
    cityLabel.textAlignment = NSTextAlignmentRight;
    [cityView addSubview:cityLabel];
    self.cityImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.25 +50, 15, 13, 9)];
    _cityImageView.image = [UIImage imageNamed:@"help_down"];
    [cityView addSubview:_cityImageView];
    _cityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cityBtn.frame = cityView.bounds;
    [_cityBtn addTarget:self action:@selector(selectCity:) forControlEvents:UIControlEventTouchUpInside];
    [cityView addSubview:_cityBtn];
    
    
}
#pragma mark --- 创建学校
/**
 *  创建学校
 */
- (void)addCreateSchoolBtn{
    
    UIImageView *createImage = [[UIImageView alloc]initWithFrame:CGRectMake(49, 9, 31, 31)];
    createImage.image = [UIImage imageNamed:@"createclass_btn"];
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT- 100- 44, 80, 50);
    [createBtn addTarget:self action:@selector(createSchool:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:createBtn];
    [createBtn addSubview:createImage];
}
- (void)createSchool:(id)sender{
    [self createAlertView];
}
/**
 *  创建提示框
 */
- (void)createAlertView{
    
    //判断 alertView是否已经存在
    UIView *alertView = (UIView *)[_mainScrollView viewWithTag:1000];
    if (alertView != nil) {
        [alertView removeFromSuperview];
    }
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.7;
    backView.tag = 500;
    [_mainScrollView addSubview:backView];
    alertView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.5 - 258 *0.5, SCREEN_VIEW_HEIGHT *0.5 - 80,258, 160 )];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.tag = 1000;
    [_mainScrollView addSubview:alertView];
    UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, alertView.frame.size.width, 40)];
    alertLabel.font = [UIFont systemFontOfSize:18];
    alertLabel.text = @"未查到学校？";
    alertLabel.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:alertLabel];
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 40, alertView.frame.size.width, 30)];
    textField.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
    textField.placeholder = @" 请在这里填写你想申请开通的学校（包括学校所在省市）";
    textField.font = [UIFont systemFontOfSize:11];
    [textField setValue:[UIColor colorWithHexString:@"#c2c2c2"] forKeyPath:@"_placeholderLabel.color"];
    [textField setValue:[UIFont systemFontOfSize:10] forKeyPath:@"_placeholderLabel.font"];
    textField.borderStyle = UITextBorderStyleNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    textField.tag = 1001;
    [alertView addSubview:textField];
    UILabel *lixiLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, SCREEN_WIDTH *0.5, 10)];
    lixiLabel.text = @"如24小时内未开通请联系我们";
    lixiLabel.font = [UIFont systemFontOfSize:8*MyAppDelegate.autoSizeScaleFont];
    [alertView addSubview:lixiLabel];
    UILabel *emailLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 92, SCREEN_WIDTH *0.5 + 50, 10)];
    emailLabel.text = @"E-mail:educational@welass.com";
    emailLabel.font = [UIFont systemFontOfSize:8*MyAppDelegate.autoSizeScaleFont];
    [alertView addSubview:emailLabel];
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(alertView.frame.size.width - 100, alertView.frame.size.height - 45, 100, 40);
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:12*MyAppDelegate.autoSizeScaleFont];
    [confirmBtn setTitleColor:[UIColor colorWithHexString:@"#0032a5"] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirm1:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:confirmBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, alertView.frame.size.height - 45, 100, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12 *MyAppDelegate.autoSizeScaleFont];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#0032a5"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelCreateSchool:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:cancelBtn];

}
- (void)cancelCreateSchool:(id)sender{
    //判断 alertView是否已经存在
    UIView *alertView = (UIView *)[_mainScrollView viewWithTag:1000];
    if (alertView != nil) {
        [alertView removeFromSuperview];
        alertView = nil;
    }
    UIView *backView = (UIView *)[_mainScrollView viewWithTag:500];
    if (backView) {
        [backView removeFromSuperview];
        backView = nil;
    }
    
}
/**
 *  确定申请创建按钮的响应
 *
 */
- (void)confirm1:(id)sender{
    //
    

    UIView *alertView = (UIView *)[_mainScrollView viewWithTag:1000];
    UITextField *textField = (UITextField *)[alertView viewWithTag:1001];
    if ([textField.text isEqualToString:@""]) {
        [self showAlert:@"请填写你想申请开通的学校" withTitle:@"温馨提示" haveCancelButton:NO];
        return;
    }
        [self showHUD];
    //网络请求，申请创建学校
    NSDictionary *dic = @{
                          @"content":textField.text
                          };
    [MYRequest requstWithDic:dic withUrl:API_Apply_School withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        //提交申请成功
        if (alertView != nil) {
            [alertView removeFromSuperview];
        }
        UIView *backView = (UIView *)[_mainScrollView viewWithTag:500];
        if (backView != nil) {
            [backView removeFromSuperview];
        }
        [self showAlert:@"申请已提交，请耐心等待" withTitle:@"温馨提示" haveCancelButton:NO];
        
    }];
}
/**
 *  选择省份
 *
 */
- (void)selectProvince:(id)sender{
    isSelectProvince = !isSelectProvince;
    if (isSelectProvince) {
        _provinceImageView.image = [UIImage imageNamed:@"help_up"];
        [UIView beginAnimations:nil context:nil];
        [_provinceTableView setFrame:CGRectMake(0, 0+35, SCREEN_WIDTH *0.5 - 1, 300)];
        [UIView commitAnimations];
    }
    else{
        _provinceImageView.image = [UIImage imageNamed:@"help_down"];
        [UIView beginAnimations:nil context:nil];
        [_provinceTableView setFrame:CGRectMake(0, 0+35, SCREEN_WIDTH *0.5 - 1, 0)];
        [UIView commitAnimations];
    }
}
/**
 *  选择城市
 *
 */
- (void)selectCity:(id)sender{
    isSelectCity = !isSelectCity;
    if (isSelectCity) {
        _cityImageView.image = [UIImage imageNamed:@"help_up"];
        [UIView beginAnimations:nil context:nil];
        [_cityTableView setFrame:CGRectMake(SCREEN_WIDTH *0.5+0.5, 0+35, SCREEN_WIDTH *0.5-1, 300)];
        [UIView commitAnimations];
    }
    else{
        _cityImageView.image = [UIImage imageNamed:@"help_down"];
        [UIView beginAnimations:nil context:nil];
        [_cityTableView setFrame:CGRectMake(SCREEN_WIDTH *0.5+0.5, 0+35, SCREEN_WIDTH *0.5-1, 0)];
        [UIView commitAnimations];
    }
}
#pragma mark -- 获取数据
/**
 *  获取城市数据
 */
- (void)getCityData{
    [self showHUD];
    NSDictionary *dic = @{
                          };
    [MYRequest requstWithDic:dic withUrl:API_Region_List withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        [self hideHUD];
        //若存在error，则网络有问题
        if (error) {
            ZLog(@"%@",error);
            [self showAlert:@"网络尚未接入互联网，请检查你的网络连接！" withTitle:@"网络错误" haveCancelButton:NO];
            return ;
        }
        
        NSDictionary *region = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        //如果存在erro则接口调用失败
        if ([region objectForKey:@"error"]) {
            [self showAlert:[region objectForKey:@"error"] withTitle:@"温馨提示" haveCancelButton:NO];
            return;
        }
        
        NSArray *provinces = [region objectForKey:@"region"];
        for (NSDictionary *proDic in provinces) {
            [_provinceArray addObject:proDic];
        }
        [_provinceTableView reloadData];
    }];
    
}
- (void)getSchoolDataWithCityDic:(NSDictionary *)cityDic{
    [self showHUD];
    
    NSDictionary *dic = @{
                          @"province":cityDic[@"pid"],//省份
                          @"city":cityDic[@"id"]//城市
                          };
    [MYRequest requstWithDic:dic withUrl:API_School_List withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
        if (_dataArray.count != 0) {
            [_dataDic removeAllObjects];
            [_indexArr removeAllObjects];
            [_dataArray removeAllObjects];
        }
        NSArray *schools = [resultDic objectForKey:@"schools"];
        [schools enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_dataArray addObject:obj];
        }];
        if (_dataArray.count == 0) {
            int width = _schoolTableView.frame.size.width;
            int height = _schoolTableView.frame.size.height;
            //无数据提示
            if (!_noView) {
                _noView = [[UIView alloc]initWithFrame:CGRectMake(width *05 - 50, height* 0.5, 100, 100)];
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
                [_schoolTableView addSubview:_noView];
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
            _indexArr = [self getIndexArr:_dataArray];
            NSLog(@"%@",_indexArr);
            for (NSString *indexStr in _indexArr) {
                NSMutableArray *rowSource = [[NSMutableArray alloc] init];
                for (NSDictionary *schoolDic in _dataArray) {
                    NSString *charString = [schoolDic objectForKey:@"schoolname"];
                    char firstChar = pinyinFirstLetter([charString characterAtIndex:0]);
                    NSString *youName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
                    if ([indexStr isEqualToString:youName]) {
                        [rowSource addObject:schoolDic];
                    }
                }
                [_dataDic setValue:rowSource forKey:indexStr];
            }
            
        }
        
        [_schoolTableView reloadData];
        
    }];
    
}
//获取数组中的首字母合集
- (NSMutableArray *)getIndexArr:(NSArray *)arr{
    NSMutableArray *indexArray = [NSMutableArray array];
    //获取字母列表
    for (int i = 0; i <arr.count; i++) {
        NSString *schoolname = [[arr objectAtIndex:i]objectForKey:@"schoolname"];
        char firstChar = pinyinFirstLetter([schoolname characterAtIndex:0]);
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

#pragma  mark --- tableviewDatasource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView == _schoolTableView) {
        if (isShowIndex) {
            return _indexArr;
        }
    }
    
    return nil;
}
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == _schoolTableView) {
        if (_dataArray.count!=0) {
            NSInteger tempSection = section;
            NSString *key = [_indexArr objectAtIndex:tempSection];
            return [@"  " stringByAppendingString:key];
        }
        else
            return nil;
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _schoolTableView) {
        return _indexArr.count;
    }
    else{
        return 1;
    }
    
    
}
/**
 *  <#Description#>
 *
 *  @param tableView <#tableView description#>
 *  @param title     <#title description#>
 *  @param index     <#index description#>
 *
 *  @return <#return value description#>
 */
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
    if (tableView == _provinceTableView) {
        return _provinceArray.count;
    }
    if (tableView == _cityTableView) {
        return _cityArr.count;
    }
    else{
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
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _provinceTableView) {
        
        static NSString *cellid = @"province";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.backgroundColor = [UIColor lightGrayColor];
            
            UILabel *provinceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, cell.contentView.frame.size.width - 10, 30)];
            provinceLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            
            provinceLabel.tag = 23;
            [cell.contentView addSubview:provinceLabel];
        }
        
        NSDictionary *proDic = _provinceArray[indexPath.row];
        UILabel *provinceLabel = (UILabel *)[cell.contentView viewWithTag:23];
        provinceLabel.text = proDic[@"regionname"];
        return cell;
    }
    if (tableView == _cityTableView) {
        static NSString *cellid = @"city";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
            cell.backgroundColor = [UIColor lightGrayColor];
            
            UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, cell.contentView.frame.size.width - 10, 30)];
            cityLabel.font = [UIFont systemFontOfSize:DefaultContentFont];
            
            cityLabel.tag = 24;
            [cell.contentView addSubview:cityLabel];
            
        }
        UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:24];
        NSDictionary *cityDic = _cityArr[indexPath.row];
        cityLabel.text = cityDic[@"regionname"];
        
        return cell;
    }
    static NSString *cellid = @"school";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //获取section上的串
    NSString *indexStr = [_indexArr objectAtIndex:indexPath.section];
    NSArray *schoolArr = [_dataDic objectForKey:indexStr];
    NSDictionary *schoolDic = schoolArr[indexPath.row];
    cell.textLabel.text = [schoolDic objectForKey:@"schoolname"];
    
    UIImageView *accessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 19, 16)];
    accessoryView.image = [UIImage imageNamed:@"icon_check_sel"];
    
    if (currentSection == indexPath.section) {
        if (currentIndex == indexPath.row) {
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
    if (tableView == _provinceTableView || tableView == _cityTableView) {
        return 30 ;
    }
    return 30 ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _provinceTableView) {
        [_cityArr removeAllObjects];
        NSDictionary *proDic = _provinceArray[indexPath.row];
        NSArray *citys = [proDic objectForKey:@"city"];
        for (NSDictionary *city in citys) {
            [_cityArr addObject:city];
        }
        isSelectCity = NO;
        [self selectCity:nil];
        [_cityTableView reloadData];
        
    }
    else  if (tableView == _cityTableView) {
        NSDictionary *cityDic = _cityArr[indexPath.row];
        
        isShowIndex = YES;
        //获取学校信息
        [self getSchoolDataWithCityDic:cityDic];
        [self selectCity:nil];
        [self selectProvince:nil];
        _cityBtn.userInteractionEnabled = NO;
        
    }
    else{
        /**
         *  选中打钩
         */
    
        currentIndex = indexPath.row;
        currentSection = indexPath.section;
        NSLog(@"currentIndex = %ld",(long)currentIndex);
        NSLog(@"currentSection = %ld",(long)currentSection);
        [_schoolTableView reloadData];
        //获取section上的串
        NSString *indexStr = [_indexArr objectAtIndex:indexPath.section];
        NSArray *schoolArr = [_dataDic objectForKey:indexStr];
        NSDictionary *schoolDic = schoolArr[indexPath.row];
        if (_isfromCreateClass) {
            
            CreateClassViewController *createClass = [[CreateClassViewController  alloc]init];
            createClass.schoolDic = schoolDic;
            [self.navigationController pushViewController:createClass animated:YES];
            
            
        }
        else{
            if (_isFromClassEdit) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"changeSchoolName" object:schoolDic];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            SelectClassViewController *selectClass = [[SelectClassViewController alloc]init];
            selectClass.schoolDic = schoolDic;
            if (_isFromClassList) {
                
                selectClass.isFromClassList = YES;
            }
            [self.navigationController pushViewController:selectClass animated:YES];
        }
        
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


#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    UIView *alertView = (UIView *)[_mainScrollView viewWithTag:1000];
    [_mainScrollView endEditing:NO];
    alertView.frame = CGRectMake(alertView.frame.origin.x,  alertView.frame.origin.y + 100, alertView.frame.size.width, alertView.frame.size.height);
    
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    UIView *alertView = (UIView *)[_mainScrollView viewWithTag:1000];
    alertView.frame = CGRectMake(alertView.frame.origin.x,  alertView.frame.origin.y - 100, alertView.frame.size.width, alertView.frame.size.height);
    
    return YES;
}

@end
