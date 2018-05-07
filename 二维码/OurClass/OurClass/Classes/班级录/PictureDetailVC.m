//
//  PictureDetailVC.m
//  OurClass
//
//  Created by STAR on 16/4/12.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "PictureDetailVC.h"
#import "VIPhotoView.h"
#import "DeletePictureVC.h"
#import "JubaoViewController.h"

@interface PictureDetailVC (){
    NSMutableDictionary *userInfo;
    NSMutableArray *arrayPrise;

    IBOutlet UIScrollView *scrView;
    
    //点赞的图片
    UIImageView *imgLove;
    
    UILabel *lbWho;
    
    BOOL isLoveAction;
}

@end

@implementation PictureDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";

    isLoveAction = NO;
    
    [self setNavBtn];
    
    [self getPicDetailInfo];
    
}

- (void)setNavBtn{
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    rightBtn.frame = CGRectMake(0, 0, 18, 18);
    [rightBtn setImage:[UIImage imageNamed:@"icon_gohome"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(doRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
    
}

- (void)doRightBtn:(UIButton *)sender{
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (PictureDetailVC*)initWithInfoDic : (NSDictionary*) infoDic{
    userInfo = [infoDic mutableCopy];
    arrayPrise = [[userInfo objectForKey:@"praise"] mutableCopy];

    return [self init];
}

- (void)getPicDetailInfo{
    
    [self showHUD];
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    NSString *picId = [userInfo objectForKey:@"id"];
    [contentDic setObject:picId forKey:@"aid"];
    
    [MYRequest requstWithDic:contentDic withUrl:API_Album_Detail withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        
        userInfo = [[resultDic objectForKey:@"album"]mutableCopy];
        arrayPrise = [[userInfo objectForKey:@"praise"] mutableCopy];

        //点赞操作只调整点赞列表
        if (isLoveAction) {
            [self setParisView];
            
            //点赞操作后响应上层代理
            if ([self.delegate respondsToSelector:@selector(changeDianzan:)]) {
                [self.delegate changeDianzan:userInfo];
            }
            
        }else{
            [self setView];
        }
        
    }];
}

- (void)setView{
    scrView.backgroundColor = [UIColor colorWithHexString:@"#EFEFF4"];
    
    UIView *topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 72 + (SCREEN_WIDTH - 16)*3/4  + 10)];
    topBgView.backgroundColor = [UIColor whiteColor];
    
    //边线
    UIView *vLineTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ONE_PIXL)];
    vLineTop.backgroundColor = [UIColor colorWithHexString:@"dfdfdf"];
    [topBgView addSubview:vLineTop];
    UIView *vLineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, topBgView.frame.size.height - ONE_PIXL, SCREEN_WIDTH, ONE_PIXL)];
    vLineBottom.backgroundColor = [UIColor colorWithHexString:@"dfdfdf"];
    [topBgView addSubview:vLineBottom];
    
    //头像
    UIImageView *vImgHead = [[UIImageView alloc]initWithFrame:CGRectMake(8, 10, 30*MyAppDelegate.autoSizeScaleY, 30*MyAppDelegate.autoSizeScaleY)];
    vImgHead.layer.cornerRadius = vImgHead.frame.size.width/2;
    [vImgHead sd_setImageWithURL:[userInfo objectForKey:@"small_head_icon"]placeholderImage:[UIImage imageNamed:@"default_head"]];
    vImgHead.layer.masksToBounds = YES;
    [topBgView addSubview:vImgHead];
    
    //名称
    UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(46, 10, 200, DefaultBtnFont)];
    lbName.font = [UIFont systemFontOfSize:DefaultBtnFont];
    lbName.text = [userInfo objectForKey:@"realname"];
    [topBgView addSubview:lbName];
    
    //时间
    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(46, 10 + DefaultBtnFont + 5, 200, DefaultContentFont)];
    lbTime.font = [UIFont systemFontOfSize:DefaultContentFont];
    lbTime.text = [self stampToDate:[userInfo objectForKey:@"ctime"] format:@"yyyy-MM-dd HH:mm:ss"];
    lbTime.textColor = [UIColor colorWithHexString:@"#b0b0b0"];
    [topBgView addSubview:lbTime];
    
    //删除和喜欢
    //判断是否赞过
    BOOL bPrise = [[userInfo objectForKey:@"is_praise"] isEqualToString:@"1"]?YES:NO;
    imgLove = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 15*MyAppDelegate.autoSizeScaleFont - 10, (36 - 10*MyAppDelegate.autoSizeScaleFont)/2, 15*MyAppDelegate.autoSizeScaleFont, 14*MyAppDelegate.autoSizeScaleFont)];
    [topBgView addSubview:imgLove];
    UIButton *btnLove = [[UIButton alloc] initWithFrame:CGRectInset(imgLove.frame, -10, -10)];
    [btnLove addTarget:self action:@selector(loveAction:) forControlEvents:UIControlEventTouchUpInside];
    [topBgView addSubview:btnLove];
    if(bPrise){
        imgLove.image = [UIImage imageNamed:@"icon_heart_sel.png"];
        [btnLove setSelected:YES];
    }
    else{
        imgLove.image = [UIImage imageNamed:@"icon_heart.png"];
        [btnLove setSelected:NO];
    }
//判断是否是本人发布的照片，如果是就显示删除按钮，否则不显示
    if ([[userInfo objectForKey:@"uid"]isEqualToString:[MyAppDelegate.userInfo objectForKey:@"id"]]) {
        //删除
        UIImageView *imgDel = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - imgLove.frame.size.width - 10 - 15 - 10*MyAppDelegate.autoSizeScaleFont, (36 - 12*MyAppDelegate.autoSizeScaleFont)/2, 14*MyAppDelegate.autoSizeScaleFont, 17*MyAppDelegate.autoSizeScaleFont)];
        imgDel.tag = 1103;
        imgDel.image = [UIImage imageNamed:@"icon_del.png"];
        [topBgView addSubview:imgDel];
        UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectInset(imgDel.frame, -10, -10)];
        [btnDel addTarget:self action:@selector(delPicAction:) forControlEvents:UIControlEventTouchUpInside];
        [topBgView addSubview:btnDel];
        
    }
    
    //描述
    UILabel *lbIntro = [[UILabel alloc]init];
    NSString *lbStr = [userInfo objectForKey:@"content"];
    CGSize lbsize = [lbStr sizeWithFont:[UIFont systemFontOfSize:DefaultBtnFont] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 46 - 8, 400) lineBreakMode:NSLineBreakByCharWrapping];
    [lbIntro setFrame:CGRectMake(46, 50, SCREEN_WIDTH - 46 - 8, lbsize.height)];
    lbIntro.text = lbStr;
    lbIntro.numberOfLines = 0;
    lbIntro.lineBreakMode = NSLineBreakByCharWrapping;
    lbIntro.font = [UIFont systemFontOfSize:DefaultBtnFont];
    [topBgView addSubview:lbIntro];
    
    //中央大图 + 点击放大
    //获取图片尺寸
    float valueWidth = ((NSString*)userInfo[@"old_image_width"]).floatValue;
    float valueHeight = ((NSString*)userInfo[@"old_image_height"]).floatValue;
    CGSize size = [[[UIImage alloc]init] getShowRect:CGSizeMake(SCREEN_WIDTH /*- 16*/, (SCREEN_WIDTH - 88)*3/4) withImageSize:CGSizeMake(valueWidth, valueHeight)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, lbIntro.frame.size.height + 50 + 10, size.width, size.height)];
    imgView.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
    [imgView sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"picture"]] placeholderImage:[UIImage imageNamed:@"default_home"]];
    imgView.userInteractionEnabled = YES;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [topBgView addSubview:imgView];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, imgView.frame.size.width, imgView.frame.size.height)];
    [btn addTarget:self action:@selector(showBigView) forControlEvents:UIControlEventTouchUpInside];
    [imgView addSubview:btn];
    
    //重新调整视图
    [topBgView setFrame:CGRectMake(topBgView.frame.origin.x, topBgView.frame.origin.y, topBgView.frame.size.width, 50 + lbIntro.frame.size.height + imgView.frame.size.height  + 20)];
    
    [scrView addSubview:topBgView];
    
    //赞列表View
    UIView *secBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20 + topBgView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - (topBgView.frame.size.height + topBgView.frame.origin.y + 20)>100?SCREEN_HEIGHT - (topBgView.frame.size.height + topBgView.frame.origin.y + 20):100)];
    
    secBgView.backgroundColor = [UIColor whiteColor];
    UIView *vLineSec = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ONE_PIXL)];
    vLineSec.backgroundColor = [UIColor colorWithHexString:@"dfdfdf"];
    [secBgView addSubview:vLineSec];
    
    UIImageView *imgHeart = [[UIImageView alloc]initWithFrame:CGRectMake(8, 9, 14, 12)];
    imgHeart.image = [UIImage imageNamed:@"icon_heart_zan.png"];
    [secBgView addSubview:imgHeart];

    lbWho = [[UILabel alloc]initWithFrame:CGRectMake(26, 8, SCREEN_WIDTH - 28, 100)];
    lbWho.font = [UIFont systemFontOfSize:DefaultContentFont];
    lbWho.numberOfLines = 0;
    ZLog(@"赞过的人");
    [self setParisView];
    [secBgView addSubview:lbWho];

    scrView.contentSize = CGSizeMake(SCREEN_WIDTH, secBgView.frame.origin.y + secBgView.frame.size.height);
    [scrView addSubview:secBgView];
}

- (void)setParisView{
    
    [lbWho setFrame:CGRectMake(26, 8, SCREEN_WIDTH - 28, 100)];
    
    NSString *loveStr = @"";
    if (arrayPrise.count > 0) {
        for(int i = 0 ; i < arrayPrise.count; i++){
            NSString *temp = [arrayPrise[i] objectForKey:@"realname"];
            loveStr = [loveStr stringByAppendingString:temp];
            if (i < arrayPrise.count - 1) {
                loveStr = [loveStr stringByAppendingString:@","];
            }
        }
        
        lbWho.text = loveStr;
    }else{
        lbWho.text = @"";

    }
    
    [lbWho sizeToFit];
    
}

#pragma mark - 删除 && 喜欢
- (IBAction)delPicAction:(id)sender{
    DeletePictureVC *vc = [[DeletePictureVC alloc]initWithInfoDic:userInfo];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)loveAction:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    btn.userInteractionEnabled = NO;
    
    isLoveAction = YES;
    
    if(!btn.isSelected){
        [self showHUD];

        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
        NSString *picId = [userInfo objectForKey:@"id"];
        [contentDic setObject:picId forKey:@"aid"];
        [MYRequest requstWithDic:contentDic withUrl:API_Praise withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
            [self hideHUD];
            
            //若存在error，则网络有问题
            if (error) {
                ZLog(@"%@",error);
                [self showAlert:@"网络尚未接入互联网，请检查你的网络连接！" withTitle:@"网络错误" haveCancelButton:NO];
                    btn.userInteractionEnabled = YES;
                return ;
            }
            
            //解析数据
            NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            //如果存在erro则接口调用失败
            if ([resultDic objectForKey:@"error"]) {
                [self showAlert:[resultDic objectForKey:@"error"] withTitle:@"温馨提示" haveCancelButton:NO];
                    btn.userInteractionEnabled = YES;
                return;
            }
            
            if([[resultDic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:1]] ){
                [self showAlert:[resultDic objectForKey:@"message"] withTitle:@"提示" haveCancelButton:NO];
                imgLove.image = [UIImage imageNamed:@"icon_heart_sel.png"];
                [btn setSelected:YES];
                
                //刷新页面
                [self getPicDetailInfo];
                
            }
     
             btn.userInteractionEnabled = YES;
        }];
    }else{
        [self showHUD];

        //去掉赞
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
        NSString *picId = [userInfo objectForKey:@"id"];
        [contentDic setObject:picId forKey:@"aid"];
        [MYRequest requstWithDic:contentDic withUrl:API_Del_Praise withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
            [self hideHUD];
            
            //若存在error，则网络有问题
            if (error) {
                ZLog(@"%@",error);
                [self showAlert:@"网络尚未接入互联网，请检查你的网络连接！" withTitle:@"网络错误" haveCancelButton:NO];
                    btn.userInteractionEnabled = YES;
                return ;
            }
            
            //解析数据
            NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            //如果存在erro则接口调用失败
            if ([resultDic objectForKey:@"error"]) {
                [self showAlert:[resultDic objectForKey:@"error"] withTitle:@"温馨提示" haveCancelButton:NO];
                    btn.userInteractionEnabled = YES;
                return;
            }
            
            if([[resultDic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:1]] ){
                [self showAlert:[resultDic objectForKey:@"message"] withTitle:@"提示" haveCancelButton:NO];
                imgLove.image = [UIImage imageNamed:@"icon_heart.png"];
                [btn setSelected:NO];
                
                //刷新页面
                [self getPicDetailInfo];

            }
                btn.userInteractionEnabled = YES;
        }];

    }
    
    
}

- (void)showBigView{
    //把本来背景挡住
    UIView *bgBigPic = [[UIView alloc] initWithFrame:self.view.bounds];
    bgBigPic.backgroundColor = [UIColor blackColor];
    bgBigPic.tag = 1102;
    [MyAppDelegate.window addSubview:bgBigPic];
    
    float valueWidth = ((NSString*)userInfo[@"old_image_width"]).floatValue;
    float valueHeight = ((NSString*)userInfo[@"old_image_height"]).floatValue;
    NSString *imageUrl = [userInfo objectForKey:@"picture"];
    ZLog(@"imageUrl : %@",imageUrl);
    UIImageView *showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, valueWidth, valueHeight)];
    [showImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"default_home"]];
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:self.view.bounds andImage:showImageView.image];
    photoView.autoresizingMask = (1 << 6) -1;
    photoView.tag = 1101;
    [MyAppDelegate.window addSubview:photoView];
    
}

@end
