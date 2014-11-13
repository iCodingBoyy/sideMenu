//
//  BSSlideController.m
//  BusButler
//
//  Created by 马远征 on 14-8-26.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "BSSlideController.h"

typedef NS_ENUM(NSInteger, GestureMoveDirection)
{
    GestureNotMoving = 0,
    GestureMovingOnLeft,
    GestureMovingOnRight,
};


#define KFrameSizeWidth self.view.frame.size.width
#define KFrameSizeHeight self.view.frame.size.height

static const CGFloat _leftSideWidth_ = 200.0f;
static const CGFloat _rightSideWidth_ = 200.0f;

#define KLeftSideWidth 200.0f
#define KRightSideWidth 200.0f

@interface BSSlideController () <UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *_panGuestureRecognizer;
    UITapGestureRecognizer *_tapGuestureRecognizer;
    CGPoint _startPanPoint;
}
@property (nonatomic, strong) UIView *rootContentView;
@property (nonatomic, assign) GestureMoveDirection movingDirection;
@property (nonatomic, assign) BOOL isShowLeftSideView;
@property (nonatomic, assign) BOOL isShowRightSideView;
@property (nonatomic, assign) BOOL panMovingRightOrLeft;
@end


@implementation BSSlideController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (instancetype)initWithRootViewController:(UIViewController*)rootViewController_
                        leftMenuController:(UIViewController*)leftMenuViewController_
                       rightMenuController:(UIViewController*)rightMenuViewController_;
{
    self = [super init];
    if (self)
    {
        NSAssert(rootViewController_ != nil, @"你必须设置一个根视图控制器");
        
        self.rootViewController = rootViewController_;
        self.leftMenuController = leftMenuViewController_;
        self.rightMenuController = rightMenuViewController_;
        
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        // 初始化默认参数
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    // 设置初始化默认值
    _leftSideWidth = KLeftSideWidth;
    _rightSideWidth = KRightSideWidth;
    
    // 侧滑默认显示边框阴影
    _showBorderShadow = YES;
    
    // 平移缩放效果
    _canBeZoomed = NO;
    
    [self addPanAndTapGestureRecognizer];
}


#pragma mark -
#pragma mark 平移和Tap手势

- (void)addPanAndTapGestureRecognizer
{
    // 添加平移手势
    _panGuestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizer:)];
    [_panGuestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_panGuestureRecognizer];
    
    
    _tapGuestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [_tapGuestureRecognizer setDelegate:self];
    [_rootViewController.view addGestureRecognizer:_tapGuestureRecognizer];
}

#pragma mark -
#pragma mark 手势

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        _startPanPoint = _rootViewController.view.frame.origin;
        if (_rootViewController.view.frame.origin.x == 0)
        {
            [self showShadow:_showBorderShadow];
        }
        // 判断移动的方向
        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
        if( velocity.x > 0 )
        {
            // 向右移动，
            if (_rootViewController.view.frame.origin.x >= 0 && _leftMenuController && !_leftMenuController.view.superview)
            {
                // 插入左侧边视图
                _leftMenuController.view.frame = self.view.bounds;
                _leftMenuController.view.autoresizingMask = self.view.autoresizingMask;
                [self.view insertSubview:_leftMenuController.view belowSubview:_rootViewController.view];
                // 移除右侧边视图
                if (_rightMenuController && _rightMenuController.view.superview)
                {
                    [_rightMenuController.view removeFromSuperview];
                }
            }
        }
        else if (velocity.x < 0)
        {
            // 向左移动，
            if (_rootViewController.view.frame.origin.x <= 0 && _rightMenuController && !_rightMenuController.view.superview)
            {
                // 插入右边侧边视图
                _rightMenuController.view.frame = self.view.bounds;
                _rightMenuController.view.autoresizingMask = self.view.autoresizingMask;
                [self.view insertSubview:_rightMenuController.view belowSubview:_rootViewController.view];
                // 移除左边侧边视图
                if (_leftMenuController && _leftMenuController.view.superview)
                {
                    [_leftMenuController.view removeFromSuperview];
                }
            }
        }
        return;
    }
    
    CGPoint currentPostion = [panGestureRecognizer translationInView:self.view];
    CGFloat xoffset = _startPanPoint.x + currentPostion.x;
    if (xoffset > 0)
    {
        //向右滑
        if (_leftMenuController && _leftMenuController.view.superview)
        {
            xoffset = MIN(_leftSideWidth_, xoffset);
        }
        else
        {
            xoffset = 0;
        }
    }
    else if( xoffset < 0 )
    {//向左滑
        if (_rightMenuController && _rightMenuController.view.superview)
        {
            xoffset = MAX(-_rightSideWidth_, xoffset);
        }
        else
        {
            xoffset = 0;
        }
    }
    
    if (xoffset != _rootViewController.view.frame.origin.x)
    {
        if ( !_canBeZoomed)
        {
            _rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(xoffset, 0.0f),1.0,1.0);
            return;
        }
        else
        {
            CGFloat scale = ABS(600 - ABS(xoffset)) / 600;
            scale = MAX(0.8, scale);
            
            _rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(xoffset, 0.0f),scale,scale);
        }
    }
    
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_rootViewController.view.frame.origin.x != 0 &&
            _rootViewController.view.frame.origin.x != _leftSideWidth_ &&
            _rootViewController.view.frame.origin.x != -_rightSideWidth_)
        {
            if (_panMovingRightOrLeft && _rootViewController.view.frame.origin.x > 20)
            {
                [self showLeftViewController:YES];
            }
            else if(!_panMovingRightOrLeft && _rootViewController.view.frame.origin.x < -20)
            {
                [self showRightViewController:YES];
            }
            else
            {
                [self hideSideMenuController:YES];
            }
        }
        else if (_rootViewController.view.frame.origin.x == 0)
        {
            [self showShadow:false];
        }
    }
    else
    {
        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
        if (velocity.x > 0)
        {
            _panMovingRightOrLeft = true;
        }
        else if(velocity.x < 0)
        {
            _panMovingRightOrLeft = false;
        }
    }
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer*)tapGestureRecognizer
{
    [self hideSideMenuController:YES];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _panGuestureRecognizer)
    {
        // 平移速度小于600，切水平偏移大于垂直偏移(左右移动),启用手势
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.view];
        CGPoint velocity = [panGesture velocityInView:self.view];
        if (velocity.x < 600 && ABS(translation.x) / ABS(translation.y) > 1 )
        {
            return YES;
        }
        return NO;
    }
    return YES;
}


- (void)showShadow:(BOOL)show
{
    NSAssert(_rootViewController != nil, @"rootViewController不能为空！");
    _rootViewController.view.layer.shadowOpacity    = show ? 0.8f : 0.0f;
    if (show)
    {
        _rootViewController.view.layer.cornerRadius = 4.0f;
        _rootViewController.view.layer.shadowOffset = CGSizeZero;
        _rootViewController.view.layer.shadowRadius = 4.0f;
        _rootViewController.view.layer.shadowPath   = [UIBezierPath bezierPathWithRect:_rootViewController.view.bounds].CGPath;
    }
}

- (void)loadView
{
    [super loadView];
    UIView *contentView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化加载根视图
    NSAssert(self.rootViewController != nil, @"你必须设置一个根视图控制器");
//    self.rootViewController.view.frame = self.view.bounds;
//    self.rootViewController.view.center = CGPointMake(KScreenWidth*0.5,KScreenHeight*0.5);
    self.rootViewController.view.autoresizingMask = self.view.autoresizingMask;
    [self.view addSubview:self.rootViewController.view];
}


#pragma mark -
#pragma mark 视图控制器设置

- (void)setRootViewController:(UIViewController *)rootViewController
{
    if (_rootViewController != rootViewController)
    {
        if (_rootViewController)
        {
            [_rootViewController removeFromParentViewController];
        }
        _rootViewController = rootViewController;
        if (_rootViewController)
        {
            [self addChildViewController:_rootViewController];
        }
    }
}

- (void)setLeftMenuController:(UIViewController *)leftMenuController
{
    if (_leftMenuController != leftMenuController)
    {
        if (_leftMenuController)
        {
            [_leftMenuController removeFromParentViewController];
        }
        _leftMenuController = leftMenuController;
        if (_leftMenuController)
        {
            [self addChildViewController:_leftMenuController];
        }
    }
}

- (void)setRightMenuController:(UIViewController *)rightMenuController
{
    if (_rightMenuController != rightMenuController)
    {
        if (_rightMenuController)
        {
            [_rightMenuController removeFromParentViewController];
        }
        _rightMenuController = rightMenuController;
        if (_rightMenuController)
        {
            [self addChildViewController:_rightMenuController];
        }
    }
}

// 设置一个新的跟控制器
- (void)setRootViewController:(UIViewController *)rootViewController animation:(BOOL)animation
{
    NSAssert(rootViewController != nil, @"新的根视图控制器不能为空！");
    if (rootViewController == nil)
    {
        return;
    }
    if (_rootViewController == rootViewController)
    {
        // 如果是同一个控制器则隐藏侧边栏
        [self hideSideMenuController:YES];
        return;
    }
    
    UIViewController *previousController = _rootViewController;
    
    _rootViewController = rootViewController;
    [self addChildViewController:_rootViewController];
    
    _rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat sideWidth = _panMovingRightOrLeft ? KLeftSideWidth : KRightSideWidth;
    CGFloat offset = sideWidth + (self.view.frame.size.width-sideWidth)/2.0;
    offset = _panMovingRightOrLeft ? offset : -offset;
    
    WEAKSELF;
    [self showShadow:YES];
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF;
        if ( !_canBeZoomed)
        {
            previousController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(offset, 0.0f),1.0,1.0);
            strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(offset, 0.0f),1.0,1.0);
        }
        else
        {
            previousController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(offset, 0.0f),0.8,0.8);
            strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(offset, 0.0f),0.8,0.8);
        }

    } completion:^(BOOL finished) {
        STRONGSELF;
        [strongSelf.view addSubview:_rootViewController.view];
        [strongSelf.rootViewController didMoveToParentViewController:weakSelf];
        
        [previousController willMoveToParentViewController:nil];
        [previousController removeFromParentViewController];
        [previousController.view removeFromSuperview];
        
        _panMovingRightOrLeft = NO;
        [UIView animateWithDuration:0.4 animations:^{
            STRONGSELF;
            strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        }completion:^(BOOL finished)
         {
             STRONGSELF;
             [weakSelf showShadow:NO];
             
             [strongSelf.leftMenuController.view removeFromSuperview];
             [strongSelf.rightMenuController.view removeFromSuperview];
         }];
        
    }];
}




#pragma mark -
#pragma mark 显示视图控制器

- (void)showLeftViewController:(BOOL)animated
{
    if (_leftMenuController == nil)
    {
        return;
    }
    
    NSTimeInterval animatedTime = 0;
    if (animated)
    {
        CGFloat originX = _rootViewController.view.frame.origin.x;
        animatedTime = ABS(_leftSideWidth_ - originX) / _leftSideWidth_ * 0.35;
    }
    
    [self showShadow:YES];
    WEAKSELF;
    [UIView animateWithDuration:animatedTime animations:^{
        STRONGSELF;
        if ( !_canBeZoomed)
        {
            strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(KLeftSideWidth, 0.0f),1.0,1.0);
        }
        else
        {
            CGFloat scale = ABS(600 - ABS(KLeftSideWidth)) / 600;
            scale = MAX(0.8, scale);
            
            strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(KLeftSideWidth, 0.0f),scale,scale);
        }
    }];

}

- (void)showRightViewController:(BOOL)animated
{
    if (_rightMenuController == nil)
    {
        return;
    }

    NSTimeInterval animatedTime = 0;
    if (animated)
    {
        CGFloat originX = self.rootViewController.view.frame.origin.x;
        animatedTime = ABS(_rightSideWidth_ + originX) / _rightSideWidth_ * 0.35;
    }
    [self showShadow:YES];
    WEAKSELF;
    [UIView animateWithDuration:animatedTime animations:^{
        STRONGSELF;
        if ( !_canBeZoomed)
        {
           strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(-KRightSideWidth, 0.0f),1.0,1.0);
            return;
        }
        else
        {
            CGFloat scale = ABS(600 - ABS(KRightSideWidth)) / 600;
            scale = MAX(0.8, scale);
            
            strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(-KRightSideWidth, 0.0f),scale,scale);
        }
    }];

}

- (void)showRootViewController:(BOOL)animated
{
    [self hideSideMenuController:animated];
}

- (void)hideSideMenuController:(BOOL)animated
{
    _panMovingRightOrLeft = NO;
    NSTimeInterval animatedTime = 0;
    UIView *view = _rootViewController.view;
    if (animated)
    {
        animatedTime = ABS(view.frame.origin.x / (view.frame.origin.x > 0?_leftSideWidth_:_rightSideWidth_)) * 0.35;
    }
    NSLog(@"---animatedTime---%f",animatedTime);
    WEAKSELF;
    [UIView animateWithDuration:animatedTime animations:^{
        STRONGSELF;
        strongSelf.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    }completion:^(BOOL finished)
     {
         STRONGSELF;
         [weakSelf showShadow:NO];
         [strongSelf.leftMenuController.view removeFromSuperview];
         [strongSelf.rightMenuController.view removeFromSuperview];
     }];
}

@end
