//
//  TTCollectionPageViewController.m
//  Article
//
//  Created by 刘廷勇 on 15/8/28.
//
//

#import "TTCollectionPageViewController.h"
#import "Masonry.h"

@implementation TTCollectionPageCellItem

@end

@interface TTCollectionPageCell : UICollectionViewCell

@property (nonatomic, strong) TTCollectionPageCellItem *item;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TTCollectionPageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:26];
        
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)setItem:(TTCollectionPageCellItem *)item
{
    if (_item != item) {
        _item = item;
        self.titleLabel.text = item.title;
    }
}

@end

@interface TTCollectionPageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, readwrite) NSInteger currentPage;
@property (nonatomic) NSInteger targetIndex;

@end

@implementation TTCollectionPageViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Register cell classes
    [self.collectionView registerClass:[TTCollectionPageCell class] forCellWithReuseIdentifier:reuseIdentifier];    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pageItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTCollectionPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.item = self.pageItems[indexPath.item];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

#pragma mark -
#pragma mark ScrollView Delegate

static BOOL userDrag = NO;//used for excluding triggerring from code

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    userDrag = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSInteger targetIndex = (*targetContentOffset).x / self.collectionView.frame.size.width;
    self.targetIndex = targetIndex;
    
    if ([self.delegate respondsToSelector:@selector(pageViewController:willPagingToIndex:)]) {
        [self.delegate pageViewController:self willPagingToIndex:targetIndex];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (CGFloat)scrollPercent:(UIScrollView *)scrollView
{
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    
    CGSize pageSize = self.collectionView.frame.size;
    CGFloat percent = 0.0f;
    
    if (pageSize.width > 0) {
        percent = (scrollView.contentOffset.x - attributes.frame.origin.x) / pageSize.width;
    }
    return percent;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (userDrag && [self.delegate respondsToSelector:@selector(pageViewController:pagingFromIndex:toIndex:completePercent:)]) {
        
        CGFloat percent = [self scrollPercent:scrollView];
        
        NSInteger fromIndex = self.currentPage;
        if (percent >= 0.5) {
            fromIndex = self.currentPage + 1;
            percent -= 1;
        } else if (percent <= -0.5) {
            fromIndex = self.currentPage - 1;
            percent += 1;
        }
        
        if (fromIndex >= 0 && fromIndex < self.pageItems.count) {
            self.currentPage = fromIndex;
        }
        
        NSInteger toIndex = percent > 0 ? fromIndex + 1 : fromIndex - 1;
        
//        NSLog(@"new page : %d  percent : %.2f", fromIndex, percent);
        
        [self.delegate pageViewController:self pagingFromIndex:fromIndex toIndex:toIndex completePercent:percent];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (userDrag && [self.delegate respondsToSelector:@selector(pageViewController:didPagingToIndex:)]) {
        [self.delegate pageViewController:self didPagingToIndex:self.currentPage];
    }
    userDrag = NO;
}

#pragma mark -
#pragma mark Methods

- (void)reloadCurrentPage
{
//    TTCollectionPageCell *cell = (TTCollectionPageCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
}

#pragma mark -
#pragma mark Accessors

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
}

- (void)setCurrentPage:(NSInteger)currentPage scrollToPage:(BOOL)scroll
{
    self.currentPage = currentPage;
    if (scroll) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

@end