//
//  RefreshView.m
//  FFPage
//
//  Created by North on 2019/8/14.
//  Copyright © 2019 North. All rights reserved.
//

#import "RefreshView.h"

@interface RefreshView ()

@property (retain ,nonatomic) UIActivityIndicatorView * indicatorView;

@end

@implementation RefreshView

- (void)setUpSubView{
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.hidesWhenStopped =NO;
    [self addSubview:self.indicatorView];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
}

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

- (void)percentUpdated{
    
    
}

- (void)layoutSubviews{
    
    self.indicatorView.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
}



@end
