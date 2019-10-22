//
//  FFPage.h
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#ifndef FFPage_h
#define FFPage_h

#import "FFPageViewController.h"
#import "FFHomePageViewController.h"
#import "FFDynamicItem.h"
#import "UIScrollView+FFPage.h"
#import "FFRereshView.h"

//开始刷新通知
#define FFPageBeginRefreshNotice @"FFPageBeginRefreshNotice"
//结束刷新通知
#define FFPageEndRefreshNotice   @"FFPageEndRefreshNotice"

//滚动视图偏移量改变通知
#define FFHomeScrollViewContentOffsetChangedNotice   @"FFHomeScrollViewContentOffsetChangedNotice"

//判断是否是全面屏
NS_INLINE BOOL isFullScreen() {
    //全面屏最低的版本就是 iOS11
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > CGFLOAT_MIN;
    }
    return NO;
}

#endif /* FFPage_h */
