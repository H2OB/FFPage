//
//  FFHomePageViewController.m
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#import "FFHomePageViewController.h"

@interface FFHomePageViewController ()<UIGestureRecognizerDelegate>

/**
 当前分页中显示的控制器
 */
@property (weak ,nonatomic) id<FFPageProtocol> controller;



/**
 是否更新位置
 */
@property (assign ,nonatomic) BOOL isUpdateFrame;


/**
 物理动画容器
 */
@property(nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

/**
 惯性行为
 */
@property(nonatomic, weak)   UIDynamicItemBehavior *inertialBehavior;//惯性

/**
 减速行为
 */
@property(nonatomic, weak)   UIDynamicItemBehavior *decelerateBehavior;

/**
 回弹行为
 */
@property(nonatomic, weak)   UIAttachmentBehavior *bounceBehavior;

/**
 最大拖动系数
 */
@property(assign,nonatomic)  CGFloat maxBounceDistance;

/**
 是否手指触摸
 */
@property(assign,nonatomic)  BOOL isTouch;

/**
 正在滚动
 */
@property(assign,nonatomic)  BOOL isScroll;



@end

@implementation FFHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    
    [self setUpNotice];
}
- (void)setUpView{
    
    [self.view addSubview:self.scrollview];
    
    [self addChildViewController:self.headViewController];
    [self.scrollview addSubview:self.headViewController.view];
    
    [self addChildViewController:self.tabViewController];
    [self.scrollview addSubview:self.tabViewController.view];
    
    [self addChildViewController:self.pageViewController];
    [self.scrollview addSubview:self.pageViewController.view];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
}

- (void)setUpNotice{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginRefresh:) name:FFPageBeginRefreshNotice object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh:) name:FFPageEndRefreshNotice object:nil];
    
}

- (void)beginRefresh:(NSNotification *)notice{
    
    FFRereshView * refreshView = notice.object;
    if(refreshView.scrollView == self.scrollview || self.controller.scrollview == refreshView.scrollView){
        
        [self.dynamicAnimator removeAllBehaviors];
        self.inertialBehavior = nil;
        self.bounceBehavior = nil;
        self.decelerateBehavior = nil;
        
        return;
    }
    
}

- (void)endRefresh:(NSNotification *)notice{
    
    FFRereshView * refreshView = notice.object;
    if(refreshView.scrollView == self.scrollview || self.controller.scrollview == refreshView.scrollView){
        
        [self.dynamicAnimator removeAllBehaviors];
        self.inertialBehavior = nil;
        self.bounceBehavior = nil;
        self.decelerateBehavior = nil;
        
        return;
    }
    

}

- (void)updateCurrentController:(id<FFPageProtocol>)controller{
    
    self.controller = controller;
    [self.controller scrollview].scrollEnabled = NO;
    if(self.controller.scrollview.header) self.controller.scrollview.header .interactiveEnable = NO;
    if(self.controller.scrollview.footer) self.controller.scrollview.footer .interactiveEnable = NO;
    if(self.scrollview.header) self.scrollview.footer .interactiveEnable = NO;
    
}

- (void)reloadHeightWithAnimation:(BOOL)animation completion:(void (^)(void))completion{
    
    self.isUpdateFrame = YES;
    
    [UIView animateWithDuration:animation ? .2 :CGFLOAT_MIN animations:^{
        
        [self.view setNeedsLayout];
        
    } completion:^(BOOL finished) {
        
        if(finished && completion)completion();
    }];
}


- (void)panGestureAction:(UIPanGestureRecognizer *)sender{
    
    if(sender.state == UIGestureRecognizerStateBegan){
        self.isTouch = YES;
        self.isScroll = YES;
        
        [self.dynamicAnimator removeAllBehaviors];
        
    }
    
    else if(sender.state == UIGestureRecognizerStateChanged){
        
        CGFloat transY = [sender translationInView:self.view].y;//滚动方向y>0为向下
        [self transitionWithOffset:transY];
        
        [sender setTranslation:CGPointZero inView:self.view];
    }
    
    else if(sender.state == UIGestureRecognizerStateEnded ){
        
        self.isTouch = NO;
        
        CGPoint velocity = [sender velocityInView:self.view];
        
        if(fabs(velocity.y)<100){
            
            CGFloat outOffY = self.scrollview.contentOffset.y;//外部滚动视图的偏移量
            CGFloat subOffY = [self.controller scrollview].contentOffset.y; //子视图的偏移量
            CGFloat maxSubOffY = self.scrollview.maxOffsetY;
            
            if(subOffY > maxSubOffY)[self bounceForScrollView:[self.controller scrollview] isTop:NO];
            else if(subOffY < -[self.controller scrollview].contentInset.top) [self bounceForScrollView:[self.controller scrollview] isTop:YES];
            else if(outOffY < -self.scrollview.contentInset.top) [self bounceForScrollView:self.scrollview isTop:YES];
            return;
        }
        
        //惯性
        
        FFDynamicItem *item = [[FFDynamicItem alloc] init];
        item.center = CGPointZero;
        __block CGFloat lastCenterY = 0;
        UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
        [inertialBehavior addLinearVelocity:CGPointMake(0, -velocity.y) forItem:item];
        inertialBehavior.resistance = 2;
        __weak typeof(self) weakSelf = self;
        inertialBehavior.action = ^{
            
            [weakSelf transitionWithOffset:lastCenterY - item.center.y];
            lastCenterY = item.center.y;
            
            CGPoint inertialVelocity = [weakSelf.inertialBehavior linearVelocityForItem:item];
            
            if(fabs(inertialVelocity.y)<50){
                
                weakSelf.isScroll = NO;
                
            }
        };
        self.inertialBehavior = inertialBehavior;
        [self.dynamicAnimator addBehavior:inertialBehavior];
        
    }
    
    
    
    
}
#pragma mark -  内外部滚动视图的偏移量处理
- (void)transitionWithOffset:(CGFloat)offset{
    
    CGFloat outOffY = self.scrollview.contentOffset.y;//外部滚动视图的偏移量
    CGFloat subOffY = [self.controller scrollview].contentOffset.y; //子视图的偏移量
    CGFloat maxOffY = self.headHeight - self.ignoreTopSpeace + self.scrollview.contentInset.top;//headView悬浮的时候最大偏移量
    CGFloat maxSubOffY = [self.controller scrollview].maxOffsetY;
    
    //手指向上
    if(offset < 0){
        // *********优先判断子视图是否滚动到顶部
        //子视图未滚动到顶部
        if(subOffY > 0){
            
            CGFloat final = subOffY - offset; //滚动多处的部分
            //多余的部分大于0 说明子视图还是没有到达顶部
            if(final > 0){
                
                if(final <= maxSubOffY){
                    
                    subOffY = final;
                    [self  setSubScrollViewOffY:subOffY];
                }else{
                    
#pragma mark 上拉到到最大的时候开始bounce
                    //超过的部分做增量减少
                    
                    if(self.isTouch || self.decelerateBehavior){
                        
                        CGFloat bounceDelta = MAX(0, (self.maxBounceDistance - fabs(subOffY - maxSubOffY))/self.maxBounceDistance) * 0.5;
                        
                        subOffY  -= offset * bounceDelta;
                        [self  setSubScrollViewOffY:subOffY];
                        
                    }else{
                        
                        [self decelerateForScrollView:[self.controller scrollview] isTop:NO];
                    }
                    
                }
                
            }else {
                
                //多余的部分小于等于0 说明子视图刚好滚动到顶部或者超过顶部
                subOffY = 0;
                [self  setSubScrollViewOffY:subOffY];
                [self transitionWithOffset:-final];
                
            }
            
            
        }else {
            
            if(subOffY ==0){
                
                //********子视图已经滚动到顶部 滚动外部的
                //滚动到顶部
                if(outOffY < maxOffY){
                    CGFloat final = outOffY - offset - maxOffY;
                    if(final < 0){
                        outOffY -= offset;
                        [self setOutScrollViewOffY:outOffY];
                        
                    }else{
                        
                        outOffY = maxOffY;
                        [self setOutScrollViewOffY:outOffY];
                        [self transitionWithOffset:-final];
                    }
                    
                }else {
                    
                    subOffY -= offset;
                    [self  setSubScrollViewOffY:subOffY];
                    
                }
                
            }else{
                
                CGFloat final = subOffY - offset;
                
                if(final<0){
                    
                    subOffY = final;
                    [self setSubScrollViewOffY:subOffY];
                    
                }else{
                    
                    subOffY = 0;
                    [self setSubScrollViewOffY:subOffY];
                    [self transitionWithOffset:-final];
                    
                }
                
            }
            
        }
        
    }
    
    //手指向下
    if(offset > 0){
        
        if(subOffY > 0){
            
            CGFloat final = subOffY - offset;
            
            if(final>0){
                
                subOffY = final;
                [self  setSubScrollViewOffY:subOffY];
                
            }else{
                
                subOffY = 0;
                [self  setSubScrollViewOffY:subOffY];
                [self transitionWithOffset:-final];
                
            }
            
        }else {
            
            
            if(self.style == FFHomePageStyleSubRefresh){
                
                
                if(outOffY >0){
                    
                    CGFloat final = outOffY - offset;
                    
                    if(final>0 && final < maxOffY){
                        
                        outOffY -= offset;
                        [self setOutScrollViewOffY:outOffY];
                        
                    }else{
                        
                        
                        if(final > maxOffY){
                            
                            outOffY = maxOffY;
                            [self setOutScrollViewOffY:outOffY];
                            [self transitionWithOffset:final - maxOffY];
                            
                        }else if(final <0){
                            
                            outOffY = 0;
                            [self setOutScrollViewOffY:outOffY];
                            [self transitionWithOffset:-final];
                            
                        }else{
                            
                            subOffY -= offset;
                            [self setSubScrollViewOffY:subOffY];
                            
                        }
                    }
                    
                }else{
                    
                    
#pragma mark 内部下拉到到最大的时候开始bounce
                    
                    if(self.isTouch || self.decelerateBehavior){
                        
                        CGFloat bounceDelta = MAX(0, (self.maxBounceDistance - fabs(subOffY))/self.maxBounceDistance) * 0.5;
                        
                        subOffY  -= offset * bounceDelta;
                        [self setSubScrollViewOffY:subOffY];
                    }else{
                        
                        
                        [self decelerateForScrollView:[self.controller scrollview] isTop:YES];
                    }
                }
                
            }else{
                
                if(outOffY >= -[self.controller scrollview].contentInset.top){
                    outOffY  -= offset;
                    [self  setOutScrollViewOffY:outOffY];
                }else{
                    
#pragma mark 外部下拉到到最大的时候开始bounce
                    
                    if(self.isTouch || self.decelerateBehavior){
                        
                        CGFloat bounceDelta = MAX(0, (self.maxBounceDistance - fabs(outOffY))/self.maxBounceDistance) * 0.5;
                        outOffY  -= offset * bounceDelta;
                        [self  setOutScrollViewOffY:outOffY];
                        
                    }else{
                        
                        [self decelerateForScrollView:self.scrollview isTop:YES];
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
}

#pragma mark -  减速

- (void)decelerateForScrollView:(UIScrollView *)scrollView isTop:(BOOL)isTop{
    
    if(self.decelerateBehavior)return;
    
    CGPoint inertialVelocity = [self.inertialBehavior linearVelocityForItem:[self.inertialBehavior.items lastObject]];//惯性结束时的速度
    [self.dynamicAnimator removeBehavior:self.inertialBehavior];
    self.inertialBehavior = nil;
    
    
    FFDynamicItem *item = [[FFDynamicItem alloc] init];
    item.center = CGPointZero;
    __block CGFloat lastCenterY = 0;
    UIDynamicItemBehavior *decelerateBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
    [decelerateBehavior addLinearVelocity:CGPointMake(0, inertialVelocity.y) forItem:item];
    decelerateBehavior.resistance = 20;
    __weak typeof(self) weakSelf = self;
    decelerateBehavior.action = ^{
        
        CGPoint decelerateVelocity = [weakSelf.decelerateBehavior linearVelocityForItem:item];
        
        if(fabs(decelerateVelocity.y) < 100){
            
            [weakSelf.dynamicAnimator removeBehavior:weakSelf.decelerateBehavior];
            weakSelf.decelerateBehavior = nil;
            
            [weakSelf bounceForScrollView:scrollView isTop:isTop];
            
        }else{
            
            [weakSelf transitionWithOffset:lastCenterY - item.center.y];
            lastCenterY = item.center.y;
        }
        
    };
    self.decelerateBehavior = decelerateBehavior;
    [self.dynamicAnimator addBehavior:decelerateBehavior];
    
}

#pragma mark -  回弹

- (void)bounceForScrollView:(UIScrollView *)scrollView isTop:(BOOL)isTop{
    
    
    //下拉减速结束的时候 最终位置没有到达零界点 不执行回弹
    if(isTop && !scrollView.isReachTop) return;
    //上拉减速结束的时候 最终位置没有到达零界点 不执行回弹
    if(!isTop && !scrollView.isReachBottom) return;
    
    
    if(self.bounceBehavior) return;
    
    FFDynamicItem *item = [[FFDynamicItem alloc] init];
    item.center = scrollView.contentOffset;
    CGFloat targetOffY = isTop? -scrollView.contentInset.top:scrollView.maxOffsetY ;
    
    UIAttachmentBehavior *bounceBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:CGPointMake(0, targetOffY)];
    bounceBehavior.length = 0;
    bounceBehavior.damping = 1;
    bounceBehavior.frequency = 2;
    __weak typeof(bounceBehavior) weakBounceBehavior = bounceBehavior;
    __weak typeof(self) weakSelf = self;
    bounceBehavior.action = ^{
        scrollView.contentOffset = CGPointMake(0, item.center.y);
        if (fabs(scrollView.contentOffset.y - targetOffY) < FLT_EPSILON) {
            [weakSelf.dynamicAnimator removeBehavior:weakBounceBehavior];
            weakSelf.bounceBehavior = nil;
            weakSelf.isScroll = NO;
            
        }
        
        if(weakSelf.scrollview == scrollView){
            
            
            if(weakSelf.style == FFHomePageStyleHeadEnlarge){
                
                CGRect frame = CGRectMake(0, 0, CGRectGetWidth(weakSelf.headViewController.view.bounds), weakSelf.headHeight);
                
                
                if(scrollView.contentOffset.y < 0){
                    frame = CGRectMake(0, roundf(scrollView.contentOffset.y), CGRectGetWidth(frame), weakSelf.headHeight - roundf(scrollView.contentOffset.y));
                }
                
                if(!CGRectEqualToRect(weakSelf.headViewController.view.frame, frame))weakSelf.headViewController.view.frame = frame;
            }
            
            return ;
        }
        
        if([weakSelf.controller scrollview] == scrollView){
            
            if([self.controller respondsToSelector:@selector(conentOffsetDidChanged:)]){
                
                [self.controller conentOffsetDidChanged:[self.controller scrollview].contentOffset];
            }
            
            return;
            
        }
        
        
        
        
    };
    self.bounceBehavior = bounceBehavior;
    [self.dynamicAnimator addBehavior:bounceBehavior];
    
}
- (void)setOutScrollViewOffY:(CGFloat)offY{
    self.scrollview.contentOffset = CGPointMake(self.scrollview.contentOffset.x, offY);
    
    if(self.style == FFHomePageStyleHeadEnlarge){
        
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.headViewController.view.bounds), self.headHeight);
        
        if(offY < 0){
            frame = CGRectMake(0, roundf(offY), CGRectGetWidth(frame), self.headHeight - roundf(offY));
        }
        self.headViewController.view.frame = frame;
    }
}

- (void)setSubScrollViewOffY:(CGFloat)offY{
    [self.controller scrollview].contentOffset =  CGPointMake([self.controller scrollview].contentOffset.x, offY);
    
    
    if([self.controller respondsToSelector:@selector(conentOffsetDidChanged:)]){
        
        [self.controller conentOffsetDidChanged:[self.controller scrollview].contentOffset];
    }
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if(!CGRectEqualToRect(self.scrollview.frame, self.view.bounds) || self.isUpdateFrame){
        
#warning 有可能本页面有tabbar 下一个页面没有引起页面错位
        if(fabs(CGRectGetHeight(self.scrollview.frame) - CGRectGetHeight(self.view.frame)) == [UIApplication sharedApplication].statusBarFrame.size.height + 44) return;
        
        self.scrollview.frame = self.view.bounds;
        
        self.headViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollview.frame), self.headHeight);
        
        self.tabViewController.view.frame = CGRectMake(0, self.headHeight, CGRectGetWidth(self.scrollview.frame), self.tabHeight);
        
        self.pageViewController.view.frame = CGRectMake(0, self.headHeight + self.tabHeight, CGRectGetWidth(self.scrollview.frame), CGRectGetHeight(self.scrollview.frame) - self.tabHeight - self.ignoreTopSpeace);
        
        self.scrollview.contentSize = CGSizeMake(CGRectGetWidth(self.scrollview.frame), CGRectGetHeight(self.pageViewController.view.frame) + self.tabHeight +self.headHeight);
        
        
        self.maxBounceDistance =  CGRectGetHeight(self.view.bounds) * .66;
    }
    
}




#pragma mark - getter

@synthesize scrollview = _scrollview;
-(UIScrollView *)scrollview{
    
    if(!_scrollview){
        
        _scrollview = [[UIScrollView alloc]init];
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator =NO;
        _scrollview.backgroundColor = UIColor.clearColor;
        _scrollview.opaque = YES;
        _scrollview.scrollEnabled = NO;
        if (@available(iOS 11.0, *)) {
            _scrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _scrollview;
}

- (UIDynamicAnimator *)dynamicAnimator{
    
    if(!_dynamicAnimator){
        _dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    }
    
    return _dynamicAnimator;
}

@synthesize isScroll = _isScroll;
- (void)setIsScroll:(BOOL)isScroll{
    
    _isScroll = isScroll;
    
    self.pageViewController.view.userInteractionEnabled = !isScroll;
    self.headViewController.view.userInteractionEnabled = !isScroll;
    self.scrollview.userInteractionEnabled = !isScroll;
    self.tabViewController.view.userInteractionEnabled = !isScroll;
    [self.controller scrollview].userInteractionEnabled = !isScroll;
    
    [self.pageViewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        obj.userInteractionEnabled = !isScroll;
    }];
    
}

@synthesize isTouch = _isTouch;
- (void)setIsTouch:(BOOL)isTouch{
    
    _isTouch = isTouch;
    
    self.scrollview.isTouch = isTouch;
    [self.controller scrollview].isTouch = isTouch;
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    
    if(self.scrollview.isFFRefreshing || self.controller.scrollview.isFFRefreshing) return NO;
    
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
    return fabs(velocity.y) > fabs(velocity.x);
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.dynamicAnimator removeAllBehaviors];
    self.isScroll = NO;
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


@end
