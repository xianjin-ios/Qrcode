//
//  BaseViewController.m
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "BaseViewController.h"
#import "MainViewController.h"

@interface BaseViewController ()<UIGestureRecognizerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{

    BOOL isFirstShowPickView;
    
}
@property (strong, nonatomic)  UIPickerView *pickDateView;

@property (nonatomic,strong) NSMutableArray *yearArray;

@property (nonatomic,strong) NSMutableArray *monthArray;



@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    UIImage *toolBarIMG;
    if ([[[UIDevice currentDevice]systemVersion] doubleValue]>=7.0) {
        toolBarIMG = [UIImage imageNamed: @"app_nav64.png"];
    }else{
        toolBarIMG = [UIImage imageNamed: @"app_nav.png"];
    }
    
    UIImage * backgroundImage = toolBarIMG;
    
    //加载导航条图片
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    //隐藏back按钮的方法，除了第一种，其他两种在返回的时候都可以完美隐藏back按钮
    //    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationItem setHidesBackButton:YES];
    //    [self.navigationController.navigationBar.backItem setHidesBackButton:YES];
    
    UIButton *bb = [UIButton buttonWithType:UIButtonTypeCustom];
    bb.frame = CGRectMake(-20, 0, 30, 44);
    //        bb.backgroundColor = [UIColor greenColor];
    [bb addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchDown];
    [bb setTitle:@"" forState:UIControlStateNormal];
    [bb setTitle:@"" forState:UIControlStateHighlighted];
    UIImageView *bbImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 14, 10, 16)];
    bbImage.image = [UIImage imageNamed:@"backBtn.png"];
    [bb setContentEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
    bb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bb addSubview:bbImage];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:bb];
    backItem.tag = 2222;
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self hideBackButton:_hideBackButton];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithHexString:@"#0032a5"], UITextAttributeTextColor,nil]];
    
    
    //点击收起键盘
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:tap];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeMainViewCanTap:) name:@"changeMainViewCanTap" object:nil];
    
    //    初始化数据源
    self.yearArray = [NSMutableArray array];
    self.monthArray = [NSMutableArray array];
    
}

- (void)dismissKeyboard{
    [self.view endEditing:YES];
    
}

- (void)cancelTapHideKeyBoard:(BOOL)cancel{
    if (cancel) {
        [[self view] removeGestureRecognizer:tap];
    }
}
- (void)setEnabledSideView:(BOOL)iscan{
    if (iscan) {
        [MyAppDelegate.deckController setEnabled:YES];
        MyAppDelegate.deckController.panningMode = IIViewDeckFullViewPanning;
    }else{
        [MyAppDelegate.deckController setEnabled:NO];
        MyAppDelegate.deckController.panningMode = IIViewDeckNoPanning;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //**************方法一****************//
    //设置滑动回退
    __weak typeof(self) weakSelf = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
    //判断是否为第一个view
    if (self.navigationController && [self.navigationController.viewControllers count] == 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
}

#pragma mark- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.navigationController && [self.navigationController.viewControllers count] == 1) {
        return NO;
    }
    return YES;
}

-(void)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideBackButton:(BOOL)hidden{
    
    UIBarButtonItem *backItem = self.navigationItem.leftBarButtonItem;
    if (backItem ==nil) {
        UIButton *bb = [UIButton buttonWithType:UIButtonTypeCustom];
        bb.frame = CGRectMake(-20, 0, 59, 44);
        [bb addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchDown];
        [bb setTitle:@"" forState:UIControlStateNormal];
        [bb setTitle:@"" forState:UIControlStateHighlighted];
        UIImageView *bbImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 14, 10, 16)];
        bbImage.image = [UIImage imageNamed:@"backBtn.png"];
        [bb setContentEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
        bb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [bb addSubview:bbImage];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:bb];
        backItem.tag = 2222;
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    backItem.customView.hidden = hidden;
    
    return;
}

#pragma mark - isValue
//判断密码是否是数字加字母
- (BOOL)isValidPassword : (NSString *)pass{
    NSString * regex = @"^[A-Za-z]+[0-9]+[A-Za-z0-9]*|[0-9]+[A-Za-z]+[A-Za-z0-9]*$";//@"^[A-Za-z0-9]{6}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isUseful = [pred evaluateWithObject:pass];
    return isUseful;
}

//验证手机号是否11位数字
- (BOOL)isValidPhone : (NSString *)phone{
    NSString * regex = @"^[0-9]{11}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isUseful = [pred evaluateWithObject:phone];
    return isUseful;
}

//验证code是否6位数字
- (BOOL)isValidCode : (NSString *)code{
    NSString * regex = @"^[0-9]{6}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isUseful = [pred evaluateWithObject:code];
    return isUseful;
}

#pragma mark - HUD
- (void)showHUD{
    if(HUD == nil){
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText = @"正在加载...";
        [HUD show:YES];
    }
}
- (void)hideHUD{
    if(HUD != nil){
        [HUD removeFromSuperview];
        HUD = nil;
    }
}

- (void)showAlert:(NSString *)message withTitle:(NSString *)title haveCancelButton:(BOOL)cancel{
    
    UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancel?@"取消":nil otherButtonTitles:@"确定", nil];
    alertV.delegate = self;
    [alertV show];
    
}

- (UIView *)getNoReadViewWithSuperFrame:(CGRect)rect{
    UIView *noreadview = [self.view viewWithTag:321];
    if (noreadview) {
        [noreadview removeFromSuperview];
        noreadview = nil;
    }
    
    noreadview = [[UIView alloc]initWithFrame:CGRectMake(rect.size.width - 5, -1, 6, 6)];
    [noreadview setBackgroundColor:[UIColor colorWithHexString:@"#ff0702"]];
    noreadview.layer.masksToBounds = YES;
    noreadview.layer.cornerRadius = 3;
    noreadview.tag = 321;
    return noreadview;
    
}

#pragma mark - 侧栏
- (void)showSideView{
    [MyAppDelegate.deckController openLeftViewAnimated:YES];
    
}

- (void)hideSideView{
    [MyAppDelegate.deckController closeLeftViewAnimated:YES];
    
}

#pragma mark - 通知修改首页可否点击
- (void)changeMainViewCanTap:(NSNotification *)noti{
    if ([noti.object isEqualToString:@"YES"]) {
        MyAppDelegate.mainViewController.view.userInteractionEnabled = YES;
        
    }else if ([noti.object isEqualToString:@"NO"]){
        MyAppDelegate.mainViewController.view.userInteractionEnabled = NO;
        
    }
    
}

-(NSString*)stringToStamp:(NSString*)strTime format:(NSString*)format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: format];
    NSDate *destDateEnd= [dateFormatter dateFromString:strTime];
    NSString *strResult = [NSString stringWithFormat:@"%ld", (long)[destDateEnd timeIntervalSince1970]];
    
    return strResult;
    
}

//时间戳转换为时间
-(NSDate*)stampToDate:(NSString*)strStamp{
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[strStamp floatValue]];
    
    return confromTimesp;
}

//时间戳转换为时间(返回字符串)
-(NSString *)stampToDate:(NSString*)strStamp format:(NSString *)format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat: format];
    NSDate *destDateEnd= [NSDate dateWithTimeIntervalSince1970:strStamp.integerValue];
    NSString *strResult = [dateFormatter stringFromDate:destDateEnd];
    
    return strResult;
    
}

- (void)setRefreshBlock : (RefreshBlock)block;{
    refreshBlock = block;
}

#pragma mark -- 时间选择 PickerView
- (void)showDatePickerView{
    [self.view endEditing:YES];
    
    UIView *backView = [[UIView alloc]initWithFrame:self.view.bounds];
    backView.backgroundColor = [UIColor lightGrayColor];
    backView.alpha = 0.3;
    backView.tag = 500;
//    backView.userInteractionEnabled = NO;
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -230)];
    [backView addSubview:btn];
    [self.view addSubview:backView];
    
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT -230, SCREEN_WIDTH, 40)];
    btnView.backgroundColor = [UIColor darkGrayColor];
    [backView addSubview:btnView];
    btnView.tag = 501;
    
    //取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 0, 40, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelPick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:cancelBtn];
    
    //确定按钮
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(SCREEN_WIDTH - 50, 0 , 40, 30);
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmPick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:confirmBtn];
    
    //pickerView
    _pickDateView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 200, SCREEN_WIDTH,   220)];
    _pickDateView.delegate = self;
    _pickDateView.dataSource = self;
    _pickDateView.backgroundColor = [UIColor whiteColor];
    [backView addSubview:_pickDateView];
    _pickDateView.tag = 502;
    isFirstShowPickView = YES;
    
    [self getDateDataSource];
    
}

- (void)hideDatePickerView{
    isFirstShowPickView = NO;
    UIView *backView = (UIView *)[self.view viewWithTag:500];
    if (backView) {
        [backView removeFromSuperview];
        backView = nil;
    }
   
    UIView *btnView = (UIView *)[self.view viewWithTag:501];
    if (btnView) {
        [btnView removeFromSuperview];
        btnView = nil;
    }
    [_pickDateView removeFromSuperview];
    _pickDateView = nil;
    [_yearArray removeAllObjects];
    [_monthArray removeAllObjects];
}
//取消按钮
- (void)cancelPick:(id)sender {
    
    [self hideDatePickerView];
}
//确定
- (void)confirmPick:(id)sender {
    
    NSString *yearString = [self.yearArray objectAtIndex:[self.pickDateView selectedRowInComponent:0]];
    NSString *monthString = [self.monthArray objectAtIndex:[self.pickDateView selectedRowInComponent:1]];
    NSString *dateStr = [NSString stringWithFormat:@"%@年%@月",yearString,monthString];
    NSMutableDictionary * dateDic = [[NSMutableDictionary alloc]init];
    [dateDic setObject:dateStr forKey:@"date"];//日期串：年、月
    [dateDic setObject:yearString forKey:@"year"];//年 的串
    [dateDic setObject:monthString forKey:@"month"];//月 的串
    NSLog(@"dateDic = %@", dateDic);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshDate" object:dateDic];
    [self hideDatePickerView];
    
}
- (void)getDateDataSource{
    for (int i = 1949; i <= 2999; i++) {
        [self.yearArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    for (int i = 1; i<13; i++) {
        
        [self.monthArray addObject:[NSString stringWithFormat:@"%.2d",i]];
    }
    
    [self.pickDateView reloadAllComponents];
    
    
}
#pragma mark --  UIPickerViewDataSource

/**
 *  返回有几个PickerView
 */

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0)
        
        return self.yearArray.count;
    
    else
        
        return self.monthArray.count;
    
    
}
#pragma mark --  UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    if (component == 0) {
        
        return [self.yearArray objectAtIndex:row];
        
    }
    else if (component == 1){
        if ([[self pickerView:_pickDateView titleForRow:row forComponent:0] isEqualToString:@"1949年"]) {
             return [self.monthArray objectAtIndex:9];
        }
        return [self.monthArray objectAtIndex:row];
    }
    
    else
        return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0 ) {
        return [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",[self.yearArray objectAtIndex:row], @"年"]];
    }
    else{
        

        if ([[self pickerView:pickerView attributedTitleForRow:[pickerView selectedRowInComponent:0] forComponent:0] isEqualToAttributedString:[[NSAttributedString alloc]initWithString:@"1949年"]]) {
             if ([self pickerView:pickerView titleForRow:row forComponent:1].intValue < 10 && isFirstShowPickView) {
                 
                 isFirstShowPickView = NO;
                 [pickerView selectRow:9 inComponent:1 animated:YES];


            }
        }
        return [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",[self.monthArray objectAtIndex:row],@"月"]];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"1111999  %@",[self pickerView:pickerView attributedTitleForRow:[pickerView selectedRowInComponent:0] forComponent:0] );
    if ([[self pickerView:pickerView attributedTitleForRow:[pickerView selectedRowInComponent:0] forComponent:0] isEqualToAttributedString:[[NSAttributedString alloc]initWithString:@"1949年"]]) {
        //10
        NSLog(@"%@",[self pickerView:pickerView titleForRow:row forComponent:1]);
        if ([self pickerView:pickerView titleForRow:row forComponent:1].intValue < 10) {
            [pickerView selectRow:9 inComponent:1 animated:YES];

        }
        
    }
    
    
}
@end
