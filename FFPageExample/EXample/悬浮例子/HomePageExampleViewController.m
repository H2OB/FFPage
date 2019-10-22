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
@property (retain, nonatomic) FFHomePageViewController   *homePageViewController;
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
    
    
    
    self.homePageViewController = [[FFHomePageViewController alloc]init];
    self.homePageViewController.style = self.segmentdControl.selectedSegmentIndex;;
    self.homePageViewController.categroyHeight = 50;
    self.homePageViewController.headHeight = 300;
    self.homePageViewController.headViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeadViewController"];
    self.homePageViewController.categroyViewController = self.categroyViewController;
    self.homePageViewController.pageViewController = self.pageViewController;
    
    
    [self addChildViewController:self.homePageViewController];
    [self.contentView addSubview:self.homePageViewController.view];
    [self.homePageViewController didMoveToParentViewController:self];
    
    
    self.categroyViewController.pageMenu.delegate = self;
    self.categroyViewController.pageMenu.bridgeScrollView = self.pageViewController.scrollview;
    
    
    
}
- (IBAction)valueChangeAction:(UISegmentedControl *)sender {
    
    self.homePageViewController.style = sender.selectedSegmentIndex;
    
    if(sender.selectedSegmentIndex == 1){
        
        self.homePageViewController.scrollview.header = [RefreshView initWithRefreshBlock:^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.homePageViewController.scrollview.header endRefresh];
            });
            
        }];
        
    } else {
        
        self.homePageViewController.scrollview.header = nil;
    }
    
    
}
- (IBAction)headHeightAction:(id)sender {
    
    
    self.homePageViewController.headHeight = randomBetween(100,500);
    [self.homePageViewController reloadHeightWithAnimation:YES completion:nil];
    
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
    
    [self.homePageViewController updateCurrentController:self.pageViewController.currentController];
    
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.homePageViewController.view.frame = self.contentView.bounds;
    
    
}

@end
