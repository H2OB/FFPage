//
//  HomePageExampleViewController.m
//  FFPageExample
//
//  Created by North on 2019/10/21.
//  Copyright © 2019 North. All rights reserved.
//

#import "HomePageExampleViewController.h"
#import "FFPage.h"
#import "CategroyViewController.h"
#import "RefreshView.h"


NS_INLINE NSUInteger randomBetween(NSUInteger begin , NSUInteger end){
    
    NSUInteger value = arc4random() % end + begin;
    if(value > end) value -= begin;
    return value;
    
}


@interface HomePageExampleViewController ()<FFPageViewControllerDelegate,SPPageMenuDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl  *segmentdControl;
@property (retain, nonatomic) FFAdapterViewController   *adapterViewController;
@property (retain ,nonatomic) CategroyViewController     * categroyViewController;
@property (retain, nonatomic) FFPageViewController       *pageViewController;




@end

@implementation HomePageExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
}

- (void)setUpView{
    
    self.categroyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategroyViewController"];
    
    self.pageViewController = [[FFPageViewController alloc]init];
    self.pageViewController.delegate = self;
    self.pageViewController.prePages = 2;
    self.pageViewController.maxPages = 10;
    
    
    
    self.adapterViewController = [[FFAdapterViewController alloc]init];
    self.adapterViewController.style = self.segmentdControl.selectedSegmentIndex;;
    self.adapterViewController.categroyHeight = 50;
    self.adapterViewController.headHeight = 300;
    self.adapterViewController.headViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeadViewController"];
    self.adapterViewController.categroyViewController = self.categroyViewController;
    self.adapterViewController.pageViewController = self.pageViewController;
    
    
    [self addChildViewController:self.adapterViewController];
    [self.contentView addSubview:self.adapterViewController.view];
    [self.adapterViewController didMoveToParentViewController:self];
    
    
    self.categroyViewController.pageMenu.delegate = self;
    self.categroyViewController.pageMenu.bridgeScrollView = self.pageViewController.scrollview;
    
    
    
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
    [self.adapterViewController reloadHeightWithAnimation:YES completion:nil];
    
}

#pragma mark - SPPageMenuDelegate

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index{
    
    [self.pageViewController scrollToPage:index animation:YES];
}


#pragma mark - FFPageViewControllerDelegate


- (NSUInteger)totalPagesOfpageViewController:(FFPageViewController *)pageViewConteoller{
    
    return self.categroyViewController.pageMenu.numberOfItems;
}

- (UIViewController *)pageViewController:(FFPageViewController *)pageViewConteoller controllerForPage:(NSInteger)page{
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PageSubViewController"];
    
    [controller setValue:@(page).stringValue forKey:@"identifier"];
    
    return  controller;
}

- (void)pageViewController:(FFPageViewController *)pageViewController currentPageChanged:(NSInteger)currentPage{
    
    [self.adapterViewController updateCurrentController:self.pageViewController.currentController];
    
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.adapterViewController.view.frame = self.contentView.bounds;
    
    
}

@end
