//
//  HomePageViewController.m
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#import "HomePageViewController.h"
#import "FFPage.h"
@interface HomePageViewController ()<FFPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) FFHomePageViewController *homePageViewController;
@property (weak, nonatomic) FFPageViewController *pageViewController;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpView];
}

- (void)setUpView{
    
    UIViewController * headViewController = [[UIViewController alloc]init];
    headViewController.view.backgroundColor = UIColor.redColor;
    
    
    UIViewController *tabViewController = [[UIViewController alloc]init];
    tabViewController.view.backgroundColor = UIColor.greenColor;
    
    FFPageViewController *pageViewController = [[FFPageViewController alloc]init];
    pageViewController.delegate = self;
    pageViewController.prePages = 2;
    pageViewController.maxPages = 10;
    
    self.pageViewController = pageViewController;
    
    FFHomePageViewController * homePageViewController = [[FFHomePageViewController alloc]init];
    homePageViewController.style = FFHomePageStyleSubRefresh;
    homePageViewController.tabHeight = 50;
    homePageViewController.headHeight = 200;
    homePageViewController.headViewController = headViewController;
    homePageViewController.tabViewController = tabViewController;
    homePageViewController.pageViewController = pageViewController;
    
    
    [self addChildViewController:homePageViewController];
    [self.contentView addSubview:homePageViewController.view];
    
    self.homePageViewController = homePageViewController;
    
    
    
    
    
}

- (NSUInteger)totalPagesOfpageViewController:(FFPageViewController *)pageViewConteoller{
    
    return 100;
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
