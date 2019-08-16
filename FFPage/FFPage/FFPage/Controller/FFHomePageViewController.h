//
//  FFHomePageViewController.h
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFPage.h"
#import "FFPageProtocol.h"

typedef NS_ENUM(NSUInteger, FFHomePageStyle) {
    
    FFHomePageStyleHeadEnlarge = 0, //头部放大
    FFHomePageStyleHeadRefresh, //头部整体刷新
    FFHomePageStyleSubRefresh //子控制器刷新 默认
};



@interface FFHomePageViewController : UIViewController

/**
 样式 默认头部放大
 */
@property (assign ,nonatomic) FFHomePageStyle style;

/**
 忽略上方间距 如果需要躲避导航条 传导航条高度
 Tips:躲避导航条指视图跟导航条有重叠才传值
 */
@property (assign ,nonatomic) CGFloat ignoreTopSpeace;

/**
 上方head高度
 */
@property (assign ,nonatomic) CGFloat headHeight;

/**
 选项栏高度
 */
@property (assign ,nonatomic) CGFloat tabHeight;

/**
 头部控制器
 */
@property (retain ,nonatomic ,nonnull) UIViewController *headViewController;

/**
 选项栏控制器
 */
@property (retain ,nonatomic ,nonnull) UIViewController *tabViewController;

/**
 分页控制器
 */
@property (retain ,nonatomic ,nonnull) UIViewController *pageViewController;

/**
 可上下滚动的滚动视图
 */
@property (readonly ,nonatomic) UIScrollView * _Nonnull scrollview;


/**
 更新当前控制器 这个控制器是下方pageViewController里面正在显示的那一个
 目的是获取滚动视图
 @param controller 实现FFPageProtocol的控制器
 */
- (void)updateCurrentController:(id<FFPageProtocol>_Nonnull )controller;


/**
 刷新 headHeight/tabHeight之后 调用
 
 @param animation 是否动画
 @param completion 完成回调
 */
- (void)reloadHeightWithAnimation:(BOOL)animation completion:(void(^_Nullable)(void))completion;


@end


