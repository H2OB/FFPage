# FFPage
![FFPage](https://github.com/H2OB/FFPage/blob/master/FFPage.gif)


## 支持
* 刷新/放大效果
* 差异滚动(左右两边滚动偏移量不互相影响)
* 动画改变高度
* 支持旋屏

## 用法

step1   使用中可参考 HomePageViewController

```
    
    self.homePageViewController = [[FFHomePageViewController alloc]init];
    //设置样式 包括头部放大/头部刷新/底部刷新
    self.homePageViewController.style = self.segmentdControl.selectedSegmentIndex;;
    //设置分类高度
    self.homePageViewController.categroyHeight = 50;
    //设置head高度
    self.homePageViewController.headHeight = 300;
    //设置头部
    self.homePageViewController.headViewController = headViewController;
    
    //设置分类
    self.homePageViewController.categroyViewController = self.tabViewController;
   
    //项目内内置了一个替代UIPageViewController的控件 可用其他替代
    self.homePageViewController.pageViewController = self.pageViewController;
    
    
    [self addChildViewController:self.homePageViewController];
    [self.contentView addSubview:self.homePageViewController.view];
    [self.homePageViewController didMoveToParentViewController:self];
    
    
    
    
```

step2   使用中可参考 TableViewController


```
//在下方可以左右切换的页面中需要实现 <FFPageProtocol>

//告诉他你的滚动视图是哪一个
- (UIScrollView *)scrollview{
    
    return self.tableView;
}

```

step3

```
更新当前控制器是哪一个

[self.homePageViewController updateCurrentController:self.pageViewController.currentController];

```

other 
如果需要根据滚动便宜量对导航栏透明度颜色等做改变 可以接收通知FFHomeScrollViewContentOffsetChangedNotice 



原理会在以后陆续更新
