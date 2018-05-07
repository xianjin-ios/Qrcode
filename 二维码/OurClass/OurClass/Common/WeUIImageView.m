//
//  WeUIImageView.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "WeUIImageView.h"
#import "OurClass_Prefix.pch"
#import "AppDelegate.h"

@implementation WeUIImageView
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setFrame:CGRectMake(self.frame.origin.x * MyAppDelegate.autoSizeScaleFont, self.frame.origin.y/* * MyAppDelegate.autoSizeScaleY*/, self.frame.size.width * MyAppDelegate.autoSizeScaleFont, self.frame.size.height * MyAppDelegate.autoSizeScaleY)];

    }
    return self;
}

@end
