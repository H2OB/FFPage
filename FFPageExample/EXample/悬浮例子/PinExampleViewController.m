//
//  PinExampleViewController.m
//  FFPageExample
//
//  Created by North on 2019/10/21.
//  Copyright © 2019 North. All rights reserved.
//

#import "PinExampleViewController.h"
#import "FFPage.h"
#import "HeadViewController.h"
#import "MenuViewController.h"
#import "RefreshView.h"


NS_INLINE NSUInteger randomBetween(NSUInteger begin,  NSUInteger end){
    
    NSUInteger value = arc4random() % end + begin;
    if(value > end) value -= begin;
    return value;
    
}


@interface PinExampleViewController ()<FFPageViewControllerDelegate,SPPageMenuDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl  *segmentdControl;
@property (retain, nonatomic) FFAdapterViewController   *adapterViewController;


@property (retain, nonatomic) HeadViewController     * headViewController;
@property (retain, nonatomic) MenuViewController     * menuViewController;
@property (retain, nonatomic) FFPageViewController       *pageViewController;




@end

@implementation PinExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
}

- (void)setUpView{
    
    self.headViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeadViewController"];
    
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    
    self.pageViewController = [[FFPageViewController alloc]init];
    self.pageViewController.delegate = self;
    self.pageViewController.prePages = 2;
    self.pageViewController.maxPages = 10;
    
    
    // 初始化
    self.adapterViewController = [[FFAdapterViewController alloc]init];
    // 设置样式
    self.adapterViewController.style = self.segmentdControl.selectedSegmentIndex;
    // 设置头部视图高度
    self.adapterViewController.headHeight = 300;
    // 设置菜单/分类控制器视图高度
    self.adapterViewController.menuHeight = 50;
    
    // 设置头部控制器
    self.adapterViewController.headViewController = self.headViewController;
    // 设置菜单/分类控制器
    self.adapterViewController.menuViewController = self.menuViewController;
    // 设置底部分页控制器
    self.adapterViewController.pageViewController = self.pageViewController;
    
    
    [self addChildViewController:self.adapterViewController];
    [self.contentView addSubview:self.adapterViewController.view];
    [self.adapterViewController didMoveToParentViewController:self];
    
    self.menuViewController.pageMenu.delegate = self;
    self.menuViewController.pageMenu.bridgeScrollView = self.pageViewController.scrollview;

}
- (IBAction)valueChangeAction:(UISegmentedControl *)sender {
    
    self.adapterViewController.style = sender.selectedSegmentIndex;
    
    if(sender.selectedSegmentIndex == 1){
        
        self.adapterViewController.scrollview.ff_header = [RefreshView initWithRefreshBlock:^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.adapterViewController.scrollview.ff_header endRefresh];
            });
            
        }];
        
    } else {
        
        self.adapterViewController.scrollview.ff_header = nil;
    }
    
    
}
- (IBAction)headHeightAction:(id)sender {
    
    
    self.adapterViewController.headHeight = randomBetween(100,500);
    [self.adapterViewController updateHeightWithAnimation:YES completion:nil];
    
}

#pragma mark - SPPageMenuDelegate

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index{
    
    [self.pageViewController scrollToPage:index animation:YES];
}


#pragma mark - FFPageViewControllerDelegate


- (NSUInteger)totalPagesOfpageViewController:(FFPageViewController *)pageViewConteoller{
    
    return self.menuViewController.pageMenu.numberOfItems;
}

- (UIViewController *)pageViewController:(FFPageViewController *)pageViewConteoller controllerForPage:(NSInteger)page{
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PageSubViewController"];
    
    [controller setValue:@(page).stringValue forKey:@"identifier"];
    
    return  controller;
}

- (void)pageViewController:(FFPageViewController *)pageViewController currentPageChanged:(NSInteger)currentPage{
    
    [self.adapterViewController updateCurrentController:(UIViewController<FFPageProtocol> *)self.pageViewController.currentController];
    
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.adapterViewController.view.frame = self.contentView.bounds;
    
    
}

@end
