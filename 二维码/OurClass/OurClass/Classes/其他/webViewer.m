//
//  WCUpbringingViewController.m
//  NewSolution
//
//  Created by 任春宁 on 15/1/22.
//  Copyright (c) 2015年 com.winchannel. All rights reserved.
//

#import "webViewer.h"

@interface webViewer ()

@end

@implementation webViewer


-(id)initWithUrl:(NSString*)url andTitle:(NSString*)title{
    self = [super init];
    if (self) {
        _strUrl = url;
        _strTitle = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _strTitle;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    //加入webview
    UIWebView * webView = [[UIWebView alloc] init];
    webView.tag = 11;
    webView.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:webView];
    webView.backgroundColor = [UIColor clearColor];
    webView.clipsToBounds = YES;
    webView.delegate = self;
    
    NSString* strUrl = _strUrl;
    
    NSURL *url = [[NSURL alloc] initWithString:strUrl];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

#pragma mark - webViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self showHUD];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self hideHUD];
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
        if (url != nil) {
            ZLog(@"%@",url);
            NSString *urlStr = [NSString stringWithFormat:@"%@",url];
            webViewer *webView = [[webViewer alloc]initWithUrl:urlStr andTitle:@"详情"];
            [self.navigationController pushViewController:webView animated:YES];
            
            return NO;
        }
    }
    
    return YES;
}


@end
