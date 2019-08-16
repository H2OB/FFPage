//
//  PageViewController.m
//  FFPage
//
//  Created by North on 2019/8/9.
//  Copyright © 2019 North. All rights reserved.
//

#import "PageViewController.h"
#import "FFPage.h"

@interface PageViewController ()<FFPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *pageTextField;
@property (retain, nonatomic)  FFPageViewController *pageViewController;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.pageViewController = [[FFPageViewController alloc]init];
    self.pageViewController.delegate = self;
//    self.pageViewController.prePages = 0;
//    self.pageViewController.maxPages = 50;
    [self addChildViewController:self.pageViewController];
    [self.contentView addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
    
    
    
}

- (IBAction)jumpBtnAction:(id)sender {
    
    [self.view endEditing:YES];
    
    [self.pageViewController scrollToPage:[self.pageTextField.text integerValue] animation:NO];
}

- (IBAction)reloadBtnAction:(id)sender {
    
    [self.view endEditing:YES];
    
    [self.pageViewController reloadData];
}



- (NSUInteger)totalPagesOfpageViewController:(FFPageViewController *)pageViewConteoller{
    
    return 100;
}

- (UIViewController *)pageViewController:(FFPageViewController *)pageViewConteoller controllerForPage:(NSInteger)page{
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
    
    [controller setValue:@(page).stringValue forKey:@"identifier"];
    
    return  controller;
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    self.pageViewController.view.frame = self.contentView.bounds;
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

@end
