//
//  WeUITextField.m
//  OurClass
//
//  Created by huadong on 16/4/5.
//  Copyright © 2016年 huadong. All rights reserved.
//

#import "WeUITextField.h"
#import "AppDelegate.h"
#import "OurClass_Prefix.pch"

@implementation WeUITextField

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        //[self setFrame:CGRectMake(self.frame.origin.x * MyAppDelegate.autoSizeScaleX, self.frame.origin.y/* * MyAppDelegate.autoSizeScaleY*/, self.frame.size.width * MyAppDelegate.autoSizeScaleX, self.frame.size.height * MyAppDelegate.autoSizeScaleY)];
        
        [self setFont:[UIFont systemFontOfSize:self.font.pointSize * MyAppDelegate.autoSizeScaleFont]];

    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
