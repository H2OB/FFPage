# FFPage
![FFPage](https://github.com/H2OB/FFPage/blob/master/FFPage.gif)


## 支持
* 刷新/放大效果
* 差异滚动(左右两边滚动偏移量不互相影响)
* 动画改变高度
* 支持旋屏

## 用法

```
pod 'FFPage'
```


`Step1`    
使用中可参考 `PinExampleViewController`

```
    // 初始化
    self.adapterViewController = [[FFAdapterViewController alloc]init];
    // 设置样式
    self.adapterViewController.style = FFPageStyle样式;
    // 设置头部视图高度
    self.adapterViewController.headHeight = 头部高度;
    // 设置菜单/分类控制器视图高度
    self.adapterViewController.menuHeight = 菜单高度;
    
    // 设置头部控制器
    self.adapterViewController.headViewController = 头部控制器;
    // 设置菜单/分类控制器
    self.adapterViewController.menuViewController = 菜单控制器;
    // 设置底部分页控制器
    self.adapterViewController.pageViewController = 分页控制器;
    
    
    [self addChildViewController:self.adapterViewController];
    [self.contentView addSubview:self.adapterViewController.view];
    [self.adapterViewController didMoveToParentViewController:self];
    
    
    // 如果你已经设置好了高度又想改变头部视图高度或者菜单高度
    self.adapterViewController.headHight = 您想修改的高度;
    self.adapterViewController.menuHeight = 您想修改的高度;
    [self.adapterViewController updateHeightWithAnimation:YES completion:^{
            
    }];
```

`Step2`   
使用中可参考 `PageSubViewController`


```
//在下方可以左右切换的页面中需要实现 <FFPageProtocol>

//告诉他你的滚动视图是哪一个
- (UIScrollView *)scrollview{
    
    return self.tableView;
}
```

`step3`

```
更新当前控制器是哪一个
[self.adapterViewController updateCurrentController:self.pageViewController.currentController];
```

`Tips` 

如果需要根据滚动偏移对导航栏透明度颜色等做改变 可以接收通知FFHomeScrollViewContentOffsetChangedNotice 值是一个`CGPoint`的字符串 

## 原理
禁用`UIScrollView`的滚动，然后增加`UIPanGestureRecognizer`来传递滚动防止手势冲突
参考了https://www.jianshu.com/p/42858f95ab43
https://github.com/xuning0/ScrollViewNestDemo


## `Other`
项目中内置了一个`FFPageViewController`用来替代`UIPageViewController`,采用`RunLoop`来预加载，采用`LRU`算法自动释放超过限制数量的控制器,每个控制器都有自己的生命周期，对内存和`CPU`进行了优化。

