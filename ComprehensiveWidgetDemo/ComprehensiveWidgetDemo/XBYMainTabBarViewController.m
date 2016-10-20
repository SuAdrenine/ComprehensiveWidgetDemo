//
//  XBYTabBarViewController.m
//  ComprehensiveWidgetDemo
//
//  Created by xiebangyao on 2016/10/20.
//  Copyright © 2016年 xiebangyao. All rights reserved.
//

#import "XBYMainTabBarViewController.h"
#import "MainViewController.h"
#import "ContactViewController.h"
#import "ActionViewController.h"
#import "MineViewController.h"
#import <YYCategories.h>
#import <Masonry.h>

@interface XBYMainTabBarViewController ()<UITabBarControllerDelegate,UIScrollViewDelegate>{
    NSInteger lastSelectedIndex;
}

@end

@implementation XBYMainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setBool:NO forKey:@"isNotFirstLaunch"];//测试用
    Boolean isNotFirstLaunch = [userDefaults boolForKey:@"isNotFirstLaunch"];
    
    //判断滑动图是否出现过，第一次调用时"isNotFirstLaunch"这个key对应的值是NO，会进入if中
    if (!isNotFirstLaunch) {
        
        [self showScrollView];//显示滑动图
    }
    
    [self initXBYTabBarController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSInteger selectedIndex = [self.viewControllers indexOfObject:viewController];
    lastSelectedIndex = selectedIndex;
    //    if (selectedIndex == 3) {
    //        return [GGSLoginViewController showInViewController:self];
    //    }
    
    return YES;
}

#pragma mark - Private Method
-(void)initXBYTabBarController {
    CGSize imageSize = CGSizeMake(26, 26);
    MainViewController *mainVC = [MainViewController new];
    UITabBarItem *mainTabBarItem = [[UITabBarItem alloc]initWithTitle:@"首页" image:[[UIImage imageNamed:@"home"] imageByResizeToSize:imageSize] tag:100];
    mainVC.view.backgroundColor = XBYViewBackgroundColor;
    mainVC.tabBarItem = mainTabBarItem;
    
    ContactViewController *contactVC = [ContactViewController new];
    contactVC.view.backgroundColor = XBYViewBackgroundColor;
    UITabBarItem *contactTabBarItem = [[UITabBarItem alloc]initWithTitle:@"联系人" image:[[UIImage imageNamed:@"contact"] imageByResizeToSize:imageSize] tag:100];
    contactVC.tabBarItem = contactTabBarItem;
    
    ActionViewController *actionVC = [ActionViewController new];
    actionVC.view.backgroundColor = XBYViewBackgroundColor;
    UITabBarItem *actionTabBarItem = [[UITabBarItem alloc]initWithTitle:@"广场" image:[[UIImage imageNamed:@"action"] imageByResizeToSize:imageSize] tag:100];
    actionVC.tabBarItem = actionTabBarItem;
    
    MineViewController *mineVC = [MineViewController new];
    mineVC.view.backgroundColor = XBYViewBackgroundColor;
    UITabBarItem *mineTabBarItem = [[UITabBarItem alloc]initWithTitle:@"我的" image:[[UIImage imageNamed:@"mine"] imageByResizeToSize:imageSize] tag:100];
    mineVC.tabBarItem = mineTabBarItem;
    
    NSArray *viewControllers = @[[self navigationControllerWithController:mainVC],
                                 [self navigationControllerWithController:contactVC],
                                 [self navigationControllerWithController:actionVC],
                                 [self navigationControllerWithController:mineVC]];
    self.viewControllers = viewControllers;
    
    self.delegate = self;
}

- (UINavigationController *)navigationControllerWithController:(UIViewController *)vc {
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    //    ios 8属性  swipe时自动隐藏navigationBar
    //    nav.hidesBarsOnSwipe = YES;
    return nav;
}

#pragma mark - 滑动图
-(void) showScrollView{
    
    UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //设置UIScrollView 的显示内容的尺寸，有n张图要显示，就设置 屏幕宽度*n ，这里假设要显示4张图
    _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, [UIScreen mainScreen].bounds.size.height);
    
    _scrollView.tag = 101;
    
    //设置翻页效果，不允许反弹，不显示水平滑动条，设置代理为自己
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    //在UIScrollView 上加入 UIImageView
    for (int i = 0 ; i < 3; i ++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * i , 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
        //将要加载的图片放入imageView 中
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d",i+1]];
        imageView.image = image;
        
        [_scrollView addSubview:imageView];
    }
    
    //初始化 UIPageControl 和 _scrollView 显示在 同一个页面中
//    UIPageControl *pageConteol = [[UIPageControl alloc] initWithFrame:CGRectMake(140, self.view.frame.size.height - 60, 50, 40)];
    UIPageControl *_pageControl = [UIPageControl new];
    _pageControl.numberOfPages = 3;//设置pageConteol 的page 和 _scrollView 上的图片一样多
    _pageControl.tag = 201;
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_pageControl];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 20));
        make.centerX.equalTo(_scrollView);
        make.bottom.equalTo(_scrollView);
    }];
    
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    // 记录scrollView 的当前位置，因为已经设置了分页效果，所以：位置/屏幕大小 = 第几页
    int current = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    
    //根据scrollView 的位置对page 的当前页赋值
    UIPageControl *page = (UIPageControl *)[self.view viewWithTag:201];
    page.currentPage = current;
    
    //当显示到最后一页时，让滑动图消失
    if (page.currentPage == 2) {
        
        //调用方法，使滑动图消失
        [self scrollViewDisappear];
    }
}

-(void)scrollViewDisappear{
    //拿到 view 中的 UIScrollView 和 UIPageControl
    UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:101];
    UIPageControl *page = (UIPageControl *)[self.view viewWithTag:201];
    
    //设置滑动图消失的动画效果图
    [UIView animateWithDuration:2.0f animations:^{
        
        scrollView.center = CGPointMake(-self.view.frame.size.width, self.view.frame.size.height/2);
        
    } completion:^(BOOL finished) {
        
        [scrollView removeFromSuperview];
        [page removeFromSuperview];
    }];
    
    //将滑动图启动过的信息保存到 NSUserDefaults 中，使得第二次不运行滑动图
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"isNotFirstLaunch"];
    [userDefaults synchronize];

}
@end
