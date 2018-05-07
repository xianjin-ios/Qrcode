//
//  WeButton.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "WeButton.h"
#import "OurClass_Prefix.pch"
#import "AppDelegate.h"

@implementation WeButton
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setFrame:CGRectMake(self.frame.origin.x /** MyAppDelegate.autoSizeScaleX*/, self.frame.origin.y/* * MyAppDelegate.autoSizeScaleY*/, self.frame.size.width * MyAppDelegate.autoSizeScaleY, self.frame.size.height * MyAppDelegate.autoSizeScaleY)];
        
        [self setFont:[UIFont systemFontOfSize:self.font.pointSize * MyAppDelegate.autoSizeScaleFont]];
    }
    return self;
}
@end
