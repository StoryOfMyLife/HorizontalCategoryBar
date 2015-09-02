//
//  TTCollectionPageViewController.h
//  Article
//
//  Created by 刘廷勇 on 15/8/28.
//
//

#import <UIKit/UIKit.h>

@protocol TTCollectionPageViewControllerDelegate;

@interface TTCollectionPageViewController : UIViewController

/**
 *  Model
 */
@property (nonatomic, strong) NSArray *pageItems;//of TTCollectionPageCellItem

/**
 *  Currently selected page index
 */
@property (nonatomic, readonly) NSInteger currentPage;

/**
 *  Delegate
 */
@property (nonatomic, weak) id <TTCollectionPageViewControllerDelegate> delegate;

/**
 *  Trigger the reloading of current page
 */
- (void)reloadCurrentPage;

/**
 *  Update current page index
 *
 *  @param currentPage new page index
 *  @param scroll      YES to scroll current page to center position
 */
- (void)setCurrentPage:(NSInteger)currentPage scrollToPage:(BOOL)scroll;

@end

@protocol TTCollectionPageViewControllerDelegate <NSObject>

@optional

/**
 *  Called when user is dragging the page
 *
 *  @param pageViewController container view controller
 *  @param fromIndex          page which occupied over 50% of the screen, equal to current page
 *  @param toIndex            page which occupied below 50% of the screen
 *  @param percent            percent = current page width offscreen / current page width.
 *                            percent > 0 means scrolling from left to right, vice versa.
 *                            Ranging from -0.5 to 0.5
 */
- (void)pageViewController:(TTCollectionPageViewController *)pageViewController pagingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent;

/**
 *  Called on finger up after dragging
 *
 *  @param pageViewController container view controller
 *  @param toIndex            target index when stop scrollong
 */
- (void)pageViewController:(TTCollectionPageViewController *)pageViewController willPagingToIndex:(NSInteger)toIndex;

/**
 *  Called on scrollView stopped scrolling
 *
 *  @param pageViewController container view controller
 *  @param toIndex            current index
 */
- (void)pageViewController:(TTCollectionPageViewController *)pageViewController didPagingToIndex:(NSInteger)toIndex;

@end

@interface TTCollectionPageCellItem : NSObject

@property (nonatomic, copy) NSString *title;

@end