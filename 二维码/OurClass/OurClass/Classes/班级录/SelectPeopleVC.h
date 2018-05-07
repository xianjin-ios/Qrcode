//
//  SelectPeopleVC.h
//  OurClass
//
//  Created by STAR on 16/4/13.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "BaseViewController.h"

@protocol SELECTPEOPLE_DELEGATE <NSObject>

- (void)selectPeopleArr:(NSMutableArray *)selectArr;

@end
@interface SelectPeopleVC : BaseViewController

@property (nonatomic,weak)id <SELECTPEOPLE_DELEGATE> delegate;

@property (nonatomic,retain)NSString *delId;

@property (nonatomic,assign)BOOL isPublish;

@end
