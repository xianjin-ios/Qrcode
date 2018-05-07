

#import "DateViewController.h"
#import "OurClass_Prefix.pch"

@interface DateViewController ()
@end

@implementation DateViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0,0,61,52);
    [cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [cancelBtn setTitleColor:[UIColor colorWithRed:(64.0/255.0) green:(177.0/255.0)  blue:(217.0/255.0) alpha:1.0] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    UIButton *okBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(SCREEN_WIDTH - 61,0,61,52);
    [okBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [okBtn setTitleColor:[UIColor colorWithRed:(64.0/255.0) green:(177.0/255.0)  blue:(217.0/255.0) alpha:1.0] forState:UIControlStateNormal];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    self.navigationItem.title=@"选择日期";
    if (self.hideOK) {
        _picker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 216)];
        okBtn.hidden=YES;
        cancelBtn.hidden=YES;
    }
    else{
        _picker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 42, SCREEN_WIDTH, 216)];
        okBtn.hidden=NO;
        cancelBtn.hidden=NO;
    }
    
    _picker.backgroundColor = [UIColor whiteColor];
    
    if (self.timeFormat) {//YES：日期；NO：日期加时间
        _picker.datePickerMode=UIDatePickerModeDate;
    }
    else{
        _picker.datePickerMode=UIDatePickerModeDateAndTime;
    }
    //[_picker setDate:[NSDate date] animated:YES];
    [self.view addSubview:_picker];
    
//    [self performSelector:@selector(hideMiddleView) withObject:nil afterDelay:0.1];
}

- (void)hideMiddleView{
    //只显示年月，把日隐藏起来

//    UIView *viewP2 = _picker.subviews[0].subviews[0].subviews[3];
//    viewP2.hidden = YES;
    
}

-(NSString*)dateToString:(NSString *)formatter date:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    return[dateFormatter stringFromDate:date];
}

-(IBAction)okAction:(id)sender{
     if (self.timeFormat) {
         if ([self.delegate respondsToSelector:@selector(selectFinish:withDate:)]){
             [delegate selectFinish:self  withDate:[self dateToString:@"yyyy-MM-dd" date:_picker.date]];
         }
     }
     else{
         if ([self.delegate respondsToSelector:@selector(selectCancel:)]){
             [delegate selectFinish:self withDate:[self dateToString:@"yyyy-MM-dd HH:mm:ss" date:_picker.date]];
         }
     }
    
}
-(IBAction)cancelAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(selectCancel:)]) {
        [delegate selectCancel:self];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
