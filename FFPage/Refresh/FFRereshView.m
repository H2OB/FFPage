//
//  FFRereshView.m
//  FFPage
//
//  Created by North on 2019/8/14.
//  Copyright © 2019 North. All rights reserved.
//

#import "FFRereshView.h"
#import "FFPage.h"

static NSString *  contentOffset = @"contentOffset";
static NSString *  contentSize = @"contentSize";
static NSString *  PanState = @"state";
static NSString *  superBounds = @"bounds";

@interface FFRereshView ()

/**
 回调块
 */
@property (copy ,nonatomic) FFRefreshBlock refreshBlock;

/**
 对象
 */
@property (nonatomic) id target;

/**
 方法
 */
@property (nonatomic) SEL action;


/**
 物理动画容器
 */
@property(nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

/**
 回弹行为
 */
@property(nonatomic, weak)   UIAttachmentBehavior *bounceBehavior;

@end

@implementation FFRereshView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpSubView];
    }
    
    return self;
}

+ (instancetype)initWithRefreshBlock:(FFRefreshBlock)block{
    
    FFRereshView * view = [[self alloc] init];
    view.refreshBlock = block;
    return view;
    
}

+ (instancetype)initWithTarget:(id)target action:(SEL)action {
    
    FFRereshView * view = [[self alloc] init];
    view.target = target;
    view.action = action;
    return view;
}


- (CGFloat)refreshHeight{

    return 50;
}

- (void)setUpSubView{}

- (void)setUpKVO{
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    
    [self.scrollView addObserver:self forKeyPath:contentOffset options:options context:nil];
    
    //监听滚动视图大小改变 以及可能的设备方向改变
    [self.scrollView addObserver:self forKeyPath:superBounds options:options context:nil];
    
    if (self.isFooter) {
        
        [self.scrollView addObserver:self forKeyPath:contentSize options:options context:nil];
    }
   
}

- (void)removeKVO{
    
    [self.scrollView removeObserver:self forKeyPath:contentOffset];
    
    [self.scrollView removeObserver:self forKeyPath:superBounds];
    
    if (self.isFooter) [self.scrollView removeObserver:self forKeyPath:contentSize];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
        if ([keyPath isEqualToString:contentOffset]) {
    
            [self calcuStatusAndProgress];
    
        } else if ([keyPath isEqualToString:contentSize]) {
    
            [self updateFrame];
            
        } else if ([keyPath isEqualToString:superBounds]) {
        
                [self updateFrame];
        }
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview || ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    if (self.scrollView) [self removeKVO];
    
    self.scrollView = (UIScrollView *)newSuperview;
    
    self.dynamicAnimator =[[UIDynamicAnimator alloc]initWithReferenceView:self];

    [self updateTouchStatus];
    
    [self setUpKVO];
    
    [self updateFrame];
    
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    
    [super willMoveToWindow:newWindow];
    
    [self updateFrame];
    
}

- (void)updateTouchStatus{
    
    __weak typeof(self) weakself = self;
    
    [self.scrollView addTounchBlock:^(BOOL isTouch) {
         [weakself touchEndAction];
    }];

}

- (void)touchEndAction{
    
    if(self.scrollView.isTouch )return;
    
    if(self.status == FFRereshStatusWillBeginRefresh){
        
        [self beginRefresh];
    }
    
    if(self.status == FFRereshStatusWillEndRefresh){
        
        [self endRefresh];
    }
    
}

- (void)calcuStatusAndProgress{
    
    if (!self.scrollView.isTouch) return;
    if (self.status == FFRereshStatusRereshing) return;
    
    CGFloat offY = self.scrollView.contentOffset.y;
    
    //头部
    if (!self.isFooter && offY < 0) {
        
        CGFloat scale = fabs(offY)/[self refreshHeight];
        if (scale > 1) scale = 1;
        self.percent = scale;

    } else if (self.isFooter && offY > self.scrollView.maxOffsetY) {
        
        CGFloat scale = (offY - MAX(0, self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds)))/[self refreshHeight];
        if (scale > 1) scale = 1;
        self.percent = scale;
        
    }
    

    if(self.percent <= 0 && self.status != FFRereshStatusNormal){

        self.status = FFRereshStatusNormal;
        return;
    }
    
   
    if (self.percent > 0 &&
       self.percent < 1 &&
       self.status  == FFRereshStatusNormal) {
           
        self.status = FFRereshStatusPulling;
        
        return;
    }
    
    if (self.percent >= 1 &&
       (self.status == FFRereshStatusPulling || self.status == FFRereshStatusWillEndRefresh)) {
        self.status = FFRereshStatusWillBeginRefresh;
        return;
    }
    
    
    if (self.percent > 0 &&
        self.percent < 1 &&
        self.status  == FFRereshStatusWillBeginRefresh
          ) {
            self.status = FFRereshStatusWillEndRefresh;
            return;
        }
    
    
    return;
    
}

@synthesize percent = _percent;
- (void)setPercent:(CGFloat)percent{
    
    if (_percent != percent) {
        
        _percent = percent;
        
        [self percentUpdated];
    }
    
}
@synthesize status = _status;
- (void)setStatus:(FFRereshStatus)status{
    
    if (self.status != status) {
        
        _status = status;
        
        UIEdgeInsets inset = self.scrollView.contentInset;
        
        //在将要刷新的时候 设置
        if (_status == FFRereshStatusWillBeginRefresh) {

            if (!self.isFooter) inset.top = [self refreshHeight];
            else inset.bottom = [self refreshHeight];

        }

        if (_status == FFRereshStatusNormal) {
            
            if (!self.isFooter) inset.top = 0;
            else inset.bottom = 0;
            
        }
        
        self.scrollView.contentInset = inset;
        
        
        [self statusUpdated];
    }
}

- (void)statusUpdated{
    
    
    
    
}

- (void)percentUpdated{
    
    
}

- (void)updateFrame{
    
    CGFloat height = [self refreshHeight];
    
    if (self.isFooter) {
        
        self.frame = CGRectMake(0,MAX(self.scrollView.contentSize.height, CGRectGetHeight(self.scrollView.bounds)), CGRectGetWidth(self.scrollView.bounds), height);
        return;
    }
    
    self.frame = CGRectMake(0, - height, CGRectGetWidth(self.scrollView.bounds), height);
}


- (void)beginRefresh{
    
    if (self.status == FFRereshStatusRereshing) return;
    
    //代码调用刷新
    if (self.status == FFRereshStatusNormal) {
    
        self.status  = FFRereshStatusWillBeginRefresh;
        [self beginRefresh];
        return;
    }
    
    //交互中不允许
    if (self.scrollView.isTouch ) return;
    
    self.status = FFRereshStatusRereshing;
    if (self.refreshBlock)self.refreshBlock();
    if (self.target && self.action) [self.target performSelectorOnMainThread:self.action withObject:nil waitUntilDone:NO];
    
    //只有顶部刷新的时候才会强制滚动
    if(self.isFooter)return;
    self.scrollView.isFFRefreshing = YES;
   
    [[NSNotificationCenter defaultCenter] postNotificationName:FFPageBeginRefreshNotice object:self userInfo:nil];
    
    CGFloat targetOffY =  -self.refreshHeight;
    
    //删除所有物理行为
    
    [self.dynamicAnimator removeAllBehaviors];
    self.bounceBehavior = nil;

    // 增加一个附着的行为
    
    FFDynamicItem *item = [[FFDynamicItem alloc] init];
    item.center = self.scrollView.contentOffset;
    

    UIAttachmentBehavior *bounceBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:CGPointMake(0, targetOffY)];
    bounceBehavior.length = 0;
    bounceBehavior.damping = 1;
    bounceBehavior.frequency = 4;
    
    __weak typeof(self) weakSelf = self;
    bounceBehavior.action = ^{
        weakSelf.scrollView.contentOffset = CGPointMake(0, item.center.y);
        if (fabs(weakSelf.scrollView.contentOffset.y - targetOffY) < FLT_EPSILON) {
            [weakSelf.dynamicAnimator removeAllBehaviors];
            weakSelf.bounceBehavior = nil;
            weakSelf.scrollView.isFFRefreshing = NO;
           
        }
    };
    
    self.bounceBehavior = bounceBehavior;
    [self.dynamicAnimator addBehavior:bounceBehavior];
    
}

- (void)endRefresh{
    
    if (self.status == FFRereshStatusNormal) return;
    
    if (self.status == FFRereshStatusRereshing) {
        self.status = FFRereshStatusWillEndRefresh;
        [self endRefresh];
        return;
    }
    
    //交互中 不允许执行结束动画
    
    if (self.scrollView.isTouch) return;
    
    //结束的目标点
    CGFloat maxOffY = MAX(0, self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds));
    
    //底部结束刷新时，控件被移出屏幕
    if(self.isFooter && self.scrollView.contentOffset.y < maxOffY){
        self.status = FFRereshStatusNormal;
        return;
    }
    
    
    self.scrollView.isFFRefreshing = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName:FFPageEndRefreshNotice object:self userInfo:nil];
    
    CGFloat targetOffY = 0;
    if(self.isFooter)targetOffY =maxOffY;
    
    //删除所有物理行为
    
    [self.dynamicAnimator removeAllBehaviors];
    self.bounceBehavior = nil;

    // 增加一个附着的行为
    
    FFDynamicItem *item = [[FFDynamicItem alloc] init];
    item.center = self.scrollView.contentOffset;
    
    
    
    UIAttachmentBehavior *bounceBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:CGPointMake(0, targetOffY)];
    bounceBehavior.length = 0;
    bounceBehavior.damping = 1;
    bounceBehavior.frequency = 4;
    
    __weak typeof(self) weakSelf = self;
    bounceBehavior.action = ^{
        weakSelf.scrollView.contentOffset = CGPointMake(0, item.center.y);
        if (fabs(weakSelf.scrollView.contentOffset.y - targetOffY) < FLT_EPSILON) {
            [weakSelf.dynamicAnimator removeAllBehaviors];
            weakSelf.bounceBehavior = nil;
            weakSelf.scrollView.isFFRefreshing = NO;
            weakSelf.status = FFRereshStatusNormal;
        }
    };
    
    self.bounceBehavior = bounceBehavior;
    [self.dynamicAnimator addBehavior:bounceBehavior];
    
}


- (void)dealloc{
    
    [self removeKVO];
}


@end
