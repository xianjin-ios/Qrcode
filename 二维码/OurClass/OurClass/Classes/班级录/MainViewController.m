//
//  MainViewController.m
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "MainViewController.h"
#import "PictureDetailVC.h"
#import "MyMessageViewController.h"
#import "ClassVC.h"
#import "PublishPictureVC.h"
#import "SelectSchoolViewController.h"
#import "JubaoViewController.h"
#import "VMessageViewController.h"

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MJRefreshBaseViewDelegate,ChangeDianzan_delegate,UIGestureRecognizerDelegate>{
    IBOutlet UITableView *iTableView;
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    
    UIView *maskView;
    NSMutableArray *dataArray;
    
    //是否有新消息，条目高度49
    BOOL isNewMessage;
    
    //新消息条数
    NSString *noticeNum;
    
    UIView *_noView;//无数据时的显示
    NSInteger selectRow;
    
    NSDictionary *jubaoDic;
    
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLeft.frame = CGRectMake(0.0, 0.0, 18, 14);
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"icon_home_left.png"] forState:UIControlStateNormal];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"icon_home_left.png"] forState:UIControlStateHighlighted];
    [btnLeft addTarget:self action:@selector(doTapLeft:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    barItemLeft.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = barItemLeft;
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.frame = CGRectMake(0.0, 0.0, 18, 18);
    [btnRight setBackgroundImage:[UIImage imageNamed:@"icon_home_right.png"] forState:UIControlStateNormal];
    [btnRight setBackgroundImage:[UIImage imageNamed:@"icon_home_right.png"] forState:UIControlStateHighlighted];
    [btnRight addTarget:self action:@selector(addPicture) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItemRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    barItemRight.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = barItemRight;
    
    
    _header = [MJRefreshHeaderView header];
    _header.scrollView = iTableView;
    _header.delegate = self;
    
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = iTableView;
    _footer.delegate = self;
    
    _NeedRefresh = YES;
    
    //删除tap事件，否则cell无法点击
    [self.view removeGestureRecognizer:tap];
    
    
    [iTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_VIEW_HEIGHT-AltitudeHeight)];
    [iTableView reloadData];
    

    
}

-(void)refreshData{
    if(MyAppDelegate.logintoken){
        if(_NeedRefresh){
            [_header beginRefreshing];
            
            if(![MyAppDelegate.classInfo isKindOfClass:[NSDictionary class]] || ![MyAppDelegate.classInfo objectForKey:@"id"]){
                //没有班级时，不显示添加按钮
                self.navigationItem.rightBarButtonItem.customView.hidden = YES;
                [self hideNoClassView:NO];
            }else{
                self.navigationItem.rightBarButtonItem.customView.hidden = NO;
                [self hideNoClassView:YES];
            }
            
            _NeedRefresh = NO;
        }
    }
}

#pragma mark - 刷新的代理方法---进入下拉刷新\上拉加载更多都有可能调用这个方法
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    [self showHUD];
    if(refreshView == _header) {// 下拉刷新
        //中间标题响应事件
        [self setMideleAction];
        [self getNewsNumber];
        dataArray = nil;
        [self getClassPictureList : 0];
        [self performSelector:@selector(endHeaderFooterLoading) withObject:nil afterDelay:1];
    }else if (refreshView == _footer){//上拉加载更多
        if(dataArray.count > 0){
            NSDictionary *dic = dataArray[dataArray.count - 1];
            NSString *itemId = [dic objectForKey:@"id"];
            [self getClassPictureList:itemId.intValue];
        }
        
        [self performSelector:@selector(endHeaderFooterLoading) withObject:nil afterDelay:1];
        
    }
}

- (void)endHeaderFooterLoading{
    [self hideHUD];
    [_header endRefreshing];
    [_footer endRefreshing];
}

#pragma mark - 获取班级相册列表
- (void)getClassPictureList : (int) lastId{
    [self showHUD];
    
    if(![MyAppDelegate.classInfo isKindOfClass:[NSDictionary class]] || ![MyAppDelegate.classInfo objectForKey:@"id"]){
        //没有默认班级不用获取班级图片
        [self performSelector:@selector(showNoClassView) withObject:nil afterDelay:0.1];
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    if(0 != lastId){
        [contentDic setObject:[NSNumber numberWithInt:lastId] forKey:@"lastid"];
    }
    [contentDic setObject:[MyAppDelegate.classInfo objectForKey:@"id"]?[MyAppDelegate.classInfo objectForKey:@"id"]:@"" forKey:@"cid"];
    [MYRequest requstWithDic:contentDic withUrl:API_Class_Album withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO  andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        
        
        if(!dataArray){
            dataArray = [NSMutableArray array];
        }
        
        //获取数据成功
        NSArray *albums = [resultDic objectForKey:@"album"];
    
        [dataArray addObjectsFromArray:albums];
        //无数据时的提示
        if (dataArray.count == 0) {
//            int width = iTableView.frame.size.width;
//            int height = iTableView.frame.size.height;
            //无数据提示
            if (!_noView) {
                _noView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *05 - 50, SCREEN_HEIGHT* 0.5 - 50, 100, 100)];
                _noView.backgroundColor = [UIColor clearColor];
                _noView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
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
                [iTableView addSubview:_noView];
            }
        }
        else{
            
            if (_noView) {
                [_noView removeFromSuperview];
                _noView = nil;
            }
            if (albums.count == 0) {
                [self showAlert:@"没有更多数据" withTitle:@"提示" haveCancelButton:NO];
            }
        }

        [iTableView reloadData];
        
    }];
}

#pragma mark - 获取消息条数
- (void)getNewsNumber{
    [self showHUD];
    if(![MyAppDelegate.userInfo isKindOfClass:[NSDictionary class]]){
        return;
    }
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    
    [MYRequest requstWithDic:contentDic withUrl:API_News_Notice withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO  andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
        [self hideHUD];
        
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
        
        noticeNum = [resultDic objectForKey:@"new_notice_count"];
        if (noticeNum.integerValue > 0) {
            isNewMessage = YES;
        }else
            isNewMessage = NO;
        
        [iTableView reloadData];
    }];
}

//
- (void)setMideleAction{
    UIButton *middle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    NSString *className = @"";
    if([MyAppDelegate.classInfo isKindOfClass:[NSDictionary class]]){
        className = MyAppDelegate.classInfo[@"classname"];
    }
    [middle setTitle:className forState:UIControlStateNormal];
    [middle setTitleColor:[UIColor colorWithHexString:@"#002ca8"] forState:UIControlStateNormal];
    [middle addTarget:self action:@selector(toOurClass:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = middle;
    
}

//点击收放侧栏
- (void)doTapLeft:(UIButton *)sender{
    if (MyAppDelegate.deckController.isAnySideOpen) {
        [self hideSideView];
        
    }else{
        [self showSideView];
        
    }
}

- (IBAction)toOurClass:(id)sender{
    if(MyAppDelegate.deckController.isAnySideOpen){
        return;
    }
        
    if([MyAppDelegate.classInfo isKindOfClass:[NSDictionary class]]){
        if([MyAppDelegate.classInfo objectForKey:@"id"]){
            ClassVC *vc = [[ClassVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

//你还没有加入班  立刻加入>
- (void)showNoClassView{
    if(!maskView){
        maskView = [[UIView alloc]initWithFrame:self.view.bounds];
        maskView.backgroundColor = [UIColor colorWithHexString:@"#F0EFF5"];
        UILabel *lbNotice = [[UILabel alloc]initWithFrame:CGRectMake(0, 130, SCREEN_WIDTH, 18)];
        lbNotice.text = @"你还没有加入班";
        lbNotice.textAlignment = NSTextAlignmentCenter;
        lbNotice.textColor = [UIColor lightGrayColor];
        [maskView addSubview:lbNotice];
        
        UILabel *lbEnter = [[UILabel alloc]initWithFrame:CGRectMake(0, lbNotice.frame.origin.y + 45, SCREEN_WIDTH, 18)];
        lbEnter.text = @"立刻加入>";
        lbEnter.textAlignment = NSTextAlignmentCenter;
        lbEnter.textColor = [UIColor colorWithHexString:@"#0032a5"];
        [maskView addSubview:lbEnter];
        
        UIButton *selectBtn = [[UIButton alloc]initWithFrame:lbEnter.frame];
        [maskView addSubview:selectBtn];
        [selectBtn addTarget:self action:@selector(toSelectSchool) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_home_empty.png"]];
        imgView.frame = CGRectMake(0, 0, 48, 45);
        imgView.center = CGPointMake(SCREEN_WIDTH/2, 40 + lbEnter.frame.origin.y + imgView.frame.size.height/2);
        [maskView addSubview:imgView];
        
        [self.view addSubview:maskView];
    }
    
    maskView.hidden = NO;
}

#pragma mark - 去选择学校
- (void)toSelectSchool{
    SelectSchoolViewController *vc = [[SelectSchoolViewController alloc]init];
    vc.isfromCreateClass = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

//隐藏班级
- (void)hideNoClassView:(BOOL)hidden{
    maskView.hidden = hidden;
}

//添加照片
- (void)addPicture{
    if(![MyAppDelegate.classInfo isKindOfClass:[NSDictionary class]]){
        //没有默认班级，不能增加图片
        [self showAlert:@"您还没有加入班级，快去加入班级吧" withTitle:@"提示" haveCancelButton:NO];
        return;
    }
    
    UIActionSheet *uploadActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"拍照",@"从手机相册选择",nil];
    
    uploadActionSheet.tag = 2003;
    [uploadActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setEnabledSideView:YES];
    
    [self refreshData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self setEnabledSideView:NO];
    
}



#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if( buttonIndex > 1 ){
        return;
    }
    //拍照
    if( buttonIndex == 0 ){
        [self takePhotPic];
    }
    //相册
    else if( buttonIndex == 1 ){
        [self selectPhoto];
    }
}

//拍照
-(void)takePhotPic{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imgPicker setDelegate:self];
    
    [self presentViewController:imgPicker animated:YES completion:^{
    }];
    
}

//相册选择
- (void)selectPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{}];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"连接到图片库错误"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"好"
                              otherButtonTitles:nil];
        [alert show];
    }
}

//拍照后，或者选择照片后，照片处理
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info{
    
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    selectImage = [selectImage fixOrientation];//修正iOS图片旋转90度问题
    
    {
//        //shoplicensepic
//        _shopLicensePic.image = selectImage;
//        _shopLicensePic.clipsToBounds = YES;
//        [_shopLicensePic setNeedsLayout];
//        isChangeLicensePic = YES;
//        isHaveLicensePic = YES;
    }
    
    [self showHUD];

    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSString *imageURL = [HDImageObject saveImage:selectImage];
        
        [self hideHUD];

        PublishPictureVC *vc = [[PublishPictureVC alloc]init];
        vc.selectImage = imageURL;
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    
}

//跳到新消息页面
- (void)toMessage{
    //跳转到消息界面，新消息没有了
    isNewMessage = NO;
    [iTableView reloadData];
    MyMessageViewController *vc = [[MyMessageViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)getPushInfo:(NSDictionary *)dic{
    ZLog(@"getPushInfo:%@",dic);
    NSString *type = dic[@"type"];
    if ([type isEqualToString:@"1"]) {
        //消息
        MyMessageViewController *vc = [[MyMessageViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([type isEqualToString:@"2"]){
        //v信息
        VMessageViewController *ctrl = [[VMessageViewController alloc]init];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

#pragma mark - 列表
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(0 == indexPath.row && isNewMessage){
        static NSString *topIdentifier = @"topCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topIdentifier];
            cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSString *lbStr = [NSString stringWithFormat:@"%ld条新消息",(long)noticeNum.integerValue];
            CGSize lbsize = [lbStr sizeWithFont:[UIFont systemFontOfSize:DefaultContentFont] constrainedToSize:CGSizeMake(SCREEN_WIDTH, 19*MyAppDelegate.autoSizeScaleY) lineBreakMode:NSLineBreakByCharWrapping];

            UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (lbsize.width + 18 + 12)*MyAppDelegate.autoSizeScaleY, 22*MyAppDelegate.autoSizeScaleY)];
            bgView.layer.borderWidth = 1.0;
            bgView.layer.borderColor = [UIColor colorWithHexString:@"#0032a5"].CGColor;
            bgView.center = cell.center;
            [cell.contentView addSubview:bgView];
            
            //🔔 & 箭头
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(2, (22*MyAppDelegate.autoSizeScaleY - 18)/2, 18, 18)];
            imgView.image = [UIImage imageNamed:@"message_btn"];
            [bgView addSubview:imgView];
            UIImageView *imgViewend = [[UIImageView alloc]initWithFrame:CGRectMake((lbsize.width + 18 + 12)*MyAppDelegate.autoSizeScaleY-8, (22*MyAppDelegate.autoSizeScaleY - 7)/2, 4, 7)];
            imgViewend.image = [UIImage imageNamed:@"icon_main_navi.png"];
            [bgView addSubview:imgViewend];
            
            //消息条目
            UILabel *lbNumInfo = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, (lbsize.width + 18 + 7)*MyAppDelegate.autoSizeScaleY - 20 - 3, 22*MyAppDelegate.autoSizeScaleY)];
            lbNumInfo.backgroundColor = [UIColor clearColor];
            lbNumInfo.textAlignment = NSTextAlignmentCenter;
            lbNumInfo.textColor = [UIColor colorWithHexString:@"#0032a5"];
            lbNumInfo.text = @"";
            lbNumInfo.font = [UIFont systemFontOfSize:DefaultContentFont];
            lbNumInfo.tag = 1101;
            [bgView addSubview:lbNumInfo];
            
            UIButton *btn  = [[UIButton alloc]initWithFrame:bgView.bounds];
            [bgView addSubview:btn];
            [btn addTarget:self action:@selector(toMessage) forControlEvents:UIControlEventTouchUpInside];

        }
        
        UILabel *lbNumInfo = (UILabel *)[cell.contentView viewWithTag:1101];
        NSString *lbStr = [NSString stringWithFormat:@"%ld条新消息",(long)noticeNum.integerValue];
        lbNumInfo.text = lbStr;

        
        return cell;
        
    }
    static NSString *commonIdentifier = @"commonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commonIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //头像
        UIImageView *vImgHead = [[UIImageView alloc]initWithFrame:CGRectMake(8, 5, 28*MyAppDelegate.autoSizeScaleY, 28*MyAppDelegate.autoSizeScaleY)];
        vImgHead.tag = 1001;
        [vImgHead setImage:[UIImage imageNamed:@"default_head"]];
        vImgHead.layer.cornerRadius = vImgHead.frame.size.width/2;
        vImgHead.layer.masksToBounds = YES;
        [cell.contentView addSubview:vImgHead];
        
        //名称
        UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(vImgHead.frame.origin.x + vImgHead.frame.size.width + 2, 5, 200, vImgHead.frame.size.height)];
        lbName.font = [UIFont systemFontOfSize:DefaultTitleFont];
        lbName.tag = 1002;
        [cell.contentView addSubview:lbName];
        
        //图片
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, vImgHead.frame.size.height + vImgHead.frame.origin.y + 8, SCREEN_WIDTH - 88, (SCREEN_WIDTH - 88)*3/4)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
        [imgView setImage:[UIImage imageNamed:@"default_home"]];
        imgView.tag = 1003;
        [cell.contentView addSubview:imgView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doLongPress:)];
        [cell addGestureRecognizer:longPress];
        
    }
    
    [cell setTag:1000+indexPath.row];
    
    //item 与实际差，
    int X = 0;
    if(isNewMessage) X = 1;
    NSDictionary *curDic = [dataArray objectAtIndex:(indexPath.row - X )];
    //
    UIImageView *vImgHead = (UIImageView*)[cell.contentView viewWithTag:1001];
    [vImgHead sd_setImageWithURL:[NSURL URLWithString:[curDic objectForKey:@"small_head_icon"]] placeholderImage:[UIImage imageNamed:@"default_head"]];
    
    UILabel *lbName = (UILabel*)[cell.contentView viewWithTag:1002];
    lbName.text = [NSString stringWithFormat:@"%@",[curDic objectForKey:@"realname"]];
    
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1003];
    //获取图片并调整高度
    float valueWidth = ((NSString*)curDic[@"old_image_width"]).floatValue;
    float valueHeight = ((NSString*)curDic[@"old_image_height"]).floatValue;
    CGSize size = [[[UIImage alloc]init] getShowRect:CGSizeMake(SCREEN_WIDTH/* - 16*/, (SCREEN_WIDTH - 88)*3/4) withImageSize:CGSizeMake(valueWidth, valueHeight)];
    [imgView setFrame:CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y, size.width, size.height)];
    
    //自己发布的图片，放在屏幕的右侧；别人发布的图片位于左侧
    NSString *dicUid = [curDic objectForKey:@"uid"];
    NSString *uid = [MyAppDelegate.userInfo objectForKey:@"id"];
    if([dicUid isEqualToString:uid]){
        //头像在右侧
        vImgHead.frame = CGRectMake(SCREEN_WIDTH - 8 - 28*MyAppDelegate.autoSizeScaleY, 5, 28*MyAppDelegate.autoSizeScaleY, 28*MyAppDelegate.autoSizeScaleY);
        lbName.frame = CGRectMake(SCREEN_WIDTH - 12 - 28*MyAppDelegate.autoSizeScaleY - lbName.frame.size.width , 5, lbName.frame.size.width, lbName.frame.size.height);
        lbName.textAlignment = NSTextAlignmentRight;
    }else{
        //头像在左侧
        vImgHead.frame = CGRectMake(8, 5, 28*MyAppDelegate.autoSizeScaleY, 28*MyAppDelegate.autoSizeScaleY);
        lbName.frame = CGRectMake(vImgHead.frame.origin.x + vImgHead.frame.size.width + 2, 5, lbName.frame.size.width, lbName.frame.size.height);
        lbName.textAlignment = NSTextAlignmentLeft;
    }
    
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:[curDic objectForKey:@"picture"]] placeholderImage:[UIImage imageNamed:@"default_home"]];
    
    return cell;
    
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(isNewMessage)
        return dataArray.count + 1;
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isNewMessage && 0 == indexPath.row){
        //有新消息提醒
        return 49;
    }else{
        //获取图片并调整高度
        //item 与实际差，
        int X = 0;
        if(isNewMessage) X = 1;
        NSDictionary *curDic = [dataArray objectAtIndex:(indexPath.row - X )];
        float valueWidth = ((NSString*)curDic[@"old_image_width"]).floatValue;
        float valueHeight = ((NSString*)curDic[@"old_image_height"]).floatValue;
        CGSize size = [[[UIImage alloc]init] getShowRect:CGSizeMake(SCREEN_WIDTH/* - 16*/, (SCREEN_WIDTH - 88)*3/4) withImageSize:CGSizeMake(valueWidth, valueHeight)];
        return size.height + 28*MyAppDelegate.autoSizeScaleY + 2 + 19;

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isNewMessage && 0 == indexPath.row){
        //用户点击消息提醒
        return;
    }
    
    int X = 0;
    if(isNewMessage) X = 1;
    NSDictionary *dic = [dataArray objectAtIndex:(indexPath.row - X )];
    
    selectRow = indexPath.row - X;
    PictureDetailVC *vc = [[PictureDetailVC alloc] initWithInfoDic:dic];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doLongPress:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = (UITableViewCell *)recognizer.view;
        [cell becomeFirstResponder];
        jubaoDic = [dataArray[cell.tag-1000] copy];
        ZLog(@"%ld",cell.tag-1000);
//        UIMenuItem *itCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(handleCopyCell:)];
        UIMenuItem *itDelete = [[UIMenuItem alloc] initWithTitle:@"投诉" action:@selector(handleDeleteCell:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:itDelete,  nil]];
        [menu setTargetRect:CGRectMake(cell.frame.size.width/3, cell.frame.size.height/3, 100, 100) inView:cell];
        [menu setMenuVisible:YES animated:YES];
        
    }
}

- (void)handleDeleteCell:(id)sender{//删除cell
    NSLog(@"handle delete cell");
    
    JubaoViewController *ctrl = [[JubaoViewController alloc]init];
    ctrl.jubaoDic = [jubaoDic copy];
    [self.navigationController pushViewController:ctrl animated:YES];

}

-(void)changeDianzan:(NSDictionary *)newDic{
    [dataArray replaceObjectAtIndex:selectRow withObject:newDic];
    
}
@end
