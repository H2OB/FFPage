//
//  UIScrollView+FFPage.m
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#import "UIScrollView+FFPage.h"
#import <objc/runtime.h>
#import "FFPage.h"

static void *TouchKey = @"touchKey";
static void *BlockKey = @"blockKey";
static void *FFHeaderRefreshKey = @"FFHeaderRefreshKey";
static void *FFFooterRefreshKey = @"FFFooterRefreshKey";
static void *AnimationKey = @"AnimationKey";

@implementation UIScrollView (FFPage)

- (void)setIsTouch:(BOOL)isTouch{
    
    if(isTouch != self.isTouch){
        
        objc_setAssociatedObject(self, TouchKey, @(isTouch).stringValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if([self blockArray]){
            
            for (TouchBlock block in [self blockArray]) {
                if(block) block(isTouch);
            }
            
        }
    }
}

- (BOOL)isTouch{
    
    return [objc_getAssociatedObject(self, TouchKey) boolValue];
    
}

- (void)addTounchBlock:(TouchBlock)block{
    
    NSMutableArray * array = [self blockArray] ? [self blockArray].mutableCopy : @[].mutableCopy;
    
    [array addObject:block];
    
    objc_setAssociatedObject(self, BlockKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSMutableArray *)blockArray{
    
    return objc_getAssociatedObject(self, BlockKey);
}



- (BOOL)isReachTop{
    
    return self.contentOffset.y <= -self.contentInset.top;
}

- (BOOL)isReachLeft{
    
    return self.contentOffset.x <= -self.contentInset.left;
}

- (BOOL)isReachBottom{
    
    return self.contentOffset.y >= self.maxOffsetY;
}

- (BOOL)isReachRight{
    
    return self.contentOffset.x >= self.maxOffsetX;
}
- (CGFloat)maxOffsetX{
    
    return fmax(0, self.contentSize.width - CGRectGetWidth(self.bounds)) + self.contentInset.right;
}

- (CGFloat)maxOffsetY{
    
    return fmax(0, self.contentSize.height - CGRectGetHeight(self.bounds)) + self.contentInset.bottom;
}

- (void)setFf_header:(FFRereshView *)ff_header{
    
    if(ff_header != self.ff_header){
        [self.ff_header removeFromSuperview];
        [self insertSubview:ff_header atIndex:0];
        objc_setAssociatedObject(self, FFHeaderRefreshKey, ff_header, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
}
- (FFRereshView *)ff_header{
    
    return objc_getAssociatedObject(self, FFHeaderRefreshKey);
}


- (void)setFf_footer:(FFRereshView *)ff_footer {
    
    if(ff_footer != self.ff_footer){
        [self.ff_footer removeFromSuperview];
        ff_footer.isFooter = YES;
        [self insertSubview:ff_footer atIndex:0];
        objc_setAssociatedObject(self, FFFooterRefreshKey, ff_footer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


- (FFRereshView *)ff_footer{
    
    return objc_getAssociatedObject(self, FFFooterRefreshKey);
}



- (void)setIsAnimationing:(BOOL)isAnimationing{
    
    objc_setAssociatedObject(self, AnimationKey, @(isAnimationing).stringValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAnimationing{
    
     return [objc_getAssociatedObject(self, AnimationKey) boolValue];
}


@end
