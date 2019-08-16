//
//  HomePageViewController.m
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#import "HomePageViewController.h"
#import "TabViewController.h"
#import "FFPage.h"
#import "RefreshView.h"

@interface HomePageViewController ()<FFPageViewControllerDelegate,SPPageMenuDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentdControl;

@property (retain, nonatomic) FFHomePageViewController *homePageViewController;
@property (retain ,nonatomic) TabViewController * tabViewController;
@property (retain, nonatomic) FFPageViewController *pageViewController;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpView];
}

- (void)setUpView{
    
    UIViewController * headViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeadViewController"];
    
    self.tabViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabViewController"];
    
    
    self.pageViewController = [[FFPageViewController alloc]init];
    self.pageViewController.delegate = self;
    self.pageViewController.prePages = 2;
    self.pageViewController.maxPages = 10;
    
    
    
    self.homePageViewController = [[FFHomePageViewController alloc]init];
    self.homePageViewController.style = self.segmentdControl.selectedSegmentIndex;;
    self.homePageViewController.tabHeight = 50;
    self.homePageViewController.headHeight = 200;
    self.homePageViewController.headViewController = headViewController;
    self.homePageViewController.tabViewController = self.tabViewController;
    self.homePageViewController.pageViewController = self.pageViewController;
    
    
    [self addChildViewController:self.homePageViewController];
    [self.contentView addSubview:self.homePageViewController.view];
    
    
    
    self.tabViewController.pageMenu.delegate = self;
    self.tabViewController.pageMenu.bridgeScrollView = self.pageViewController.scrollview;
    
    
    
}
- (IBAction)valueChangeAction:(UISegmentedControl *)sender {
    
    self.homePageViewController.style = sender.selectedSegmentIndex;
    
    if(sender.selectedSegmentIndex == 1){
        
        self.homePageViewController.scrollview.header = [RefreshView headerWithRefreshBlock:^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.homePageViewController.scrollview.header endRefresh];
            });
            
        }];
        
        self.pageViewController.scrollview.header.interactiveEnable = NO;
        
    } else {
        
        self.homePageViewController.scrollview.header = nil;
    }
    
    
}
- (IBAction)headHeightAction:(id)sender {
    
    self.homePageViewController.headHeight = randomBetween(200, 300);
    [self.homePageViewController reloadHeightWithAnimation:YES completion:nil];
    
}

#pragma mark - SPPageMenuDelegate

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index{
    
    [self.pageViewController scrollToPage:index animation:YES];
}


#pragma mark - FFPageViewControllerDelegate


- (NSUInteger)totalPagesOfpageViewController:(FFPageViewController *)pageViewConteoller{
    
    return self.tabViewController.pageMenu.numberOfItems;
}

- (UIViewController *)pageViewController:(FFPageViewController *)pageViewConteoller controllerForPage:(NSInteger)page{
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
    
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
