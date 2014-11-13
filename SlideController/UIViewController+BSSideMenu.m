//
//  UIViewController+BSSideMenu.m
//  BusButler
//
//  Created by 马远征 on 14-9-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "UIViewController+BSSideMenu.h"

@implementation UIViewController (BSSideMenu)
- (BSSlideController*)sideController
{
    if ([self.parentViewController isKindOfClass:[BSSlideController class]])
    {
        return (BSSlideController*)(self.parentViewController);
    }
    return nil;
}
@end
