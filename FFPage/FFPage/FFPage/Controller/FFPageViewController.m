//
//  FFPageViewController.m
//  FFPage
//
//  Created by North on 2019/8/5.
//  Copyright © 2019 North. All rights reserved.
//

#import "FFPageViewController.h"


NS_INLINE CGRect frameForPage(FFPageViewController *controller ,NSInteger page){
    
    CGFloat x = controller.scrollDirection != ScrollDirectionVertical?page * CGRectGetWidth(controller.scrollview.frame):0;
    CGFloat y = controller.scrollDirection != ScrollDirectionVertical?0:page * CGRectGetHeight(controller.scrollview.frame);
    
    return CGRectMake(x, y,CGRectGetWidth(controller.scrollview.frame), CGRectGetHeight(controller.scrollview.frame));
    
}

NS_INLINE NSInteger pageFormOffset(UIScrollView *scrollView){
    
    CGPoint point = scrollView.contentOffset;
    
    double scale = scrollView.contentSize.width > CGRectGetWidth(scrollView.bounds)? point.x/CGRectGetWidth(scrollView.bounds):point.y/CGRectGetHeight(scrollView.bounds);
    NSInteger page = roundl(scale); //四舍五入 取出在屏幕中最多显示区域的页码
    
    return page;
}

@interface FFPageViewController ()<UIScrollViewDelegate>

/**
 缓存
 */
@property (strong ,nonatomic) NSMapTable * cacheMaps;

/**
 存储页数的数组
 用于简单实现LRU算法
 */
@property (strong ,nonatomic) NSMutableArray * pagesArray;

/**
 用户开始拖拽钱的便宜量
 */
@property (assign ,nonatomic) CGPoint startOffset;



/**
 runloop观察者
 */
@property CFRunLoopObserverRef observer;


/**
 计时器 保证runloop不退出
 */
@property (retain ,nonatomic) NSTimer * timer ;



@end

@implementation FFPageViewController
@synthesize currentPage = _currentPage;
@synthesize scrollview = _scrollview;
@synthesize currentController = _currentController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    
    [self setUpRunloop];
}

- (void)setUpView{
    
    [self.view addSubview:self.scrollview];
}


#pragma mark - Runloop

- (void)setUpRunloop{
    
    [self removeRunloop];
    
    if(self.prePages <= 0 && self.maxPages <= 0) return;
    
    __weak typeof(self) weakself=self;
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler
    (kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true,NSIntegerMax - 999, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {

        [weakself preControllers];

    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
    
    self.observer = observer;
    
    NSTimer * timer = [NSTimer timerWithTimeInterval:.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    }];

    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    self.timer = timer;
    
}

- (void)removeRunloop{
    
    if(self.timer){
        
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observer, kCFRunLoopDefaultMode);
        CFRelease(self.observer);
        
        [self.timer invalidate];
        self.timer = nil;
        
    }
}

- (void)preControllers{
    
    if (![self isRespondsDelete]) return;
    
    if(!self.currentController) return;
    
    NSInteger page = self.currentPage - self.prePages;
    page = MAX(page, 0);
    NSInteger end = MIN([self totalPages], self.currentPage + self.prePages + 1);
   
    for (NSInteger index = page; index < end; index ++) {
        
        if(![self.pagesArray containsObject:@(index)]){
            [self addConrolerForPage:@(index)];
            return;
        }
    }
    
    BOOL maxPageSure = self.maxPages >= self.prePages * 2 + 1;
    maxPageSure = maxPageSure && self.maxPages < self.pagesArray.count;
    
    //如果缓存数量过多 释放最后一个控制器
    if(maxPageSure){
        [self removeControllerForPage:self.pagesArray.lastObject];
        return;
    }

}

#pragma mark - 外部调用

- (void)reloadData{
    
    //检查代理
    NSAssert([self isRespondsDelete], @"请实现代理FFPageViewControllerDelegate");
    
    [self.pagesArray enumerateObjectsUsingBlock:^(NSNumber * page, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeControllerForPage:page];
    }];
    
    [self.pagesArray removeAllObjects];
    
    //如果当前页 超过最大页数 置为0
    if ([self totalPages] < self.currentPage) {
        
        _currentPage = 0;
    }
    
    [self updateDisplay];
    
    
}


- (void)scrollToPage:(NSInteger)page animation:(BOOL)animation{
    
    _currentPage = page;
    
    //没有实现代理
    if (![self isRespondsDelete]) return;
    
    //页码不正确
    if (page < 0 || [self totalPages] <= page ) return;
    
    //还没调整完位置
    if (!CGRectEqualToRect(self.view.bounds, self.scrollview.frame))return;
    
    [self.scrollview setContentOffset:frameForPage(self, page).origin animated:animation];
    
    [self addConrolerForPage:@(page)];
    
    if(!animation){
        
        [self updateAppearance:page];
    }
}

#pragma mark - 更新控制器/视图

- (void)updateDisplay{
    
    //调整 scrollview的contentSize
    [self updateContentSize];
    
    //调整位置
    [self addConrolerForPage:@(_currentPage)];
    
    //调整滚动量
    self.scrollview.contentOffset = frameForPage(self, self.currentPage).origin;
    
    [self updateAppearance:_currentPage];
    
}

/**
 更新滚动区域大小
 */
- (void)updateContentSize{
    
    NSInteger maxPage = [self totalPages] - 1;
    CGRect maxPageFrame = frameForPage(self, maxPage);
    self.scrollview.contentSize = CGSizeMake(CGRectGetMaxX(maxPageFrame), CGRectGetMaxY(maxPageFrame));
    
}

/**
 添加子控制器以及视图

 @param page 页码
 */
- (void)addConrolerForPage:(NSNumber *)page{
    
    
    NSInteger intPage = [page integerValue];
    
    //越界 直接返回
    if (intPage < 0 || intPage >= [self totalPages]) return;
    
    //已经添加
    if ([self.pagesArray containsObject:page]){
        
        UIViewController *controller = [self.cacheMaps objectForKey:page];
        //可能涉及到调整屏幕旋转 需要调整frame
        controller.view.frame = frameForPage(self, intPage);
        [self.scrollview bringSubviewToFront:controller.view];
        [self.pagesArray removeObject:page];
        [self.pagesArray insertObject:page atIndex:0];
        
        return;
    }
    
    UIViewController * controller = [self.delegate pageViewController:self controllerForPage:intPage];
    controller.view.frame = frameForPage(self, intPage);
    
    [self addChildViewController:controller];
    [self.scrollview addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    [self.cacheMaps setObject:controller forKey:page];
    [self.pagesArray insertObject:page atIndex:0];
    
}

/**
 删除子控制器以及视图 并释放内存

 @param page 页码
 */
- (void)removeControllerForPage:(NSNumber *)page{
    
    if (![self.pagesArray containsObject:page]) return;
    [self.pagesArray removeObject:page];
    
    UIViewController *controller = [self.cacheMaps objectForKey:page];
    
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    controller = nil;
    
    [self.cacheMaps setObject:controller forKey:page];
    
}

/**
 是否实现代理
 
 @return YES 代表实现
 */
- (BOOL)isRespondsDelete{
    
    return self.delegate && [self.delegate respondsToSelector:@selector(totalPagesOfpageViewController:)] && [self.delegate respondsToSelector:@selector(pageViewController:controllerForPage:)];
}


/**
 获取总页数
 
 @return 总页数
 */
- (NSInteger)totalPages{
    
    if(![self isRespondsDelete]) return 0;
    
    return [self.delegate totalPagesOfpageViewController:self];
}



- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if (!CGRectEqualToRect(self.view.bounds, self.scrollview.frame)){
        
        self.scrollview.frame = self.view.bounds;
        
        if (![self isRespondsDelete]) return;
        
        [self updateDisplay];
        
    }
    
}

#pragma mark - UIScrollViewDelegate

//用户开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (!scrollView.isDecelerating) self.startOffset = scrollView.contentOffset;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //手指触摸时才允许添加视图 防止滚动距离过大 全部加载到内存中 引起CPU内存暴增
    if (!scrollView.isDragging) return;

    NSInteger page = pageFormOffset(scrollView);
    
    //添加下一页控制器
    NSInteger nextPage = page;
    
    if (scrollView.contentOffset.x > self.startOffset.x || scrollView.contentOffset.y > self.startOffset.y)  nextPage ++ ;
    else if (scrollView.contentOffset.x < self.startOffset.x || scrollView.contentOffset.y < self.startOffset.y) nextPage --;
    
    [self addConrolerForPage:@(nextPage)];
    
}

//结束减速 用户触摸滚动结束后调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger page = pageFormOffset(scrollView);
    [self updateAppearance:page];
}
//结束动画 非用户触摸滚动结束后调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    NSInteger page = pageFormOffset(scrollView);
    [self updateAppearance:page];
    
}

#pragma mark - 子控制器生命周期

- (void)updateAppearance:(NSInteger)page{
    
    UIViewController * controller = [self.cacheMaps objectForKey:@(page)];
    
    if(controller != _currentController){
        
        if(_currentController)[_currentController beginAppearanceTransition:NO animated:YES];
        [controller beginAppearanceTransition:YES animated:YES];
        if(_currentController)[_currentController endAppearanceTransition];
        [controller endAppearanceTransition];
        
    
        _currentPage = page;
        _currentController = controller;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:currentPageChanged:)]){
            [self.delegate pageViewController:self currentPageChanged:_currentPage];
        }
        
        
    }
}


// 自控制器生命周期不跟随父类
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}


#pragma mark - getter 懒加载

- (UIScrollView *)scrollview{
    
    if (!_scrollview){
        
        _scrollview = [UIScrollView new];
        _scrollview.pagingEnabled = YES;
        _scrollview.delegate = self;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator =NO;

        if (@available(iOS 11.0, *)) {
            _scrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _scrollview;
}

- (NSMapTable *)cacheMaps{
    
    if (!_cacheMaps) _cacheMaps = [NSMapTable strongToWeakObjectsMapTable];
    return _cacheMaps;
}

- (NSMutableArray *)pagesArray{
    
    if (!_pagesArray) _pagesArray = @[].mutableCopy;
    return _pagesArray;
}

- (NSInteger)currentPage{
    
    return _currentPage;
}

#pragma mark 生命周期

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.currentController beginAppearanceTransition:YES animated:YES];
    
    if(!self.timer)[self setUpRunloop];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.currentController endAppearanceTransition];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.currentController beginAppearanceTransition:NO animated:YES];
    
    [self removeRunloop];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.currentController endAppearanceTransition];
}


- (void)dealloc{
    
    
    
    
}


@end
