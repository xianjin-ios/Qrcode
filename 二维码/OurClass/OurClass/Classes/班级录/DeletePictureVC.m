//
//  DeletePictureVC.m
//  OurClass
//
//  Created by STAR on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "DeletePictureVC.h"
#import "SelectPeopleVC.h"


@interface DeletePictureVC ()<SELECTPEOPLE_DELEGATE>
{
    NSDictionary *userInfo;
    
    __weak IBOutlet UILabel *_lbAlert;
    __weak IBOutlet UILabel *_lbSelectMate;
    
    
    BOOL canDelete;
    
    //要@的人
    NSString *userids;
}
@end

@implementation DeletePictureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"照片删除";
    
    [_lbAlert setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    [_lbSelectMate setFont:[UIFont systemFontOfSize:DefaultContentFont]];
    
    [self addRightBtn];
}

- (DeletePictureVC*)initWithInfoDic : (NSDictionary*) infoDic{
    userInfo = [infoDic copy];
    return [self init];
}

//@好友
- (IBAction)selectpeople:(id)sender{
    SelectPeopleVC *vc = [[SelectPeopleVC alloc]init];
    vc.isPublish = NO;
    vc.delegate = self;
    vc.delId = [userInfo objectForKey:@"cid"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addRightBtn{
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.frame = CGRectMake(0.0, 0.0, 48, 22);
    UILabel *lbClose = [[UILabel alloc]initWithFrame:btnRight.bounds];
    lbClose.text = @"确定";
    lbClose.font = [UIFont systemFontOfSize:DefaultBtnFont];
    lbClose.textColor = [UIColor blueColor];
    lbClose.textAlignment = NSTextAlignmentCenter;
    [btnRight addSubview:lbClose];
    [btnRight addTarget:self action:@selector(doSendMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItemRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    barItemRight.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = barItemRight;
}

#pragma mark - selectPeopel_Delegate
-(void)selectPeopleArr:(NSMutableArray *)selectArr{
    
    ZLog(@"%@",selectArr);
    [self adjustNameLabel:selectArr];
}

-(void)adjustNameLabel:(NSArray *)selectArray{
    NSMutableString *selectMateStr = [[NSMutableString alloc]init];
    userids = @"";
    for (int i = 0; i < selectArray.count; i ++) {
        [selectMateStr appendFormat:@"@%@",selectArray[i][@"realname"]];
        userids = [userids stringByAppendingString:selectArray[i][@"id"]];
        if (i < selectArray.count - 1) {
            userids = [userids stringByAppendingString:@","];
        }
    }
    [_lbSelectMate setText:selectMateStr];
    
    if (selectArray.count < 5 || selectArray.count > 9) {
        canDelete = NO;
    }else{
        canDelete = YES;
    }
    
}

//发送删除照片的消息
- (void)doSendMessage{
    
    if (!canDelete) {
        [self showAlert:@"请选择5-9名同学" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    NSString *picId = [userInfo objectForKey:@"id"];
    [contentDic setObject:picId forKey:@"aid"];
    [contentDic setObject:[userInfo objectForKey:@"cid"] forKey:@"cid"];
    [contentDic setObject:userids forKey:@"to_uids"];

    [MYRequest requstWithDic:contentDic withUrl:API_Del_Album withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO  andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        
        if([[resultDic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:1]]){
            [self showAlert:@"照片删除申请已发送！" withTitle:@"提示" haveCancelButton:NO];
        }
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:@"照片删除申请已发送！"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
