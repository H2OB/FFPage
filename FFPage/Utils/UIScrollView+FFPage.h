//
//  UIScrollView+FFPage.h
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FFRereshView;

typedef void(^TouchBlock)(BOOL isTouch);

@interface UIScrollView (FFPage)

/**
 是否正在交互
 */
@property (assign, nonatomic) BOOL isTouch;

/**
 是否到达顶部
 */
@property(assign, nonatomic) BOOL isReachTop;
/**
 是否到达左边
 */
@property(assign, nonatomic) BOOL isReachLeft;

/**
 是否到达底部
 */
@property(assign, nonatomic) BOOL isReachBottom;

/**
 是否到达底部
 */
@property(assign, nonatomic) BOOL isReachRight;

/**
 最大X偏移量
 */
@property (assign, nonatomic) CGFloat maxOffsetX;

/**
 最大Y偏移量
 */
@property (assign, nonatomic) CGFloat maxOffsetY;

/**
 添加一个监控交互状态改变回调

 @param block 回调
 */
- (void)addTounchBlock:(TouchBlock)block;


#pragma mark - 刷新相关

/**
 是否 正在结束/开始刷新 在此期间 禁止交互 避免页面弹跳
 */
@property(assign, nonatomic) BOOL isAnimationing;


@property (retain, nonatomic) FFRereshView * ff_header;

@property (retain, nonatomic) FFRereshView * ff_footer;

@end


