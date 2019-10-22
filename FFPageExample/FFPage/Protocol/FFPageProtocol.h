//
//  FFPageProtocol.h
//  FFPage
//
//  Created by North on 2019/8/10.
//  Copyright © 2019 North. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FFPageProtocol <NSObject>


@required

/**
 返回本控制器的滚动视图
 
 @return 滚动视图
 */
- (UIScrollView *_Nonnull)scrollview;

@optional


/**
 滚动视图的偏移量改变了
 
 @param conentOffset 偏移量
 */
- (void)conentOffsetDidChanged:(CGPoint)conentOffset;
@end


