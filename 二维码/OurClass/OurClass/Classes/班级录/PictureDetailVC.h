//
//  PictureDetailVC.h
//  OurClass
//
//  Created by STAR on 16/4/12.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "BaseViewController.h"

@protocol ChangeDianzan_delegate <NSObject>

-(void)changeDianzan:(NSDictionary *)newDic;

@end
@interface PictureDetailVC : BaseViewController

@property (nonatomic,assign) id<ChangeDianzan_delegate>delegate;

- (PictureDetailVC*)initWithInfoDic : (NSDictionary*) infoDic;

@end
