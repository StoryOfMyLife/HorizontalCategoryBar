//
//  TTHorizontalTabbar.h
//  HorizontalTabbar
//
//  Created by 刘廷勇 on 15/8/25.
//  Copyright (c) 2015年 liuty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectionHandler)(NSInteger index);


@interface TTCategoryItem : NSObject

@property (nonatomic, copy) NSString *title;

@end


@interface TTHorizontalCategoryBar : UIView

@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, copy) SelectionHandler didSelectCategory;

@property (nonatomic) CGFloat interitemSpacing;                 //Default 30pt

@property (nonatomic) NSUInteger selectedIndex;                 //Initial 0

@property (nonatomic, strong) UIColor *bottomIndicatorColor;    //Default redColor
@property (nonatomic) BOOL bottomIndicatorEnabled;              //Default YES

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (void)updateInteractiveTransition:(CGFloat)percentComplete fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

- (void)scrollToIndex:(NSUInteger)index;

@end
