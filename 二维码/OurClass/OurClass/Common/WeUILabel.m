//
//  WeUILabel.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "WeUILabel.h"
#import "AppDelegate.h"
#import "OurClass_Prefix.pch"

@implementation WeUILabel
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setFrame:CGRectMake(self.frame.origin.x * MyAppDelegate.autoSizeScaleFont, self.frame.origin.y/** MyAppDelegate.autoSizeScaleY*/, self.frame.size.width * MyAppDelegate.autoSizeScaleFont, self.frame.size.height * MyAppDelegate.autoSizeScaleY)];
        
        [self setFont:[UIFont systemFontOfSize:self.font.pointSize * MyAppDelegate.autoSizeScaleFont]];
    }
    return self;
}


@end
