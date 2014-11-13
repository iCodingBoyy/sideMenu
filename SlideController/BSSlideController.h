//
//  BSSlideController.h
//  BusButler
//
//  Created by 马远征 on 14-8-26.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSSlideController : UIViewController
@property (nonatomic, strong) UIViewController *leftMenuController;
@property (nonatomic, strong) UIViewController *rightMenuController;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, assign) CGFloat leftSideWidth;
@property (nonatomic, assign) CGFloat rightSideWidth;
@property (nonatomic, assign) NSTimeInterval leftAnimationDuration;
@property (nonatomic, assign) NSTimeInterval rightAnimationDuration;
@property (nonatomic, assign) BOOL canBeZoomed;
@property (nonatomic, assign) BOOL showBorderShadow;

- (instancetype)initWithRootViewController:(UIViewController*)rootVC
                        leftMenuController:(UIViewController*)leftMenuVC
                       rightMenuController:(UIViewController*)rightMenuVC;
- (void)setRootViewController:(UIViewController *)rootViewController animation:(BOOL)animation;
- (void)showLeftViewController:(BOOL)animated;
- (void)showRightViewController:(BOOL)animated;
- (void)showRootViewController:(BOOL)animated;
@end
