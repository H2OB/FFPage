//
//  MenuViewController.m
//  FFPageExample
//
//  Created by North on 2019/10/21.
//  Copyright © 2019 North. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setUpView];
}

- (void)setUpView{
    
    self.pageMenu.permutationWay = SPPageMenuPermutationWayScrollAdaptContent;
    self.pageMenu.trackerWidth = 45;
    self.pageMenu.selectedItemTitleColor = [UIColor redColor];
    self.pageMenu.unSelectedItemTitleColor = [UIColor darkGrayColor];
    [self.pageMenu setItems:@[@"选项1",@"选项2",@"选项3",@"选项4",@"选项5",@"选项6",@"选项7",@"选项8",@"选项9",@"选项10",@"选项11",@"选项12",@"选项13",@"选项14",@"选项15",@"选项16",@"选项17",@"选项18"] selectedItemIndex:0];
}

@end
