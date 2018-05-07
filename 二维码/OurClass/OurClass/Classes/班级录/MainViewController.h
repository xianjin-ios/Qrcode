//
//  MainViewController.h
//  OurClass
//
//  Created by huadong on 16/3/31.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "BaseViewController.h"

@interface MainViewController : BaseViewController

@property (nonatomic,assign) BOOL NeedRefresh;

- (void)refreshData;

- (void)getPushInfo:(NSDictionary *)dic;

@end
