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


#define FFPageBeginRefreshNotice @"FFPageBeginRefreshNotice"
#define FFPageEndRefreshNotice   @"FFPageEndRefreshNotice"


NS_INLINE NSUInteger randomBetween(NSUInteger begin , NSUInteger end){
    
    NSUInteger value = arc4random() % end + begin;
    if(value > end) value -= begin;
    return value;
    
}

#endif /* FFPage_h */
