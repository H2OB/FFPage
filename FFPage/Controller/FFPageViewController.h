//
//  FFPageViewController.h
//  FFPage
//
//  Created by North on 2019/8/5.
//  Copyright © 2019 North. All rights reserved.
//

#import <UIKit/UIKit.h>

//滚动方向
typedef NS_ENUM(NSUInteger, ScrollDirection) {
    ScrollDirectionHorizontal = 0, //横向滚动 默认
    ScrollDirectionVertical        //纵向滚动
};

@class FFPageViewController;

@protocol FFPageViewControllerDelegate <NSObject>

@required

/**
 控制器总数量

 @param pageViewConteoller pageViewConteoller
 @return 数量
 */
- (NSUInteger)totalPagesOfpageViewController:(FFPageViewController *_Nonnull)pageViewConteoller;

/**
 返回页码对应控制器

 @param pageViewConteoller pageViewConteoller
 @param page 页码
 @return 控制器
 */
- (UIViewController *_Nonnull)pageViewController:(FFPageViewController *_Nonnull)pageViewConteoller                             controllerForPage:(NSInteger)page;

@optional

/**
 控制器页面改变

 @param pageViewController pageViewController
 @param currentPage 当前页码
 */
- (void)pageViewController:(FFPageViewController *_Nonnull)pageViewController
        currentPageChanged:(NSInteger)currentPage;


/**
 滚动视图偏移量改变

 @param pageViewController pageViewController
 @param contentOffset 偏移量
 */
- (void)pageViewController:(FFPageViewController *_Nonnull)pageViewController
        contentOffSetChanged:(CGPoint)contentOffset;



@end

@interface FFPageViewController : UIViewController

/**
 代理
 */
@property (nonatomic, weak, nullable) id<FFPageViewControllerDelegate> delegate;

/**
 滚动方向
 */
@property (assign ,nonatomic) ScrollDirection scrollDirection;

/**
 前/后预加载页数  总加载页数 = 2 * prePages + 1
 */
@property (assign ,nonatomic) NSUInteger prePages;

/**
 同时存在的控制器最大数量 超过这个数量 不常用的控制器将会被释放
 如果不设置值，默认不释放控制器
 如果设置值，应当大于 2 * prePages + 1
 */
@property (assign ,nonatomic) NSUInteger maxPages;

/**
 默认显示页数
 */
@property(assign ,nonatomic ) NSInteger defaultPage;

/**
 滚动容器
 */
@property(readonly ,nonatomic) UIScrollView * _Nonnull scrollview;

/**
 当前页数
 */
@property(assign ,nonatomic ,readonly) NSInteger currentPage;

/**
 当前控制器
 */
@property(weak ,nonatomic ,readonly) UIViewController * _Nullable currentController;

/**
 滚动到第几页
 
 @param page 需要滚动的页数
 @param animation 是否动画
 */
- (void)scrollToPage:(NSInteger)page animation:(BOOL)animation;

/**
 刷新数据
 */
- (void)reloadData;

@end


