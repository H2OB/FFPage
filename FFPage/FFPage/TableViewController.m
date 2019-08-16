//
//  TableViewController.m
//  FFPage
//
//  Created by North on 2019/8/8.
//  Copyright © 2019 North. All rights reserved.
//

#import "TableViewController.h"
#import "FFPageProtocol.h"
#import "FFPage.h"
#import "RefreshView.h"

NS_INLINE NSUInteger randomBetween(NSUInteger begin , NSUInteger end){
    
    NSUInteger value = arc4random() % end + begin;
    if(value > end) value -= begin;
    return value;
    
}

@interface TableViewController ()<FFPageProtocol>

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.rowHeight = 100;
    
    
    self.tableView.header = [RefreshView headerWithRefreshBlock:^{

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.tableView.header endRefresh];
            
        });
        
    }];
    
    self.tableView.footer = [RefreshView footerWithRefreshBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.tableView.footer endRefresh];
            
        });
        
    }];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 50, 0);
    
    
    
}

- (UIScrollView *)scrollview{
    
    return self.tableView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return randomBetween(10, 30);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:randomBetween(1, 255)/255.0 green:randomBetween(1, 255)/255.0 blue:randomBetween(1, 255)/255.0 alpha:randomBetween(1, 255)/255.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView.header beginRefresh];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"%@ --viewWillAppear ",self.identifier);
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    NSLog(@"%@ --viewWillDisappear ",self.identifier);
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%@ --viewDidAppear ",self.identifier);
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    NSLog(@"%@ --viewDidDisappear ",self.identifier);
}

- (void)dealloc{
    
    NSLog(@"%@ --dealloc ",self.identifier);
}


@end
