//
//  WCUpbringingViewController.h
//  NewSolution
//
//  Created by 任春宁 on 15/1/22.
//  Copyright (c) 2015年 com.winchannel. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface webViewer : BaseViewController<UIWebViewDelegate>{
    
    NSString * _strUrl;
    
    NSString * _strTitle;
}

-(id)initWithUrl:(NSString*)url andTitle:(NSString*)title;

@end
