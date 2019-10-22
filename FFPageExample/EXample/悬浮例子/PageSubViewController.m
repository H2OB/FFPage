//
//  PageSubViewController.m
//  FFPageExample
//
//  Created by North on 2019/10/21.
//  Copyright © 2019 North. All rights reserved.
//

#import "PageSubViewController.h"
#import "FFPageProtocol.h"
#import "RefreshView.h"
@interface PageSubViewController ()<FFPageProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PageSubViewController

#pragma FFPageProtocol
- (UIScrollView *)scrollview{
    
    return self.tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 100;
    
    self.tableView.header = [RefreshView initWithRefreshBlock:^{

         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

             [self.tableView.header endRefresh];

         });

     }];

    
     self.tableView.footer = [RefreshView initWithRefreshBlock:^{

         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

             [self.tableView.footer endRefresh];

         });

     }];
    
   

}


#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//
//    return 100;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 50;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//    UIView * view = [UIView new];
//    view.backgroundColor = [UIColor greenColor];
//    return view;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

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
