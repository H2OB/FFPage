//
//  FFRereshView.h
//  FFPage
//
//  Created by North on 2019/8/14.
//  Copyright © 2019 North. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFPage.h"

typedef NS_ENUM(NSUInteger, FFRereshStatus) {
    
    FFRereshStatusNormal = 0, //普通状态
    FFRereshStatusPulling, //下拉或者上提
    FFRereshStatusWillBeginRefresh, //将要刷新
    FFRereshStatusRereshing, //正在刷新
    FFRereshStatusWillEndRefresh, //将要结束刷新
    FFRereshStatusNoMore //没有更多数据
};

typedef void(^FFRefreshBlock)(void);


@interface FFRereshView : UIView

@property (assign ,nonatomic) FFRereshStatus status;

@property (assign ,nonatomic) CGFloat percent;

@property (weak ,nonatomic) UIScrollView * scrollView;

@property (assign ,nonatomic) BOOL isFooter;

+ (instancetype)initWithRefreshBlock:(FFRefreshBlock)block;

+ (instancetype)initWithTarget:(id)target
                        action:(SEL)action;

- (void)setUpSubView;

- (CGFloat)refreshHeight;

- (void)statusUpdated;

- (void)percentUpdated;


/**
 开始刷新
 */
- (void)beginRefresh;

/**
 结束刷新
 */
- (void)endRefresh;


@end


