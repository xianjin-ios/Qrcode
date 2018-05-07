//
//  CreateClassViewController.m
//  OurClass
//
//  Created by siqiyang on 16/4/12.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "CreateClassViewController.h"
#import "MyClassViewController.h"
#import "SelectSchoolViewController.h"

@interface CreateClassViewController ()<UITextFieldDelegate>

//所属学校
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLabel;
//班级名称
@property (weak, nonatomic) IBOutlet UITextField *classNameField;

//起始时间
@property (retain, nonatomic)  UITextField *startTimeField;

//结束时间
@property (retain, nonatomic)  UITextField *endTimeField;

//pickIndex 是否选择时间 0--未选择 1-选择起始时间，2-选择结束时间
@property (nonatomic,assign) int pickIndex;

@property (weak, nonatomic) IBOutlet UIView *periodView;

@property (nonatomic,strong) NSMutableString *startTimeStr;
@property (nonatomic,strong) NSMutableString *endTimeStr;

@end

@implementation CreateClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建班级";
    [self initPeriodView];
    _pickIndex = 0;
    if (_schoolDic) {
        self.schoolNameLabel.text = [_schoolDic objectForKey:@"schoolname"];
    }
//    _classNameField.delegate = self;
    
    [self addConfirmBtn];
    
}
- (void)initPeriodView{
    //起始时间--年
    _startTimeField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 100, _periodView.frame.size.height - 20)];
//    _startTimeField.delegate = self;
    _startTimeField.font = [UIFont systemFontOfSize:DefaultTitleFont];
    _startTimeField.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
    _startTimeField.placeholder = @"起始年月 ";
    //    _startTimeField.keyboardType = UIKeyboardTypePhonePad;
    _startTimeField.textAlignment = NSTextAlignmentRight;
    [_periodView addSubview:_startTimeField];
    UIButton *startTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startTimeBtn.frame = _startTimeField.bounds;
    [startTimeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_startTimeField addSubview:startTimeBtn];
    startTimeBtn.tag = 11;
    
    
    UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(110, _periodView.frame.size.height * 0.5 - 0.5, 10, 1)];
    lineview.backgroundColor = [UIColor colorWithHexString:@"#b0b0b0"];
    [_periodView addSubview:lineview];
    
    //结束时间--年
    _endTimeField = [[UITextField alloc]initWithFrame:CGRectMake(120, 10, 100, _periodView.frame.size.height - 20)];
    _endTimeField.placeholder = @" 结束年月";
//    _endTimeField.delegate = self;
    _endTimeField.font = [UIFont systemFontOfSize:DefaultTitleFont];
    //    _endTimeField.keyboardType = UIKeyboardTypePhonePad;
    _endTimeField.textAlignment = NSTextAlignmentLeft;
    _endTimeField.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
    [_periodView addSubview:_endTimeField];
    [_endTimeField addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *endTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    endTimeBtn.tag = 12;
    endTimeBtn.frame = _startTimeField.bounds;
    [endTimeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_endTimeField addSubview:endTimeBtn];
    
}
//增加确定按钮
- (void)addConfirmBtn{
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(0, 0, 60, 44);
    [deleteBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [deleteBtn setTitle:@"确定" forState:UIControlStateNormal];
    [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:DefaultBtnFont]];
    [deleteBtn setTitleColor:[UIColor colorWithHexString:@"#0032a5"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:deleteBtn]];
    
    
}
- (void)confirm:(id)sender{
    
    //判断是否符合
    if (!_schoolDic) {
        [self showAlert:@"请选择学校" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    if ([_classNameField.text isEqualToString:@""]) {
        [self showAlert:@"请填写班级名称" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    if (_startTimeField.text.length == 0) {
        [self showAlert:@"请输入在校时间的初始年月" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    NSString *startStr = [self stringToStamp:_startTimeField.text format:@"yyyy年MM月"];
    NSString *endStr = [self stringToStamp:_endTimeField.text format:@"yyyy年MM月"];
    if (_endTimeField.text.length == 0 ) {
        [self showAlert:@"请输入在校时间的结束年月" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    if (startStr.intValue > endStr.intValue) {
        [self showAlert:@"开始时间必须早于结束时间，请重新填写时间" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
        [self showHUD];
    
    NSDictionary *dic = @{
                          @"sid":[_schoolDic objectForKey:@"id"],//学校id
                          @"classname":self.classNameField.text,//班级名称
                          @"starttime":startStr,//起始时间
                          @"endtime":endStr//终止时间
                          };
    [MYRequest requstWithDic:dic withUrl:API_Create_Class withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
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
        //创建成功
        [self showAlert:@"创建班级成功！" withTitle:@"提示" haveCancelButton:NO];
        MyClassViewController *class = [[MyClassViewController alloc]init];
        [self.navigationController pushViewController:class animated:YES];
        
    }];
    
}

- (void)buttonClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 11:
            _pickIndex = 1;
            break;
        case 12:
            _pickIndex = 2;
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(RefreshDate:) name:@"refreshDate" object:nil];
    [self showDatePickerView];
    
}
- (void)RefreshDate:(NSNotification *)notify{
    NSMutableDictionary * dateDic = notify.object;
    if (_pickIndex == 1) {
        self.startTimeField.text = [dateDic objectForKey:@"date"];
        _startTimeStr = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@-%@",dateDic[@"year"],dateDic[@"month"]]];
    }
    else if(_pickIndex == 2)
    {
        _endTimeField.text = [dateDic objectForKey:@"date"];
        _endTimeStr = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@-%@",dateDic[@"year"],dateDic[@"month"]]];
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshDate" object:nil];
    
}
@end
