//
//  RefreshView.m
//  FFPage
//
//  Created by North on 2019/8/14.
//  Copyright © 2019 North. All rights reserved.
//

#import "RefreshView.h"

@interface RefreshView ()

@property (retain, nonatomic) UIActivityIndicatorView * indicatorView;

@end

@implementation RefreshView

/**
 设置子视图
 */
- (void)setUpSubView{
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.hidesWhenStopped =NO;
    [self addSubview:self.indicatorView];
}

/**
 状态改变
 */
- (void)statusUpdated{
    
    if (self.status == FFRereshStatusNormal){
        
        [self.indicatorView stopAnimating];
        
        return;
    }
    
    if (self.status == FFRereshStatusRereshing){
        
       [self.indicatorView startAnimating];
        
        return;
    }
    
}

/**
 上拉下拉百分比改变
 */
- (void)percentUpdated{
    
    
}
//子视图布局
- (void)layoutSubviews{
    
    self.indicatorView.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
}



@end
