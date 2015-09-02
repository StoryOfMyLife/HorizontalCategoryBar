//
//  TTHorizontalTabbar.m
//  HorizontalTabbar
//
//  Created by 刘廷勇 on 15/8/25.
//  Copyright (c) 2015年 liuty. All rights reserved.
//

#import "TTHorizontalCategoryBar.h"
#import "Masonry.h"

#define kTextFont [UIFont systemFontOfSize:15]
static const NSTimeInterval animateDuration = 0.3f;
static const CGFloat transformScale = 1.2f;

#pragma mark -
#pragma mark CategoryItem

@implementation TTCategoryItem

@end

#pragma mark -
#pragma mark CategoryCell

@interface TTCategoryCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *maskLabel;

@property (nonatomic, strong) TTCategoryItem *cellItem;

@property (nonatomic) BOOL enableHightedStatus;
@property (nonatomic) BOOL animatedHighlighted;

@end

@implementation TTCategoryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubview];
    }
    return self;
}

- (void)initSubview
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = kTextFont;
    
    self.maskLabel = [[UILabel alloc] init];
    self.maskLabel.textAlignment = self.titleLabel.textAlignment;
    self.maskLabel.backgroundColor = self.titleLabel.backgroundColor;
    self.maskLabel.textColor = [UIColor redColor];
    self.maskLabel.font = kTextFont;
    self.maskLabel.alpha = 0.f;
    
    self.animatedHighlighted = YES;
    
    [self.contentView addSubview:self.maskLabel];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    
    [self.maskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.titleLabel);
    }];
}

- (void)setCellItem:(TTCategoryItem *)cellItem
{
    self.titleLabel.text = cellItem.title;
    self.maskLabel.text = cellItem.title;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (self.enableHightedStatus) {
        [UIView animateWithDuration:(self.animatedHighlighted ? animateDuration : 0) animations:^{
            if (selected) {
                self.titleLabel.alpha = 0;
                self.maskLabel.alpha = 1;
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, transformScale, transformScale);
            } else {
                self.titleLabel.alpha = 1;
                self.maskLabel.alpha = 0;
                self.transform = CGAffineTransformIdentity;
            }
        }];
    }
}

@end

#pragma mark -
#pragma mark CategoryBar

@interface TTHorizontalCategoryBar () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIView *bottomIndicator;
@property (nonatomic, strong) UIView *bottomSeperator;

@end

@implementation TTHorizontalCategoryBar

#pragma mark -
#pragma mark init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self setupConstraints];
    }
    return self;
}

- (void)initView
{
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumInteritemSpacing = 30;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = nil;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[TTCategoryCell class] forCellWithReuseIdentifier:NSStringFromClass([TTCategoryCell class])];
    
    self.bottomIndicator = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomIndicator.backgroundColor = [UIColor redColor];
    [self.collectionView addSubview:self.bottomIndicator];
    
    self.bottomSeperator = [[UIView alloc] init];
    self.bottomSeperator.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.bottomSeperator];
    
    self.bottomIndicatorEnabled = YES;
}

- (void)setupConstraints
{
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.bottomIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.height.equalTo(@3);
    }];
    
    [self.bottomSeperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(self);
        make.height.equalTo(@0.5);
    }];
}

- (void)setCategories:(NSArray *)categories
{
    if (_categories != categories) {
        _categories = categories;
        [self.collectionView reloadData];
        self.selectedIndex = 0;
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing
{
    if (_interitemSpacing != interitemSpacing) {
        _interitemSpacing = interitemSpacing;
        self.flowLayout.minimumInteritemSpacing = interitemSpacing;
        [self.flowLayout invalidateLayout];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
    
        TTCategoryCell *cell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
        TTCategoryCell *lastSelectedCell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]];
        
        cell.selected = YES;
        lastSelectedCell.selected = NO;
        
        _selectedIndex = selectedIndex;
        
        [self.bottomIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(CGRectGetWidth(cell.frame)));
            make.left.equalTo(@(CGRectGetMinX(cell.frame)));
        }];
        
        [UIView animateWithDuration:animateDuration animations:^{
            if (self.bottomIndicatorEnabled) {
                [self.bottomIndicator layoutIfNeeded];
            }
        }];
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)scrollToIndex:(NSUInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)setBottomIndicatorColor:(UIColor *)bottomIndicatorColor
{
    if (_bottomIndicatorColor != bottomIndicatorColor) {
        _bottomIndicatorColor = bottomIndicatorColor;
        self.bottomIndicator.backgroundColor = bottomIndicatorColor;
    }
}

- (void)setBottomIndicatorEnabled:(BOOL)bottomIndicatorEnabled
{
    _bottomIndicatorEnabled = bottomIndicatorEnabled;
    self.bottomIndicator.hidden = !bottomIndicatorEnabled;
}

- (CGSize)sizeForItem:(TTCategoryItem *)item
{
    if (item.title.length > 0) {
        CGFloat height = self.collectionView.frame.size.height;
        CGSize size = [item.title boundingRectWithSize:CGSizeMake(NSIntegerMax, height) options:NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : kTextFont } context:nil].size;
        return CGSizeMake(size.width, height);
    } else {
        return CGSizeZero;
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    if (fromIndex < 0 || fromIndex >= [self.categories count] || toIndex < 0 || toIndex >= [self.categories count]) {
        return;
    }
    
    percentComplete = MAX(-1, MIN(percentComplete, 1));
    
    TTCategoryCell *fromCell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]];
    TTCategoryCell *toCell = (TTCategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
    
    if (self.bottomIndicatorEnabled) {
        UICollectionViewLayoutAttributes *fromAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]];
        UICollectionViewLayoutAttributes *toAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
        
        CGFloat proposedWidth = CGRectGetWidth(fromAttributes.frame);
        CGFloat targetWidth = CGRectGetWidth(toAttributes.frame);
        
        CGPoint proposedOffset = fromAttributes.frame.origin;
        CGPoint targetOffset = toAttributes.frame.origin;
        
        [self.bottomIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(proposedWidth + (targetWidth - proposedWidth) * fabs(percentComplete)));
            make.left.equalTo(@(proposedOffset.x + (targetOffset.x - proposedOffset.x) * fabs(percentComplete)));
        }];
        
        [self.bottomIndicator layoutIfNeeded];
    } else {
        CGFloat transformScaleDelta = (transformScale - 1);
        CGFloat percent = fabs(percentComplete);
        
        CGFloat fromScale = 1 + transformScaleDelta * (1 - percent);
        CGFloat toScale = 1 + transformScaleDelta * percent;
    
        fromCell.titleLabel.alpha = percent;
        fromCell.maskLabel.alpha = 1 - percent;
        fromCell.transform = CGAffineTransformMakeScale(fromScale, fromScale);
        
        if (fromIndex != toIndex) {
            toCell.titleLabel.alpha = 1- percent;
            toCell.maskLabel.alpha = percent;
            toCell.transform = CGAffineTransformMakeScale(toScale, toScale);
        }
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTCategoryCell class]) forIndexPath:indexPath];
    cell.cellItem = self.categories[indexPath.row];
    cell.enableHightedStatus = !self.bottomIndicatorEnabled;

    cell.selected = NO;
    if (self.selectedIndex == indexPath.item && indexPath.item == 0) {
        cell.selected = YES;
        if (self.didSelectCategory) {
            self.didSelectCategory(indexPath.item);
        }
        [self.bottomIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(CGRectGetWidth(cell.frame)));
            make.left.equalTo(@(CGRectGetMinX(cell.frame)));
        }];
    }
    if (self.selectedIndex == indexPath.item) {
        cell.selected = YES;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.item;
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if (self.didSelectCategory) {
        self.didSelectCategory(indexPath.item);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((TTCategoryCell *)cell).animatedHighlighted = NO;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((TTCategoryCell *)cell).animatedHighlighted = YES;
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTCategoryItem *item = self.categories[indexPath.item];
    return [self sizeForItem:item];
}

//For centering adjustment
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat totalWidth = 0;
    for (TTCategoryItem *item in self.categories) {
        totalWidth += [self sizeForItem:item].width;
    }
    
    CGFloat canvasWidth = collectionView.frame.size.width;
    CGFloat itemSpacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];

    CGFloat inset = (canvasWidth - itemSpacing * (numberOfItems - 1) - totalWidth) / 2;
    
    UIEdgeInsets sectionInset = ((UICollectionViewFlowLayout *)collectionViewLayout).sectionInset;
    if (inset < sectionInset.left) {
        return sectionInset;
    } else {
        return UIEdgeInsetsMake(0, inset, 0, inset);
    }
}

@end