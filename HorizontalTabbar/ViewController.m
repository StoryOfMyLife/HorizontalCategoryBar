//
//  ViewController.m
//  HorizontalTabbar
//
//  Created by 刘廷勇 on 15/8/25.
//  Copyright (c) 2015年 liuty. All rights reserved.
//

#import "ViewController.h"
#import "TTHorizontalCategoryBar.h"
#import "Masonry.h"
#import "UIViewAdditions.h"
#import "TTCollectionPageViewController.h"

@interface ViewController () <UIScrollViewDelegate, TTCollectionPageViewControllerDelegate>

@property (nonatomic, strong) TTHorizontalCategoryBar *bar;
@property (nonatomic, strong) TTCollectionPageViewController *pageViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.pageViewController.view];
    [self addChildViewController:self.pageViewController];
    
    [self.view addSubview:self.bar];
    
    [self.bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.equalTo(self.view);
        make.height.equalTo(@30);
    }];
    
    NSMutableArray *topItems = [NSMutableArray array];
    NSMutableArray *bottomItems = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        TTCategoryItem *item = [[TTCategoryItem alloc] init];
        TTCollectionPageCellItem *bottomItem = [[TTCollectionPageCellItem alloc] init];
        if (i == 1) {
            item.title = @"我是一个很长的label";
        } else if (i == 3) {
            item.title = @"我不长不短";
        } else {
            item.title = [NSString stringWithFormat:@"title%d", i];
        }
        bottomItem.title = item.title;
        [topItems addObject:item];
        [bottomItems addObject:bottomItem];
    }
    
    self.bar.categories = topItems;
    self.pageViewController.pageItems = bottomItems;
    
    __weak typeof(self) wSelf = self;
    self.bar.didSelectCategory = ^(NSInteger index) {
        [wSelf.pageViewController setCurrentPage:index scrollToPage:YES];
    };
}

- (TTHorizontalCategoryBar *)bar
{
    if (!_bar) {
        _bar = [[TTHorizontalCategoryBar alloc] initWithFrame:CGRectZero];
        _bar.bottomIndicatorColor = [UIColor orangeColor];
        _bar.bottomIndicatorEnabled = NO;
    }
    return _bar;
}

- (TTCollectionPageViewController *)pageViewController
{
    if (!_pageViewController) {
        _pageViewController = [[TTCollectionPageViewController alloc] init];
        _pageViewController.view.frame = self.view.bounds;
        _pageViewController.delegate = self;
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}

#pragma mark -
#pragma mark Page View Controller Delegate

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController pagingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent
{
    [self.bar updateInteractiveTransition:percent fromIndex:fromIndex toIndex:toIndex];
}

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController didPagingToIndex:(NSInteger)toIndex
{
    self.bar.selectedIndex = toIndex;
}

- (void)pageViewController:(TTCollectionPageViewController *)pageViewController willPagingToIndex:(NSInteger)toIndex
{
    [self.bar scrollToIndex:toIndex];
}

@end
