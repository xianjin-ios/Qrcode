//
//  WeUIView.m
//  OurClass
//
//  Created by huadong on 16/4/1.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "WeUIView.h"
#import "AppDelegate.h"
#import "OurClass_Prefix.pch"

@implementation WeUIView
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setFrame:CGRectMake(self.frame.origin.x /** MyAppDelegate.autoSizeScaleX*/, self.frame.origin.y/* * MyAppDelegate.autoSizeScaleY*/, self.frame.size.width * MyAppDelegate.autoSizeScaleFont, self.frame.size.height * MyAppDelegate.autoSizeScaleY)];
        
    }
    return self;
}
@end
