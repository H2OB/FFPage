# FFPage
![FFPage](https://github.com/H2OB/FFPage/blob/master/FFPage.gif)


## 支持
* 刷新/放大效果
* 差异滚动(左右两边滚动偏移量不互相影响)
* 动画改变高度

## 用法

```
    
    self.homePageViewController = [[FFHomePageViewController alloc]init];
    //设置样式
    self.homePageViewController.style = self.segmentdControl.selectedSegmentIndex;;
    self.homePageViewController.tabHeight = 50;
    self.homePageViewController.headHeight = 300;
    self.homePageViewController.headViewController = headViewController;
    self.homePageViewController.tabViewController = self.tabViewController;
    //项目内内置了一个替代UIPageViewController的控件 可用其他替代
    self.homePageViewController.pageViewController = self.pageViewController;
    
    
    [self addChildViewController:self.homePageViewController];
    [self.contentView addSubview:self.homePageViewController.view];
    [self.homePageViewController didMoveToParentViewController:self];
    
    
    参考HomePageViewController类
    
```

```
//在下方可以左右切换的页面中需要实现 <FFPageProtocol>

//告诉他你的滚动视图是哪一个
- (UIScrollView *)scrollview{
    
    return self.tableView;
}

   参考 TableViewController





```
