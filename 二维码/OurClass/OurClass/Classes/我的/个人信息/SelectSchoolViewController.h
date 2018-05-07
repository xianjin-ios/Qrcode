//
//  SelectSchoolViewController.h
//  OurClass
//
//  Created by siqiyang on 16/4/11.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectSchoolViewController : BaseViewController

//判断是否从创建班级界面而来
@property (nonatomic,assign) BOOL isfromCreateClass;
@property (nonatomic,assign)  BOOL isFromClassList;

//判断是否是从编辑班级界面而来
@property (nonatomic,assign) BOOL isFromClassEdit;

@end
