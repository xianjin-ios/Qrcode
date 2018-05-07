//
//  VMessageViewController.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "VMessageViewController.h"
#import "TFHpple.h"

@interface VMessageViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;
    
    NSMutableArray *_titleArray;
    NSMutableArray *_imageArray;
    NSMutableArray *_contArray;
    NSArray *_array;
}
@end

@implementation VMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"V信息";
    
    //加入webview
    _webView = [[UIWebView alloc] init];
    _webView.tag = 11;
    _webView.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:_webView];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.clipsToBounds = YES;
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    
    NSString* strUrl = self.urlStr?self.urlStr:API_VMessage;//@"http://www.lomowo.com/posts/47689";
    
    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    //点击v信息表示阅读了
    [self updatePushCount];
    
}

- (void)setShareBtn:(BOOL)isShow{
    
    UIButton *bb = (UIButton *)[_webView viewWithTag:1101];
    if (bb == nil) {
        bb = [UIButton buttonWithType:UIButtonTypeCustom];
        bb.frame = CGRectMake(_webView.frame.size.width - 32*MyAppDelegate.autoSizeScaleY, SCREEN_VIEW_HEIGHT - AltitudeHeight - 40, 32*MyAppDelegate.autoSizeScaleY, 32*MyAppDelegate.autoSizeScaleY);
        [bb addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchDown];
        [bb setTitle:@"" forState:UIControlStateNormal];
        [bb setTitle:@"" forState:UIControlStateHighlighted];
        [bb setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        bb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [bb setTag:1101];
        [_webView addSubview:bb];
        
    }
    
    [bb setHidden:!isShow];
}

//分享
- (void)doShare:(UIButton *)sender{
    
    ZLog(@"分享");
    ZLog(@"title:%@",[self AnalyticalTitle:_webView.request.URL.description]);
    ZLog(@"image:%@",[self AnalyticalImage:_webView.request.URL.description]);
    
    NSString *contentStr = [NSString stringWithFormat:@"我刚刚分享了%@",[[self AnalyticalTitle:_webView.request.URL.description] objectAtIndex:0]];
    NSString *imageUrl = [[self AnalyticalImage:_webView.request.URL.description] objectAtIndex:0];
    NSString *shareUrl = [_webView.request.URL.description stringByAppendingString:@"&resource_type=app_share"];
    NSDictionary *shareDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"我们班",@"title",
                              imageUrl,@"image",
                              contentStr,@"content",
                              shareUrl,@"url",
                              nil];
    
    [MyAppDelegate shareContext:shareDic];
}

//刷新push数量
- (void)updatePushCount{
    
    if (![SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserId]) {
        return;
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    [contentDic setObject:[SSKeychain passwordForService:keyChainAccessGroup account:keyChainUserId] forKey:@"uid"];
    
    [MYRequest requstWithDic:contentDic withUrl:API_PUSH_Count_Vinfo withRequestMethod:@"POST" isHTTPS:NO isMultiPart:NO andMultiPartFileUrl:nil andGetData:^(id data, NSError *error) {
        
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
        
        //重新获取push数量
        [MyAppDelegate getPushCount];
        
    }];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self showHUD];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self hideHUD];
    
    //控制分享按钮显示与隐藏
    if (self.urlStr) {
        [self setShareBtn:YES];
    }else{
        [self setShareBtn:NO];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self hideHUD];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *url = [request URL];
        ZLog(@"%@",url);
        
        VMessageViewController *ctrl = [[VMessageViewController alloc]init];
        ctrl.urlStr = url.description;
        [self.navigationController pushViewController:ctrl animated:YES];
        
        //不响应点击事件，保存当前页面
        return NO;
    }
    
    return YES;
}

#pragma mark - HTML
-(NSArray *)AnalyticalTitle:(NSString *)urlString{
    
    NSString *title=[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding/*CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)*/error:nil];
    
    //    NSLog(@"title%@",title);
    
    NSRange range=[title rangeOfString:@"<title>"];
    
    NSMutableString *needTidyString=[NSMutableString stringWithString:[title substringFromIndex:range.location+range.length]];
    
    //    NSLog(@"%@",needTidyString);
    
    NSRange rang2=[needTidyString rangeOfString:@"</title>"];
    
    NSMutableString *html2=[NSMutableString stringWithString:[needTidyString substringToIndex:rang2.location]];
    //NSLog(@"%@",html2);
    
    _titleArray=[[NSMutableArray alloc]init];
    
    [_titleArray addObject:html2];
    
    return _titleArray;
    
    
}

#pragma image
-(NSMutableArray *)AnalyticalImage:(NSString *)htmlString;{
    
    NSString *imageStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString] encoding:NSUTF8StringEncoding error:nil];
    
    NSRange rang1=[imageStr rangeOfString:@"<main>"];
    NSMutableString *imageStr2=[[NSMutableString alloc]initWithString:[imageStr substringFromIndex:rang1.location+rang1.length]];
    
    NSRange rang2=[imageStr2 rangeOfString:@"</main>"];
    NSMutableString *imageStr3=[[NSMutableString alloc]initWithString:[imageStr2 substringToIndex:rang2.location]];
    
//    NSLog(@"%@",imageStr3);
    
    NSData *dataTitle=[imageStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    
    NSArray *elements=[xpathParser searchWithXPathQuery:@"//img"];
    
    
    _imageArray=[[NSMutableArray alloc]init];
    
    
    for (TFHppleElement *element in elements) {
        
        NSDictionary *elementContent =[element attributes];
        
//         NSLog(@"%@",[elementContent objectForKey:@"src"]);
        
        [_imageArray addObject:[elementContent objectForKey:@"src"]];
    }
    
    return _imageArray;
    
}

#pragma cont
-(NSMutableArray *)AnalyticalCont:(NSString *)htmlString{
    
    NSString *imageStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString] encoding:NSUTF8StringEncoding error:nil];
    
    NSRange rang1=[imageStr rangeOfString:@"<p>"];
    NSMutableString *imageStr2=[[NSMutableString alloc]initWithString:[imageStr substringFromIndex:rang1.location]];
    
    NSRange rang2=[imageStr2 rangeOfString:@"<div class=\"clear\"></div>"];
    NSMutableString *imageStr3=[[NSMutableString alloc]initWithString:[imageStr2 substringToIndex:rang2.location]];
    
    //NSLog(@"%@",imageStr3);
    
    NSData *htmlData=[imageStr3 dataUsingEncoding:/*CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)*/NSUTF8StringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//p"];
    
    //NSLog(@"%@",elements);
    
    _contArray=[[NSMutableArray alloc]init];
    
    for (TFHppleElement *element in elements) {
        
        if ([element content]!=nil) {
            
            // NSLog(@"%@",[element content]);
            
            [_contArray addObject:[element content]];
            
        }
        
    }
    
    return _contArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
